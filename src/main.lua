import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "vendor/pdfxr"

local pd = playdate
local gfx = pd.graphics
local screenWidth, screenHeight = pd.display.getSize()

math.randomseed(pd.getSecondsSinceEpoch())

local frameCount = 0
local score = 0
local scene = 'title'
local reduceFlashing = pd.getReduceFlashing()

local largeFont = gfx.getSystemFont()
local smallFont = gfx.font.new("fonts/font-rains-1x")

local boomSound = pdfxr.synth.new("sounds/boom")
local goodBoomSound = pdfxr.synth.new("sounds/good-boom")
local pointSound = pdfxr.synth.new("sounds/point")
local powerupSound = pdfxr.synth.new("sounds/powerup")
local shieldDownSound = pdfxr.synth.new("sounds/shield-down")
local shieldUpSound = pdfxr.synth.new("sounds/shield-up")

local earth = {
  pos = pd.geometry.point.new(screenWidth // 2, screenHeight // 2),
  radius = 12,
  mass = 0.6,
  health = 5,
  maxHealth = 5,
  bombs = 0,
}

local moonDistanceFromEarth = 60
local moon = {
  pos = pd.geometry.point.new(earth.pos.x, earth.pos.y - moonDistanceFromEarth),
  distanceFromEarth = moonDistanceFromEarth,
  radius = 6,
  gravityRadius = 50,
  mass = 1.75,
  hasShield = false,
}

local rocketNorthImage = gfx.image.new("images/rocket-orth")
local rocketEastImage = rocketNorthImage:rotatedImage(90)
local rocketNorthEastImage = gfx.image.new("images/rocket-diag")

local rocketDirectionInfo = {
  north = {
    image = rocketNorthImage,
    angle = 0,
    anchor = { x = 0.5, y = 1 },
    flip = gfx.kImageUnflipped,
  },
  northeast = {
    image = rocketNorthEastImage,
    angle = 45,
    anchor = { x = 0, y = 1 },
    flip = gfx.kImageUnflipped,
  },
  east = {
    image = rocketEastImage,
    angle = 90,
    anchor = { x = 0, y = 0.5 },
    flip = gfx.kImageUnflipped,
  },
  southeast = {
    image = rocketNorthEastImage,
    angle = 135,
    anchor = { x = 0, y = 0 },
    flip = gfx.kImageFlippedY,
  },
  south = {
    image = rocketNorthImage,
    angle = 180,
    anchor = { x = 0.5, y = 0 },
    flip = gfx.kImageFlippedY,
  },
  southwest = {
    image = rocketNorthEastImage,
    angle = 225,
    anchor = { x = 1, y = 0 },
    flip = gfx.kImageFlippedXY,
  },
  west = {
    image = rocketEastImage,
    angle = 270,
    anchor = { x = 1, y = 0.5 },
    flip = gfx.kImageFlippedX,
  },
  northwest = {
    image = rocketNorthEastImage,
    angle = 315,
    anchor = { x = 1, y = 1 },
    flip = gfx.kImageFlippedX,
  },
}
local rocketDirections = {}
for direction, _ in pairs(rocketDirectionInfo) do
  table.insert(rocketDirections, direction)
end

local curRocket = nil
local lastRocketAt = 0

local function spawnRocket()
  local direction = rocketDirections[math.random(#rocketDirections)]
  local directionInfo = rocketDirectionInfo[direction]
  local pos = earth.pos + pd.geometry.vector2D.newPolar(earth.radius + 1, directionInfo.angle)
  curRocket = {
    frame = 0,
    pos = pos,
    vel = pd.geometry.vector2D.new(0, 0),
    acc = pd.geometry.vector2D.new(0, 0),
    direction = direction,
    info = directionInfo
  }
end

local explosionImageTable = gfx.imagetable.new("images/explosion")
local explosions = {}
local curExplosionId = 0

local function spawnExplosion(pos)
  curExplosionId += 1
  local id = curExplosionId
  explosions[id] = {
    pos = pos,
    frame = 0,
    dir = -1,
  }
end

local asteroids = {}
local curAsteroidId = 0
local function nextAsteroidId()
  curAsteroidId += 1
  return curAsteroidId
end

local function spawnAsteroid()
  local id = nextAsteroidId()
  local angle = math.random() * 360
  local pos = earth.pos + pd.geometry.vector2D.newPolar(250, angle)
  asteroids[id] = {
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
  for _, asteroid in pairs(asteroids) do
    local earthVec = asteroid.pos - earth.pos
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

local stars = {}
local function regenerateStars()
  stars = {}
  for _ = 1, 100 do
    table.insert(stars, pd.geometry.point.new(math.random() * screenWidth, math.random() * screenHeight))
  end
end
regenerateStars()

local curMessage = nil
local curMessageAt = nil

local function flashMessage(message)
  curMessage = message
  curMessageAt = frameCount
end

local function screenShake(shakeTime, shakeMagnitude)
  if reduceFlashing then
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

local heartImage = gfx.image.new("images/heart")
local heartEmptyImage = gfx.image.new("images/empty-heart")
local bombImage = gfx.image.new("images/bomb")

pd.display.setRefreshRate(50)
gfx.setBackgroundColor(gfx.kColorBlack)

function pd.update()
  pd.timer.updateTimers()

  if scene == 'title' then
    gfx.clear()

    gfx.setColor(gfx.kColorWhite)
    for _, star in ipairs(stars) do
      gfx.drawPixel(star)
    end

    local animFrame = math.min(frameCount, 700)

    -- Earth
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.45, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(screenWidth - 60, screenHeight // 4, 20)

    -- Moon
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(screenWidth / 3 + animFrame / 10, screenHeight * 2 / 3 - animFrame / 20, screenWidth / 3)

    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(screenWidth // 4, screenHeight // 2 - 12, screenWidth // 2, 24, 5)

    gfx.setFont(largeFont)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("The Moon is our Friend", screenWidth // 2, screenHeight // 2 - 9, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(screenWidth // 2 - 70, screenHeight - screenHeight // 4 - 5, 140, 17, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(screenWidth // 2 - 70, screenHeight - screenHeight // 4 - 5, 140, 17, 5)

    gfx.setFont(smallFont)
    gfx.drawTextAligned("Press A to start", screenWidth // 2, screenHeight - screenHeight // 4, kTextAlignment.center)

    frameCount += 1

    if pd.buttonJustReleased(pd.kButtonA) then
      scene = 'story'
      frameCount = 0
    end
    return
  elseif scene == 'story' or scene == 'instructions' then
    gfx.clear()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(0, 0, screenWidth, screenHeight, 15)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(1, 1, screenWidth - 2, screenHeight - 2, 15)

    local text
    local paddingX, paddingY = 10, 10
    local title = nil
    if scene == 'story' then
      title = "2038: The Moon Wakes Up"
      paddingY = 50
      text = {
        "After a large-scale asteroid mining expedition\ngone wrong, "
        .. "the Earth is now under a barrage of\nasteroids and is very scared.",
        "Desparate to help its best friend, "
        .. "the Moon has\nwoken up from its deep slumber "
        .. "and is free to\nmove around in its orbit "
        .. "to deflect the incoming\nasteroids with its gravitational pull." }
    else
      text = {
        "Control the Moon with the crank "
        .. "to pull incoming\nasteroids away from the Earth, "
        .. "but don't let the\nasteroids hit the Moon either. "
        .. "Bonus points for\ngetting two asteroids to collide with each other!",
        "Sometimes Earth will send up a rocket full of\nsupplies - "
        .. "make sure to catch it as it zooms by! "
        .. "It\ncould contain extra health, a shield, or give you\nspecial abilities.",
        "The game has no end, but if you can get 100\npoints you'll get a gold star on the title screen!"
      }
    end

    local maxChars = math.floor(frameCount * 1.5)

    gfx.setFont(largeFont)

    if title then
      gfx.drawTextAligned('*' .. title .. '*', screenWidth // 2, 16, kTextAlignment.center)
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

    local perlY = math.min(3, math.max(-3, gfx.perlin(0, (frameCount % 100) / 100, 0, 0) * 20 - 10))
    gfx.drawText("Ⓐ", screenWidth - 28, screenHeight - 28 + perlY)

    frameCount += 1

    if pd.buttonJustReleased(pd.kButtonA) then
      if not done then
        frameCount = 1000000
      elseif scene == 'story' then
        scene = 'instructions'
        frameCount = 0
      else
        scene = 'game'
        frameCount = 0
      end
    end
    return
  elseif scene == 'gameover' then
    if pd.buttonJustReleased(pd.kButtonA) then
      scene = 'game'
      frameCount = 0
      score = 0
      asteroids = {}
      earth.maxHealth = 5
      earth.health = earth.maxHealth
      earth.bombs = 0
      moon.hasShield = false
      curRocket = nil
      lastRocketAt = 0
      curMessage = nil
      explosions = {}
      regenerateStars()
    end
    return
  end

  if not pd.isCrankDocked() then
    moon.pos = earth.pos + pd.geometry.vector2D.newPolar(moon.distanceFromEarth, pd.getCrankPosition())

    if frameCount % 100 == 0 then -- 2 seconds
      spawnAsteroid()
    end

    -- Update physics
    local idsToRemove = {}
    for id, asteroid in pairs(asteroids) do
      local earthVec = earth.pos - asteroid.pos
      local acc = earthVec:scaledBy(earth.mass / earthVec:magnitudeSquared())
      local moonVec = moon.pos - asteroid.pos
      if moonVec:magnitude() <= moon.gravityRadius then
        acc += moonVec:scaledBy(moon.mass / moonVec:magnitudeSquared())
      end
      asteroid.vel += acc
      asteroid.pos += asteroid.vel

      if asteroid.state == 'entering' and isAsteroidOnScreen(asteroid) then
        asteroid.state = 'active'
      elseif asteroid.state == 'active' and not isAsteroidOnScreen(asteroid) then
        table.insert(idsToRemove, id)
        score += 1
        pointSound:play()
      end
    end
    for _, id in ipairs(idsToRemove) do
      asteroids[id] = nil
    end

    -- Update rocket
    if curRocket then
      if curRocket.frame == 100 then
        -- Liftoff!
        curRocket.acc = pd.geometry.vector2D.newPolar(0.005, curRocket.info.angle)
      end
      curRocket.vel += curRocket.acc
      curRocket.pos += curRocket.vel

      curRocket.frame += 1

      if not isRocketOnScreen(curRocket) then
        curRocket = nil
        lastRocketAt = frameCount
      elseif isRocketCollidingWithCircle(curRocket, moon.pos, moon.radius) then
        local powerups = { 'bomb' }
        if earth.health <= earth.maxHealth then
          table.insert(powerups, 'health')
        end
        if not moon.hasShield then
          table.insert(powerups, 'shield')
        end

        local powerup = powerups[math.random(#powerups)]

        if powerup == 'health' then
          earth.health += 1
          flashMessage('+1 Health!')
          powerupSound:play()
        elseif powerup == 'shield' then
          moon.hasShield = true
          flashMessage('You got a shield!')
          shieldUpSound:play()
        elseif powerup == 'bomb' then
          earth.bombs += 1
          flashMessage('+1 Bomb! (Ⓑ to use)')
          powerupSound:play()
        end

        curRocket = nil
        lastRocketAt = frameCount
      end
    elseif (frameCount - lastRocketAt) > 150 and math.random(500) == 1 then -- every 3 + ~10 seconds
      spawnRocket()
      flashMessage('Supplies incoming!')
    end

    -- Collisions
    idsToRemove = {}
    for id, asteroid in pairs(asteroids) do
      if asteroid.state ~= 'active' then
        goto continue
      end

      if areCirclesColliding(asteroid.pos, asteroid.radius, earth.pos, earth.radius) then
        earth.health -= 1
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
        spawnExplosion(asteroid.pos)
        screenShake(500, 5)
        boomSound:play()
      elseif areCirclesColliding(asteroid.pos, asteroid.radius, moon.pos, moon.radius + (moon.hasShield and 3 or 0)) then
        if moon.hasShield then
          moon.hasShield = false
          shieldDownSound:play()
        else
          earth.health -= 1
          spawnExplosion(asteroid.pos)
          screenShake(500, 5)
          boomSound:play()
        end
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
      else
        for id2, asteroid2 in pairs(asteroids) do
          if id ~= id2 and asteroid2.state == 'active' and areCirclesColliding(asteroid.pos, asteroid.radius, asteroid2.pos, asteroid2.radius) then
            table.insert(idsToRemove, id)
            table.insert(idsToRemove, id2)
            asteroid.state = 'dead'
            asteroid2.state = 'dead'
            score += 5
            flashMessage('2 asteroids collided! +5 points')
            spawnExplosion(
              pd.geometry.lineSegment.new(
                asteroid.pos.x,
                asteroid.pos.y,
                asteroid2.pos.x,
                asteroid2.pos.y
              ):midPoint()
            )
            goodBoomSound:play()
            break
          end
        end
      end
      ::continue::
    end
    for _, id in ipairs(idsToRemove) do
      asteroids[id] = nil
    end

    if pd.buttonJustPressed(pd.kButtonB) and earth.bombs > 0 then
      earth.bombs -= 1
      for _, asteroid in pairs(asteroids) do
        if isAsteroidOnScreen(asteroid) then
          spawnExplosion(asteroid.pos)
        end
      end
      goodBoomSound:play()
      screenShake(500, 5)
      asteroids = {}
    end

    -- Check for game over
    if earth.health <= 0 then
      scene = 'gameover'
      flashMessage('Game Over')
    end

    frameCount += 1
  end

  -- Update screen
  gfx.clear()

  -- Stars
  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(stars) do
    gfx.drawPixel(star)
  end

  -- Earth
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.45, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earth.pos, earth.radius)

  -- Earth eyes
  local leftEye = pd.geometry.point.new(earth.pos.x - 4, earth.pos.y - 4)
  local rightEye = pd.geometry.point.new(earth.pos.x + 4, earth.pos.y - 4)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(leftEye, 3)
  gfx.fillCircleAtPoint(rightEye, 3)
  local lookAt = closestAsteroidDirection()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(leftEye + lookAt, 1)
  gfx.fillCircleAtPoint(rightEye + lookAt, 1)

  -- Rocket
  if curRocket then
    if curRocket.frame >= 100 or (curRocket.frame // 5) % 2 == 0 then
      curRocket.info.image:drawAnchored(curRocket.pos.x, curRocket.pos.y, curRocket.info.anchor.x,
        curRocket.info.anchor.y, curRocket.info.flip)
    end
  end

  -- Moon
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moon.pos, moon.radius)
  if moon.hasShield then
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(moon.pos, moon.radius + 3)
  end

  -- Asteroids
  gfx.setColor(gfx.kColorXOR)
  for _, asteroid in pairs(asteroids) do
    if isAsteroidOnScreen(asteroid) then
      gfx.fillCircleAtPoint(asteroid.pos, asteroid.radius)
    end
  end

  -- Explosions
  local idsToRemove = {}
  for id, explosion in pairs(explosions) do
    local animFrame = explosion.frame // 5 + 1
    if animFrame <= #explosionImageTable then
      explosionImageTable:getImage(animFrame):drawAnchored(explosion.pos.x, explosion.pos.y, 0.5, 0.5)
      explosion.frame += 1
    else
      table.insert(idsToRemove, id)
    end
  end
  for _, id in ipairs(idsToRemove) do
    explosions[id] = nil
  end

  -- Hearts
  for i = 1, earth.maxHealth do
    (earth.health >= i and heartImage or heartEmptyImage):draw(4, 4 + (i - 1) * 15)
  end

  -- Bombs
  for i = 1, earth.bombs do
    bombImage:draw(20, 4 + (i - 1) * 15)
  end

  -- UI
  if pd.isCrankDocked() then
    pd.ui.crankIndicator:draw()
  end

  gfx.setFont(smallFont)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawTextAligned("Score " .. score, screenWidth - 10, 10, kTextAlignment.right)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  if curMessage then
    if frameCount - curMessageAt > 100 then
      curMessage = nil
    else
      gfx.setFont(largeFont)
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
      gfx.drawTextAligned(curMessage, screenWidth // 2, screenHeight - 24, kTextAlignment.center)
      gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
  end

  --pd.drawFPS(5, screenHeight - 15)
end
