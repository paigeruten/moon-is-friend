import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

local pd = playdate
local gfx = pd.graphics
local screenWidth, screenHeight = pd.display.getSize()

math.randomseed(pd.getSecondsSinceEpoch())

local score = 0
local scene = 'title'
local reduceFlashing = pd.getReduceFlashing()

local earth = {
  pos = pd.geometry.point.new(screenWidth // 2, screenHeight // 2),
  radius = 12,
  mass = 0.6,
  health = 5,
  maxHealth = 5,
}

local moonDistanceFromEarth = 60
local moon = {
  pos = pd.geometry.point.new(earth.pos.x, earth.pos.y - moonDistanceFromEarth),
  distanceFromEarth = moonDistanceFromEarth,
  radius = 6,
  gravityRadius = 50,
  mass = 2,
}

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

local function isAsteroidOnScreen(asteroid)
  local x, y, r = asteroid.pos.x, asteroid.pos.y, asteroid.radius
  return x + r >= 0 and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

local function areCirclesColliding(centerA, radiusA, centerB, radiusB)
  local distance = (centerB - centerA):magnitude()
  return distance <= radiusA + radiusB
end

local stars = {}
for _ = 1, 100 do
  table.insert(stars, pd.geometry.point.new(math.random() * screenWidth, math.random() * screenHeight))
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

-- From 8x8.me
local heartOutline <const> = {
  0x00, --  ▓▓▓▓▓▓▓▓
  0x6C, --  ▓░░▓░░▓▓
  0x92, --  ░▓▓░▓▓░▓
  0x82, --  ░▓▓▓▓▓░▓
  0x44, --  ▓░▓▓▓░▓▓
  0x28, --  ▓▓░▓░▓▓▓
  0x10, --  ▓▓▓░▓▓▓▓
  0x00, --  ▓▓▓▓▓▓▓▓
}
local heartSolid <const> = {
  0x00, --  ▓▓▓▓▓▓▓▓
  0x6C, --  ▓░░▓░░▓▓
  0xFE, --  ░░░░░░░▓
  0xFE, --  ░░░░░░░▓
  0x7C, --  ▓░░░░░▓▓
  0x38, --  ▓▓░░░▓▓▓
  0x10, --  ▓▓▓░▓▓▓▓
  0x00, --  ▓▓▓▓▓▓▓▓
}

pd.display.setRefreshRate(50)
gfx.setBackgroundColor(gfx.kColorBlack)

local frameCount = 0
function pd.update()
  pd.timer.updateTimers()

  if scene == 'title' then
    gfx.clear()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("Press A to start", screenWidth // 2, screenHeight // 2, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    if pd.buttonJustReleased(pd.kButtonA) then
      scene = 'game'
    end
    return
  elseif scene == 'gameover' then
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("Game Over", screenWidth // 2, screenHeight - screenHeight // 3, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    if pd.buttonJustReleased(pd.kButtonA) then
      scene = 'game'
      frameCount = 0
      score = 0
      asteroids = {}
      earth.maxHealth = 5
      earth.health = earth.maxHealth
    end
    return
  end

  if frameCount % 100 == 0 then -- 2 seconds
    spawnAsteroid()
  end

  -- Handle input
  if not pd.isCrankDocked() then
    moon.pos = earth.pos + pd.geometry.vector2D.newPolar(moon.distanceFromEarth, pd.getCrankPosition())
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
    end
  end
  for _, id in ipairs(idsToRemove) do
    asteroids[id] = nil
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
      screenShake(500, 5)
    elseif areCirclesColliding(asteroid.pos, asteroid.radius, moon.pos, moon.radius) then
      earth.health -= 1
      table.insert(idsToRemove, id)
      asteroid.state = 'dead'
      screenShake(500, 5)
    else
      for id2, asteroid2 in pairs(asteroids) do
        if id ~= id2 and asteroid2.state == 'active' and areCirclesColliding(asteroid.pos, asteroid.radius, asteroid2.pos, asteroid2.radius) then
          table.insert(idsToRemove, id)
          table.insert(idsToRemove, id2)
          asteroid.state = 'dead'
          asteroid2.state = 'dead'
          break
        end
      end
    end
    ::continue::
  end
  for _, id in ipairs(idsToRemove) do
    asteroids[id] = nil
  end

  -- Check for game over
  if earth.health <= 0 then
    scene = 'gameover'
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

  -- Moon
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moon.pos, moon.radius)

  -- Asteroids
  gfx.setColor(gfx.kColorXOR)
  for _, asteroid in pairs(asteroids) do
    if isAsteroidOnScreen(asteroid) then
      gfx.fillCircleAtPoint(asteroid.pos, asteroid.radius)
    end
  end

  -- Hearts
  for i = 1, earth.maxHealth do
    gfx.setPattern(earth.health >= i and heartSolid or heartOutline)
    gfx.fillRect(0, (i - 1) * 8, 8, 8)
  end

  -- UI
  if pd.isCrankDocked() then
    pd.ui.crankIndicator:draw()
  end

  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawTextAligned("Score: " .. score, screenWidth - 10, 10, kTextAlignment.right)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  pd.drawFPS(5, screenHeight - 15)

  frameCount += 1
end
