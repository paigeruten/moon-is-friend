import "CoreLibs/easing"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "vendor/pdfxr"

local pd = playdate
local gfx = pd.graphics
local screenWidth, screenHeight = pd.display.getSize()

math.randomseed(pd.getSecondsSinceEpoch())

local saveData = pd.datastore.read() or { highScore = 0 }

local MOON_DISTANCE_FROM_EARTH = 60
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
    pos = pd.geometry.point.new(screenWidth // 2, screenHeight // 2),
    radius = 12,
    mass = 0.6,
    health = 5,
    maxHealth = 5,
    bombs = 0,
  }

  gs.moon = {
    pos = pd.geometry.point.new(gs.earth.pos.x, gs.earth.pos.y - MOON_DISTANCE_FROM_EARTH),
    distanceFromEarth = MOON_DISTANCE_FROM_EARTH,
    radius = 6,
    gravityRadius = 50,
    mass = 1.75,
    hasShield = false,
  }

  gs.curRocket = nil
  gs.lastRocketAt = 0

  gs.explosions = {}
  gs.curExplosionId = 0

  gs.asteroids = {}
  gs.curAsteroidId = 0
  gs.lastAsteroidAt = 0

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
    star = gfx.image.new("images/star")
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
    dir = -1,
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
  gs.asteroids[id] = {
    id = id,
    pos = pos,
    vel = -pd.geometry.vector2D.newPolar(
      (math.random() / 2) + 0.5,        -- magnitude between 0.5 and 1.0
      angle + (math.random() * 20 - 10) -- vary angle from -10 to +10
    ),
    radius = math.random(2, 4),
    state = 'entering',
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
  return x + r >= 0 and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

local function isRocketOnScreen(rocket)
  local x, y, r = rocket.pos.x, rocket.pos.y, 3
  return x + r >= 0 and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
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

    local gameoverBoxHeight = pd.easingFunctions.outExpo(gs.frameCount, 0, 28, 50)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, screenHeight - gameoverBoxHeight, screenWidth, gameoverBoxHeight)
    gfx.setFont(assets.fonts.large)
    gfx.drawText("Game Over", 20, screenHeight - gameoverBoxHeight + 5)

    gfx.setFont(assets.fonts.small)
    local optionY = screenHeight - gameoverBoxHeight + 11
    local retryX = screenWidth // 2 - 32
    local backX = screenWidth // 2 + 64
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

    if gs.frameCount - gs.lastAsteroidAt >= (gs.difficulty == 'ramp-up' and gs.rampUpDifficulty or difficultyLevels[gs.difficulty]) then
      spawnAsteroid()
      gs.lastAsteroidAt = gs.frameCount
      if gs.difficulty == 'ramp-up' then
        updateRampUpDifficulty()
      end
    end

    -- Update physics
    local idsToRemove = {}
    for id, asteroid in pairs(gs.asteroids) do
      local earthVec = gs.earth.pos - asteroid.pos
      local acc = earthVec:scaledBy(gs.earth.mass / earthVec:magnitudeSquared())
      local moonVec = gs.moon.pos - asteroid.pos
      if moonVec:magnitude() <= gs.moon.gravityRadius then
        acc += moonVec:scaledBy(gs.moon.mass / moonVec:magnitudeSquared())
      end
      asteroid.vel += acc
      asteroid.pos += asteroid.vel

      if asteroid.state == 'entering' and isAsteroidOnScreen(asteroid) then
        asteroid.state = 'active'
      elseif asteroid.state == 'active' and not isAsteroidOnScreen(asteroid) then
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
      gs.curRocket.vel += gs.curRocket.acc
      gs.curRocket.pos += gs.curRocket.vel

      gs.curRocket.frame += 1

      if not isRocketOnScreen(gs.curRocket) then
        gs.curRocket = nil
        gs.lastRocketAt = gs.frameCount
      elseif isRocketCollidingWithCircle(gs.curRocket, gs.moon.pos, gs.moon.radius) then
        local powerups = { 'bomb' }
        if gs.earth.health < gs.earth.maxHealth then
          table.insert(powerups, 'health')
        end
        if not gs.moon.hasShield then
          table.insert(powerups, 'shield')
        end

        local powerup = powerups[math.random(#powerups)]

        if powerup == 'health' then
          gs.earth.health += 1
          flashMessage('+1 Health!')
          assets.sfx.powerup:play()
        elseif powerup == 'shield' then
          gs.moon.hasShield = true
          flashMessage('You got a shield!')
          assets.sfx.shieldUp:play()
        elseif powerup == 'bomb' then
          gs.earth.bombs += 1
          flashMessage('+1 Bomb! (Ⓑ to use)')
          assets.sfx.powerup:play()
        end

        gs.curRocket = nil
        gs.lastRocketAt = gs.frameCount
      end
    elseif (gs.frameCount - gs.lastRocketAt) > 150 and math.random(500) == 1 then -- every 3 + ~10 seconds
      spawnRocket()
      flashMessage('Supplies incoming!')
    end

    -- Collisions
    idsToRemove = {}
    for id, asteroid in pairs(gs.asteroids) do
      if asteroid.state ~= 'active' then
        goto continue
      end

      if areCirclesColliding(asteroid.pos, asteroid.radius, gs.earth.pos, gs.earth.radius) then
        gs.earth.health -= 1
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
        spawnExplosion(asteroid.pos)
        screenShake(500, 5)
        assets.sfx.boom:play()
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

    if pd.buttonJustPressed(pd.kButtonB) and gs.earth.bombs > 0 then
      gs.earth.bombs -= 1
      for _, asteroid in pairs(gs.asteroids) do
        if isAsteroidOnScreen(asteroid) then
          spawnExplosion(asteroid.pos)
        end
      end
      assets.sfx.goodBoom:play()
      screenShake(500, 5)
      gs.asteroids = {}
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

  -- Earth eyes
  local leftEye = pd.geometry.point.new(gs.earth.pos.x - 4, gs.earth.pos.y - 4)
  local rightEye = pd.geometry.point.new(gs.earth.pos.x + 4, gs.earth.pos.y - 4)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(leftEye, 3)
  gfx.fillCircleAtPoint(rightEye, 3)
  local lookAt = closestAsteroidDirection()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(leftEye + lookAt, 1)
  gfx.fillCircleAtPoint(rightEye + lookAt, 1)

  -- Rocket
  if gs.curRocket then
    if gs.curRocket.frame >= 100 or (gs.curRocket.frame // 5) % 2 == 0 then
      gs.curRocket.info.image:drawAnchored(gs.curRocket.pos.x, gs.curRocket.pos.y, gs.curRocket.info.anchor.x,
        gs.curRocket.info.anchor.y, gs.curRocket.info.flip)
    end
  end

  -- Moon
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.moon.pos, gs.moon.radius)
  if gs.moon.hasShield then
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(gs.moon.pos, gs.moon.radius + 3)
  end

  -- Asteroids
  gfx.setColor(gfx.kColorXOR)
  for _, asteroid in pairs(gs.asteroids) do
    if isAsteroidOnScreen(asteroid) then
      gfx.fillCircleAtPoint(asteroid.pos, asteroid.radius)
    end
  end

  -- Explosions
  local idsToRemove = {}
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

  -- Hearts
  for i = 1, gs.earth.maxHealth do
    (gs.earth.health >= i and assets.gfx.heart or assets.gfx.heartEmpty):draw(4, 4 + (i - 1) * 15)
  end

  -- Bombs
  for i = 1, gs.earth.bombs do
    assets.gfx.bomb:draw(20, 4 + (i - 1) * 15)
  end

  -- UI
  if pd.isCrankDocked() then
    pd.ui.crankIndicator:draw()
  end

  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawTextAligned("Score " .. gs.score .. (gs.score >= STAR_SCORE and "  " or ""), screenWidth - 10, 10,
    kTextAlignment.right)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  if gs.score >= STAR_SCORE then
    assets.gfx.star:draw(screenWidth - 19, 7)
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

  --pd.drawFPS(5, screenHeight - 15)
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawText('' .. gs.rampUpDifficulty, 5, screenHeight - 15)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)
end
