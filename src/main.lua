import "CoreLibs/easing"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "vendor/pdfxr"

local pd = playdate
local gfx = pd.graphics
local screenWidth, screenHeight = pd.display.getSize()
local sidebarWidth = 48

math.randomseed(pd.getSecondsSinceEpoch())

local saveData = pd.datastore.read() or { highScore = 0 }

local MOON_DISTANCE_FROM_EARTH = 70
local STAR_SCORE = 100
local MAX_RAMP_UP_DIFFICULTY = 120
local MIN_RAMP_UP_DIFFICULTY = 40

local difficultyLevels = {
  easy = 125,   -- asteroid spawns every 2.5 seconds
  normal = 100, -- asteroid spawns every 2 seconds
  hard = 75,    -- asteroid spawns every 1.5 seconds
  aaaah = 50,   -- asteroid spawns every 1 second
}

local gs = {
  scene = 'title',
  difficulty = 'ramp-up',
  screenShakeEnabled = not pd.getReduceFlashing()
}

local function updateRampUpDifficulty()
  gs.rampUpDifficulty = MAX_RAMP_UP_DIFFICULTY - math.floor(
    pd.easingFunctions.outSine(
      gs.frameCount,
      0,
      MAX_RAMP_UP_DIFFICULTY - MIN_RAMP_UP_DIFFICULTY,
      22500 -- 7.5 minutes
    )
  )
end

local function resetGameState()
  gs.frameCount = 0
  gs.score = 0

  gs.earth = {
    pos = pd.geometry.point.new(screenWidth // 2 + sidebarWidth // 2, screenHeight // 2),
    radius = 14,
    mass = 0.75,
    health = 5,
    maxHealth = 5,
    bombs = 2,
    maxBombs = 5,
    hasShield = false,
  }

  gs.moon = {
    pos = pd.geometry.point.new(gs.earth.pos.x, gs.earth.pos.y - MOON_DISTANCE_FROM_EARTH),
    distanceFromEarth = MOON_DISTANCE_FROM_EARTH,
    radius = 7,
    gravityRadius = 75,
    mass = 2.5,
    hasShield = false,
  }

  gs.bombShockwave = 0
  gs.bombShockwavePos = nil

  gs.curRocket = nil
  gs.lastRocketAt = 0

  gs.explosions = {}
  gs.curExplosionId = 0

  gs.asteroids = {}
  gs.curAsteroidId = 0
  gs.lastAsteroidAt = 0

  gs.targets = {}
  gs.curTargetId = 0

  gs.particles = {}
  gs.curParticleId = 0

  gs.stars = {}
  for _ = 1, 100 do
    table.insert(gs.stars, pd.geometry.point.new(math.random() * screenWidth, math.random() * screenHeight))
  end

  gs.curMessage = nil
  gs.curMessageAt = nil

  gs.gameoverSelection = 'retry'
  gs.isHighScore = false

  updateRampUpDifficulty()
end
resetGameState()

local assets = {
  fonts = {
    large = gfx.getSystemFont(),
    small = gfx.font.new("fonts/font-rains-1x")
  },
  sfx = {
    boop = pdfxr.synth.new("sounds/boop"),
    boom = pdfxr.synth.new("sounds/boom"),
    goodBoom = pdfxr.synth.new("sounds/good-boom"),
    point = pdfxr.synth.new("sounds/point"),
    powerup = pdfxr.synth.new("sounds/powerup"),
    shieldDown = pdfxr.synth.new("sounds/shield-down"),
    shieldUp = pdfxr.synth.new("sounds/shield-up")
  },
  gfx = {
    rocketNorth = gfx.image.new("images/rocket-orth"),
    rocketNorthEast = gfx.image.new("images/rocket-diag"),

    explosion = gfx.imagetable.new("images/explosion"),

    heart = gfx.image.new("images/heart"),
    heartEmpty = gfx.image.new("images/empty-heart"),
    bomb = gfx.image.new("images/bomb"),
    star = gfx.image.new("images/star"),

    arrowUp = gfx.image.new("images/arrow-up"),
    arrowRight = gfx.image.new("images/arrow-right"),
  }
}
assets.gfx.rocketEast = assets.gfx.rocketNorth:rotatedImage(90)

local rocketDirectionInfo = {
  north = {
    image = assets.gfx.rocketNorth,
    angle = 0,
    anchor = { x = 0.5, y = 1 },
    flip = gfx.kImageUnflipped,
  },
  northeast = {
    image = assets.gfx.rocketNorthEast,
    angle = 45,
    anchor = { x = 0, y = 1 },
    flip = gfx.kImageUnflipped,
  },
  east = {
    image = assets.gfx.rocketEast,
    angle = 90,
    anchor = { x = 0, y = 0.5 },
    flip = gfx.kImageUnflipped,
  },
  southeast = {
    image = assets.gfx.rocketNorthEast,
    angle = 135,
    anchor = { x = 0, y = 0 },
    flip = gfx.kImageFlippedY,
  },
  south = {
    image = assets.gfx.rocketNorth,
    angle = 180,
    anchor = { x = 0.5, y = 0 },
    flip = gfx.kImageFlippedY,
  },
  southwest = {
    image = assets.gfx.rocketNorthEast,
    angle = 225,
    anchor = { x = 1, y = 0 },
    flip = gfx.kImageFlippedXY,
  },
  west = {
    image = assets.gfx.rocketEast,
    angle = 270,
    anchor = { x = 1, y = 0.5 },
    flip = gfx.kImageFlippedX,
  },
  northwest = {
    image = assets.gfx.rocketNorthEast,
    angle = 315,
    anchor = { x = 1, y = 1 },
    flip = gfx.kImageFlippedX,
  },
}
local rocketDirections = {}
for direction, _ in pairs(rocketDirectionInfo) do
  table.insert(rocketDirections, direction)
end

local function spawnRocket()
  local direction = rocketDirections[math.random(#rocketDirections)]
  local directionInfo = rocketDirectionInfo[direction]
  local pos = gs.earth.pos + pd.geometry.vector2D.newPolar(gs.earth.radius + 1, directionInfo.angle)
  gs.curRocket = {
    frame = 0,
    pos = pos,
    vel = pd.geometry.vector2D.new(0, 0),
    acc = pd.geometry.vector2D.new(0, 0),
    direction = direction,
    info = directionInfo
  }
end

local function spawnExplosion(pos)
  gs.curExplosionId += 1
  local id = gs.curExplosionId
  gs.explosions[id] = {
    pos = pos,
    frame = 0,
  }
end

local function spawnParticle(pos, vel, ttl, minRadius, maxRadius, ditherAlpha)
  gs.curParticleId += 1
  local id = gs.curParticleId
  gs.particles[id] = {
    pos = pos,
    vel = vel,
    ttl = ttl,
    minRadius = minRadius,
    maxRadius = maxRadius,
    ditherAlpha = ditherAlpha,
  }
end

local function nextAsteroidId()
  gs.curAsteroidId += 1
  return gs.curAsteroidId
end

local function spawnAsteroid()
  local id = nextAsteroidId()
  local angle = math.random() * 360
  local pos = gs.earth.pos + pd.geometry.vector2D.newPolar(250, angle)
  local chooseRadius = math.random()
  local asteroidRadius
  if chooseRadius < 0.6 then
    asteroidRadius = 3
  elseif chooseRadius < 0.9 then
    asteroidRadius = 4
  elseif chooseRadius < 0.95 then
    asteroidRadius = 5
  elseif chooseRadius < 0.99 then
    asteroidRadius = 6
  else
    asteroidRadius = 7
  end
  local speed
  if pos.x < 0 or pos.x >= screenWidth then
    speed = math.random(5, 14) / 10
  else
    speed = math.random(5, 9) / 10
  end
  gs.asteroids[id] = {
    id = id,
    pos = pos,
    vel = -pd.geometry.vector2D.newPolar(
      speed,
      angle + (math.random() * 40 - 20) -- vary angle from -20 to +20
    ),
    radius = asteroidRadius,
    state = 'entering',
  }
  return id
end

local function spawnTarget(x, y, r)
  gs.curTargetId += 1
  local id = gs.curTargetId
  gs.targets[id] = {
    id = id,
    pos = pd.geometry.point.new(x, y),
    radius = r,
    health = 100,
  }
  return id
end

local function closestAsteroidDirection()
  local direction = pd.geometry.vector2D.new(0, 0)
  local minDistance = nil
  for _, asteroid in pairs(gs.asteroids) do
    local earthVec = asteroid.pos - gs.earth.pos
    local distance = earthVec:magnitudeSquared()
    if minDistance == nil or distance < minDistance then
      minDistance = distance
      direction = earthVec:normalized()
    end
  end
  return direction
end

local function isAsteroidOnScreen(asteroid)
  local x, y, r = asteroid.pos.x, asteroid.pos.y, asteroid.radius
  return x + r >= sidebarWidth and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

local function isRocketOnScreen(rocket)
  local x, y, r = rocket.pos.x, rocket.pos.y, 3
  return x + r >= sidebarWidth and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

local function areCirclesColliding(centerA, radiusA, centerB, radiusB)
  local distance = (centerB - centerA):magnitude()
  return distance <= radiusA + radiusB
end

local function isRocketCollidingWithCircle(rocket, center, radius)
  local direction = pd.geometry.vector2D.newPolar(1, rocket.info.angle)
  -- Collision zone consists of three small circles along the length of the rocket
  for section = 0, 2 do
    local pos = rocket.pos + direction:scaledBy(section * 2)
    if areCirclesColliding(pos, 1.5, center, radius) then
      return true
    end
  end
  return false
end

local function flashMessage(message)
  gs.curMessage = message
  gs.curMessageAt = gs.frameCount
end

local function clamp(value, low, high)
  return math.min(high, math.max(low, value))
end

local function screenShake(shakeTime, shakeMagnitude)
  if not gs.screenShakeEnabled then
    return
  end

  local shakeTimer = pd.timer.new(shakeTime, shakeMagnitude, 0)

  shakeTimer.updateCallback = function(timer)
    -- Using the timer value, so the shaking magnitude
    -- gradually decreases over time
    local magnitude = math.floor(timer.value)
    local shakeX = math.random(-magnitude, magnitude)
    local shakeY = math.random(-magnitude, magnitude)
    pd.display.setOffset(shakeX, shakeY)
  end

  shakeTimer.timerEndedCallback = function()
    pd.display.setOffset(0, 0)
  end
end

local menu = pd.getSystemMenu()
menu:addOptionsMenuItem('difficulty', { 'easy', 'normal', 'ramp-up', 'hard', 'aaaah' }, gs.difficulty, function(selected)
  gs.difficulty = selected
  updateRampUpDifficulty()
end)
menu:addCheckmarkMenuItem('screen shake', gs.screenShakeEnabled, function(checked)
  gs.screenShakeEnabled = checked
end)

-- Menu items that should be removed when going back to the title screen
local inGameMenuItems = {}

local function resetMenu()
  for _, menuItem in ipairs(inGameMenuItems) do
    menu:removeMenuItem(menuItem)
  end
  inGameMenuItems = {}
end

pd.display.setRefreshRate(50)
gfx.setBackgroundColor(gfx.kColorBlack)

function pd.update()
  pd.timer.updateTimers()

  if gs.scene == 'title' then
    gfx.clear()

    -- TODO: Try drawing stars to a background image once instead?
    gfx.setColor(gfx.kColorWhite)
    for _, star in ipairs(gs.stars) do
      gfx.drawPixel(star)
    end

    local animFrame = math.min(gs.frameCount, 700)

    -- Earth
    local earthX, earthY = screenWidth - 60, screenHeight // 4
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.45, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(earthX, earthY, 20)

    -- Earth eyes
    local leftEye = pd.geometry.point.new(earthX - 7, earthY - 7)
    local rightEye = pd.geometry.point.new(earthX + 7, earthY - 7)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(leftEye, 5)
    gfx.fillCircleAtPoint(rightEye, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(leftEye, 2)
    gfx.fillCircleAtPoint(rightEye, 2)

    -- Moon
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(screenWidth / 3 + animFrame / 10, screenHeight * 2 / 3 - animFrame / 20, screenWidth / 3)

    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(screenWidth // 4, screenHeight // 2 - 12, screenWidth // 2, 24, 5)

    gfx.setFont(assets.fonts.large)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("*The Moon is our Friend*", screenWidth // 2, screenHeight // 2 - 9, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    local perlY = math.min(3, math.max(-3, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(screenWidth // 2 - 70, screenHeight - screenHeight // 4 - 5 + perlY, 140, 17, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(screenWidth // 2 - 70, screenHeight - screenHeight // 4 - 5 + perlY, 140, 17, 5)
    gfx.setFont(assets.fonts.small)
    gfx.drawTextAligned("Press A to start", screenWidth // 2, screenHeight - screenHeight // 4 + perlY,
      kTextAlignment.center)

    if saveData.highScore > 0 then
      local hasStar = saveData.highScore >= STAR_SCORE
      gfx.setFont(assets.fonts.small)
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
      gfx.drawTextAligned("High score\n" .. saveData.highScore .. (hasStar and "  " or ""), screenWidth - 7,
        screenHeight - 30,
        kTextAlignment.right,
        8)
      gfx.setImageDrawMode(gfx.kDrawModeCopy)

      if hasStar then
        assets.gfx.star:draw(screenWidth - 19, screenHeight - 18)
      end
    end

    gs.frameCount += 1

    if pd.buttonJustReleased(pd.kButtonA) then
      gs.scene = 'story'
      gs.frameCount = 0
      assets.sfx.boop:play()
    end
    return
  elseif gs.scene == 'story' or gs.scene == 'instructions' then
    gfx.clear()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(0, 0, screenWidth, screenHeight, 15)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(1, 1, screenWidth - 2, screenHeight - 2, 15)

    local text
    local paddingX, paddingY = 10, 10
    local titleY
    local title
    if gs.scene == 'story' then
      title = "2038: The Moon Wakes Up"
      titleY = 16
      paddingY = 50
      text = {
        "After a large-scale asteroid mining expedition\ngone wrong, "
        .. "the Earth is now under a barrage of\nasteroids, and is very scared.",
        "Desparate to help its best friend, "
        .. "the Moon wakes\nup from its deep slumber "
        .. "and springs into action\nto protect the Earth." }
    else
      title = "How to play"
      titleY = 10
      paddingY = 36
      text = {
        "Use the crank to control the Moon and "
        .. "pull\nincoming asteroids away from the Earth. "
        .. "Get\n*+1 point* per asteroid averted, "
        .. "and *+5 points* for\ngetting two asteroids to collide with each other!",
        "Try to grab any supplies the Earth sends your\nway - "
        .. "they may contain extra health or various\npowerups.",
        "If you get *100 points*, you get a little gold star on\nthe title screen. Good luck!"
      }
    end

    local maxChars = math.floor(gs.frameCount * 1.5)

    gfx.setFont(assets.fonts.large)

    if title then
      gfx.drawTextAligned('*' .. title .. '*', screenWidth // 2, titleY, kTextAlignment.center)
    end

    local done = true
    local textY = paddingY
    for _, para in ipairs(text) do
      if maxChars < #para then
        para = string.sub(para, 1, maxChars)
        done = false
      end
      local _, paraHeight = gfx.drawText(para, paddingX, textY, screenWidth - paddingX * 2, screenHeight)
      textY += paraHeight + 10
      if maxChars < #para then
        break
      else
        maxChars -= #para
      end
    end

    local perlY = math.min(3, math.max(-3, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
    gfx.drawText("Ⓐ", screenWidth - 28, screenHeight - 28 + perlY)

    gs.frameCount += 1

    if pd.buttonJustReleased(pd.kButtonA) then
      if not done then
        gs.frameCount = 1000000
      elseif gs.scene == 'story' then
        gs.scene = 'instructions'
        gs.frameCount = 0
        assets.sfx.boop:play()
      else
        gs.scene = 'game'
        resetGameState()
        assets.sfx.boop:play(77)

        table.insert(inGameMenuItems, (menu:addMenuItem('restart game', function()
          resetGameState()
          gs.scene = 'game'
        end)))
        table.insert(inGameMenuItems, (menu:addMenuItem('back to title', function()
          resetGameState()
          gs.scene = 'title'
          resetMenu()
        end)))
      end
    end
    return
  elseif gs.scene == 'gameover' then
    if gs.isHighScore then
      local highScoreBoxWidth = pd.easingFunctions.outExpo(gs.frameCount, 0, 136, 50)
      gfx.setColor(gfx.kColorWhite)
      gfx.fillRoundRect(screenWidth - highScoreBoxWidth, 26, highScoreBoxWidth + 5, 24, 5)
      gfx.setFont(assets.fonts.large)
      gfx.drawText("New high score!", screenWidth - highScoreBoxWidth + 11, 29)
    end

    local gameoverBoxHeight = pd.easingFunctions.outExpo(gs.frameCount, 0, 32, 50)
    local gameoverBoxLeft = sidebarWidth + 32
    local gameoverBoxWidth = screenWidth - gameoverBoxLeft
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
    gfx.fillRect(gameoverBoxLeft, screenHeight - gameoverBoxHeight, gameoverBoxWidth, gameoverBoxHeight)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(gameoverBoxLeft + 4, screenHeight - gameoverBoxHeight + 4, gameoverBoxWidth - 4, gameoverBoxHeight - 4)
    gfx.setFont(assets.fonts.large)
    gfx.drawText("*Game Over*", gameoverBoxLeft + 20, screenHeight - gameoverBoxHeight + 9)

    gfx.setFont(assets.fonts.small)
    local optionY = screenHeight - gameoverBoxHeight + 15
    local retryX = screenWidth // 2 + 16
    local backX = screenWidth // 2 + 80
    local retryWidth, retryHeight = gfx.drawText("Retry", retryX, optionY)
    local backWidth, backHeight = gfx.drawText("Back to title", backX, optionY)

    local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
    gfx.setColor(gfx.kColorBlack)
    if gs.gameoverSelection == 'retry' then
      gfx.fillRect(retryX, optionY + retryHeight + 4 + perlY, retryWidth, 2)
    else
      gfx.fillRect(backX, optionY + backHeight + 4 + perlY, backWidth, 2)
    end

    if pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
      if gs.gameoverSelection == 'retry' then
        gs.gameoverSelection = 'back'
      else
        gs.gameoverSelection = 'retry'
      end
      assets.sfx.boop:play()
    end

    if pd.buttonJustReleased(pd.kButtonA) then
      if gs.gameoverSelection == 'retry' then
        gs.scene = 'game'
      else
        gs.scene = 'title'
        resetMenu()
      end

      resetGameState()
      assets.sfx.boop:play(77)
    end
    gs.frameCount += 1
    return
  end

  if not pd.isCrankDocked() then
    gs.moon.pos = gs.earth.pos + pd.geometry.vector2D.newPolar(gs.moon.distanceFromEarth, pd.getCrankPosition())

    -- Animate bomb shockwave
    if gs.bombShockwave > 0 then
      gs.lastAsteroidAt = gs.frameCount
      gs.bombShockwave += 10
      for id, asteroid in pairs(gs.asteroids) do
        if asteroid.state == 'active' and areCirclesColliding(gs.bombShockwavePos, gs.bombShockwave, asteroid.pos, asteroid.radius) then
          spawnExplosion(asteroid.pos)
          assets.sfx.goodBoom:play()
          gs.asteroids[id] = nil
        end
      end
      if gs.bombShockwave > screenWidth then
        gs.bombShockwave = 0
        gs.asteroids = {}
      end
    end

    if gs.frameCount - gs.lastAsteroidAt >= (gs.difficulty == 'ramp-up' and gs.rampUpDifficulty or difficultyLevels[gs.difficulty]) then
      spawnAsteroid()
      gs.lastAsteroidAt = gs.frameCount
      if gs.difficulty == 'ramp-up' then
        updateRampUpDifficulty()
      end
    end

    if gs.frameCount == 2 then
      --spawnTarget(100, 30, 26)
      --spawnTarget(screenWidth - 30, 100, 20)
      --spawnTarget(35, 130, 22)
      --spawnTarget(280, screenHeight - 40, 18)
    end

    -- Update physics
    local idsToRemove = {}
    for id, asteroid in pairs(gs.asteroids) do
      local isOnScreen = isAsteroidOnScreen(asteroid)
      local earthVec = gs.earth.pos - asteroid.pos
      local acc = earthVec:scaledBy(gs.earth.mass / earthVec:magnitudeSquared())
      local moonVec = gs.moon.pos - asteroid.pos
      if isOnScreen and moonVec:magnitude() <= gs.moon.gravityRadius then
        local moonMass = gs.moon.mass
        if pd.buttonIsPressed(pd.kButtonA) then
          moonMass *= 2
        end
        acc += moonVec:scaledBy(moonMass / moonVec:magnitudeSquared())
      end
      asteroid.vel += acc
      asteroid.pos += asteroid.vel

      if asteroid.state == 'entering' and isOnScreen then
        asteroid.state = 'active'
      elseif asteroid.state == 'active' and not isOnScreen then
        table.insert(idsToRemove, id)
        gs.score += 1
        assets.sfx.point:play()
      end
    end
    for _, id in ipairs(idsToRemove) do
      gs.asteroids[id] = nil
    end

    -- Update rocket
    if gs.curRocket then
      if gs.curRocket.frame == 100 then
        -- Liftoff!
        gs.curRocket.acc = pd.geometry.vector2D.newPolar(0.005, gs.curRocket.info.angle)
      end
      if gs.frameCount % 2 == 0 then
        spawnParticle(gs.curRocket.pos,
          -gs.curRocket.vel + pd.geometry.vector2D.new(math.random() - 0.5, math.random() - 0.5), 5, 1, 2, 0.2)
      end
      gs.curRocket.vel += gs.curRocket.acc
      gs.curRocket.pos += gs.curRocket.vel

      gs.curRocket.frame += 1

      if not isRocketOnScreen(gs.curRocket) then
        gs.curRocket = nil
        gs.lastRocketAt = gs.frameCount
      elseif isRocketCollidingWithCircle(gs.curRocket, gs.moon.pos, gs.moon.radius) then
        local powerups = {}
        if gs.earth.health < gs.earth.maxHealth then
          table.insert(powerups, 'health')
          table.insert(powerups, 'health')
        end
        if gs.earth.bombs < gs.earth.maxBombs then
          table.insert(powerups, 'bomb')
        end
        if not gs.moon.hasShield then
          table.insert(powerups, 'moon-shield')
        end
        if not gs.earth.hasShield then
          table.insert(powerups, 'earth-shield')
        end
        if #powerups == 0 then
          table.insert(powerups, 'max-health')
        end

        local powerup = powerups[math.random(#powerups)]

        if powerup == 'health' then
          gs.earth.health += 1
          flashMessage('+1 Health!')
          assets.sfx.powerup:play()
        elseif powerup == 'max-health' then
          gs.earth.maxHealth += 1
          gs.earth.health = gs.earth.maxHealth
          flashMessage('+1 Max Health!')
          assets.sfx.powerup:play()
        elseif powerup == 'moon-shield' then
          gs.moon.hasShield = true
          flashMessage('You got a shield!')
          assets.sfx.shieldUp:play()
        elseif powerup == 'earth-shield' then
          gs.earth.hasShield = true
          flashMessage('Earth got a shield!')
          assets.sfx.shieldUp:play()
        elseif powerup == 'bomb' then
          gs.earth.bombs += 1
          flashMessage('+1 Bomb! (Ⓑ to use)')
          assets.sfx.powerup:play()
        end

        gs.curRocket = nil
        gs.lastRocketAt = gs.frameCount
      else
        for id, asteroid in pairs(gs.asteroids) do
          if asteroid.state == 'active' and isRocketCollidingWithCircle(gs.curRocket, asteroid.pos, asteroid.radius) then
            spawnExplosion(
              pd.geometry.lineSegment.new(
                asteroid.pos.x,
                asteroid.pos.y,
                gs.curRocket.pos.x,
                gs.curRocket.pos.y
              ):midPoint()
            )
            assets.sfx.goodBoom:play()
            gs.asteroids[id] = nil
            gs.curRocket = nil
            gs.lastRocketAt = gs.frameCount
            break
          end
        end
      end
    elseif ((gs.frameCount - gs.lastRocketAt) > 150 and math.random(500) == 1)
        or (gs.frameCount - gs.lastRocketAt) > 1000 -- every 3 + ~10 seconds, max 20 seconds
    then
      spawnRocket()
      flashMessage('Supplies incoming!')
    end

    -- Collisions
    idsToRemove = {}
    for id, asteroid in pairs(gs.asteroids) do
      if asteroid.state ~= 'active' then
        goto continue
      end

      if areCirclesColliding(asteroid.pos, asteroid.radius, gs.earth.pos, gs.earth.radius + (gs.earth.hasShield and 4 or 0)) then
        if gs.earth.hasShield then
          gs.earth.hasShield = false
          assets.sfx.shieldDown:play()
        else
          gs.earth.health -= 1
          spawnExplosion(asteroid.pos)
          screenShake(500, 5)
          assets.sfx.boom:play()
        end
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
      elseif areCirclesColliding(asteroid.pos, asteroid.radius, gs.moon.pos, gs.moon.radius + (gs.moon.hasShield and 3 or 0)) then
        if gs.moon.hasShield then
          gs.moon.hasShield = false
          assets.sfx.shieldDown:play()
        else
          gs.earth.health -= 1
          spawnExplosion(asteroid.pos)
          screenShake(500, 5)
          assets.sfx.boom:play()
        end
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
      else
        for targetId, target in pairs(gs.targets) do
          if areCirclesColliding(asteroid.pos, asteroid.radius, target.pos, target.radius) then
            table.insert(idsToRemove, id)
            asteroid.state = 'dead'
            target.health -= math.max(5, math.floor(asteroid.radius * asteroid.vel:magnitude()))
            assets.sfx.goodBoom:play()
            for i = 1, 32 do
              spawnParticle(asteroid.pos, pd.geometry.vector2D.newPolar(math.random() + 1, math.random() * 360),
                10, 2, 4, 0.2)
            end
            if target.health <= 0 then
              gs.targets[targetId] = nil
            end
            goto continue
          end
        end

        for id2, asteroid2 in pairs(gs.asteroids) do
          if id ~= id2 and asteroid2.state == 'active' and areCirclesColliding(asteroid.pos, asteroid.radius, asteroid2.pos, asteroid2.radius) then
            table.insert(idsToRemove, id)
            table.insert(idsToRemove, id2)
            asteroid.state = 'dead'
            asteroid2.state = 'dead'
            gs.score += 5
            flashMessage('2 asteroids collided! +5 points')
            spawnExplosion(
              pd.geometry.lineSegment.new(
                asteroid.pos.x,
                asteroid.pos.y,
                asteroid2.pos.x,
                asteroid2.pos.y
              ):midPoint()
            )
            assets.sfx.goodBoom:play()
            break
          end
        end
      end
      ::continue::
    end
    for _, id in ipairs(idsToRemove) do
      gs.asteroids[id] = nil
    end

    if pd.buttonJustPressed(pd.kButtonB) and gs.earth.bombs > 0 and gs.bombShockwave == 0 then
      gs.earth.bombs -= 1
      gs.bombShockwave = 1
      gs.bombShockwavePos = gs.moon.pos
      screenShake(500, 5)
    end

    -- Check for game over
    if gs.earth.health <= 0 then
      gs.scene = 'gameover'
      gs.frameCount = 0
      if gs.score > saveData.highScore then
        saveData.highScore = gs.score
        pd.datastore.write(saveData)
        gs.isHighScore = true
      end
    end

    gs.frameCount += 1
  end

  -- Update screen
  gfx.clear()

  -- Stars
  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star)
  end

  -- Earth
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.45, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos, gs.earth.radius)
  if gs.earth.hasShield then
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(gs.earth.pos, gs.earth.radius + 4)
  end

  -- Earth eyes
  local leftEye = pd.geometry.point.new(gs.earth.pos.x - 5, gs.earth.pos.y - 5)
  local rightEye = pd.geometry.point.new(gs.earth.pos.x + 5, gs.earth.pos.y - 5)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(leftEye, 4)
  gfx.fillCircleAtPoint(rightEye, 4)
  local lookAt = closestAsteroidDirection()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(leftEye + lookAt, 2)
  gfx.fillCircleAtPoint(rightEye + lookAt, 2)

  -- Rocket
  if gs.curRocket then
    gs.curRocket.info.image:drawAnchored(gs.curRocket.pos.x, gs.curRocket.pos.y, gs.curRocket.info.anchor.x,
      gs.curRocket.info.anchor.y, gs.curRocket.info.flip)
  end

  -- Moon
  gfx.setColor(gfx.kColorWhite)
  --gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.moon.pos, gs.moon.radius)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(3, 2), 3)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(-3, -1), 2)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(3, -3), 2)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(-4, 4), 2)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(-1, -5), 2)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(-5, 0), 2)
  if gs.moon.hasShield then
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(gs.moon.pos, gs.moon.radius + 3)
  end

  -- Targets
  for _, target in pairs(gs.targets) do
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.7, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos, target.radius)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos + pd.geometry.vector2D.new(-2, -2), target.radius - 2)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos + pd.geometry.vector2D.new(-4, -4), target.radius - 4)

    if target.health < 100 then
      gfx.setColor(gfx.kColorWhite)
      gfx.drawRoundRect(target.pos.x - 10, target.pos.y + target.radius + 4, 20, 4, 2)
      gfx.fillRoundRect(target.pos.x - 10, target.pos.y + target.radius + 4, target.health / 5, 4, 2)
    end
  end

  -- Particles
  local idsToRemove = {}
  for id, particle in pairs(gs.particles) do
    if math.random(1, 4) == 1 then
      gfx.setColor(gfx.kColorXOR)
    else
      gfx.setColor(gfx.kColorWhite)
    end
    gfx.setDitherPattern(particle.ditherAlpha, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(particle.pos, math.random(particle.minRadius, particle.maxRadius))
    if particle.ttl <= 0 then
      table.insert(idsToRemove, id)
    else
      particle.ttl -= 1
      particle.pos += particle.vel
    end
  end
  for _, id in ipairs(idsToRemove) do
    gs.particles[id] = nil
  end

  -- Asteroids
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  for _, asteroid in pairs(gs.asteroids) do
    if isAsteroidOnScreen(asteroid) then
      gfx.fillCircleAtPoint(asteroid.pos, asteroid.radius)
      if gs.frameCount % 2 == 0 or gs.frameCount % 3 == 0 then
        local velAngle = -asteroid.vel:angleBetween(pd.geometry.vector2D.new(0, -1))
        local minRadius, maxRadius = 1, 2
        if asteroid.radius > 6 then
          minRadius, maxRadius = 2, 5
        elseif asteroid.radius > 5 then
          minRadius, maxRadius = 2, 4
        elseif asteroid.radius > 4 then
          minRadius, maxRadius = 1, 4
        elseif asteroid.radius > 3 then
          minRadius, maxRadius = 1, 3
        end
        spawnParticle(
          asteroid.pos - pd.geometry.vector2D.newPolar(asteroid.radius, velAngle + math.random(-35, 35)),
          pd.geometry.vector2D.newPolar(math.random(1, asteroid.radius) / 10,
            -velAngle + math.random(-15, 15)),
          7,
          minRadius,
          maxRadius,
          0.5
        )
      end
    elseif (gs.frameCount // 10) % 3 ~= 0 then
      if asteroid.pos.y < 0 then
        assets.gfx.arrowUp:drawAnchored(clamp(asteroid.pos.x, sidebarWidth, screenWidth - 1), 0, 0.5, 0)
      elseif asteroid.pos.y >= screenHeight then
        assets.gfx.arrowUp:drawAnchored(clamp(asteroid.pos.x, sidebarWidth, screenWidth - 1), screenHeight - 1, 0.5, 1,
          gfx.kImageFlippedY)
      elseif asteroid.pos.x < sidebarWidth then
        assets.gfx.arrowRight:drawAnchored(sidebarWidth, clamp(asteroid.pos.y, 0, screenHeight - 1), 0, 0.5,
          gfx.kImageFlippedX)
      elseif asteroid.pos.x >= screenWidth then
        assets.gfx.arrowRight:drawAnchored(screenWidth - 1, clamp(asteroid.pos.y, 0, screenHeight - 1), 1, 0.5)
      end
    end
  end

  -- Explosions
  idsToRemove = {}
  for id, explosion in pairs(gs.explosions) do
    local animFrame = explosion.frame // 5 + 1
    if animFrame <= #assets.gfx.explosion then
      assets.gfx.explosion:getImage(animFrame):drawAnchored(explosion.pos.x, explosion.pos.y, 0.5, 0.5)
      explosion.frame += 1
    else
      table.insert(idsToRemove, id)
    end
  end
  for _, id in ipairs(idsToRemove) do
    gs.explosions[id] = nil
  end

  -- Bomb shockwave
  if gs.bombShockwave > 0 then
    for i, alpha in ipairs({ 0.8, 0.4, 0.1, 0.4, 0.8 }) do
      local radius = gs.bombShockwave - i * 4
      if radius > 0 then
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(alpha, gfx.image.kDitherTypeBayer8x8)
        gfx.drawCircleAtPoint(gs.bombShockwavePos, radius)
      end
    end
  end

  -- Sidebar
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(sidebarWidth - 8, 0, 8, screenHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(sidebarWidth - 8, 0, 8, screenHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0, 0, sidebarWidth - 4, screenHeight)
  gfx.setImageDrawMode(gfx.kDrawModeInverted)

  -- Hearts
  for i = 1, gs.earth.maxHealth do
    (gs.earth.health >= i and assets.gfx.heart or assets.gfx.heartEmpty):draw(8, 8 + (i - 1) * 15)
  end

  -- Bombs
  for i = 1, gs.earth.bombs do
    assets.gfx.bomb:draw(26, 8 + (i - 1) * 15)
  end
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  -- Time
  local totalSecondsElapsed = gs.frameCount // 50
  local minutesElapsed = totalSecondsElapsed // 60
  local secondsElapsed = totalSecondsElapsed % 60
  local timeElapsed = table.concat({ minutesElapsed, ":", secondsElapsed < 10 and "0" or "", secondsElapsed })
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.drawText(timeElapsed, 7, 180)
  gfx.drawText("TIME", 7, 190)

  -- Score
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.drawText("" .. gs.score, 7, 215)
  gfx.drawText("PTS", 7, 225)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  -- UI
  if pd.isCrankDocked() then
    pd.ui.crankIndicator:draw()
  end

  if gs.curMessage then
    if gs.frameCount - gs.curMessageAt > 100 then
      gs.curMessage = nil
    else
      gfx.setFont(assets.fonts.large)
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
      gfx.drawTextAligned(gs.curMessage, screenWidth // 2, screenHeight - 24, kTextAlignment.center)
      gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
  end

  --gfx.setFont(assets.fonts.small)
  --gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  --gfx.drawText('' .. gs.rampUpDifficulty, 5, screenHeight - 15)
  --gfx.setImageDrawMode(gfx.kDrawModeCopy)

  --pd.drawFPS(screenWidth - 20, screenHeight - 15)
end
