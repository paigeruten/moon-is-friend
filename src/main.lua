import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/ui"

local pd = playdate
local gfx = pd.graphics
local screenWidth, screenHeight = pd.display.getSize()

math.randomseed(pd.getSecondsSinceEpoch())

local score = 0

local earth = {
  pos = pd.geometry.point.new(screenWidth // 2, screenHeight // 2),
  radius = 12,
  mass = 0.5,
}

local moonDistanceFromEarth = 60
local moon = {
  pos = pd.geometry.point.new(earth.pos.x, earth.pos.y - moonDistanceFromEarth),
  distanceFromEarth = moonDistanceFromEarth,
  radius = 6,
  gravityRadius = 50,
  mass = 3,
}

local asteroids = {}
local curAsteroidId = 0
local function nextAsteroidId()
  curAsteroidId += 1
  return curAsteroidId
end

local function spawnAsteroid()
  local id = nextAsteroidId()
  local pos = earth.pos + pd.geometry.vector2D.newPolar(250, math.random() * 360)
  asteroids[id] = {
    id = id,
    pos = pos,
    vel = (earth.pos - pos):normalized():scaledBy(1),
    radius = 3,
    state = 'entering',
  }
  return id
end

local function isAsteroidOnScreen(asteroid)
  local x, y, r = asteroid.pos.x, asteroid.pos.y, asteroid.radius
  return x + r >= 0 and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

gfx.setBackgroundColor(gfx.kColorBlack)

local frameCount = 0
function pd.update()
  if frameCount % 150 == 0 then -- 5 seconds
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

  -- Update screen
  gfx.clear()

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
    gfx.fillCircleAtPoint(asteroid.pos, asteroid.radius)
  end

  -- UI
  if pd.isCrankDocked() then
    pd.ui.crankIndicator:draw()
  end

  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawTextAligned("Score: " .. score, screenWidth - 10, 10, kTextAlignment.right)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  frameCount += 1
end
