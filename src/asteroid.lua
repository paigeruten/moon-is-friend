local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

local polarCoordinates = Util.polarCoordinates
local angleFromVec = Util.angleFromVec

Asteroid = {}

local function nextAsteroidId()
  gs.curAsteroidId += 1
  return gs.curAsteroidId
end

function Asteroid.spawn()
  local id = nextAsteroidId()
  local angle
  if gs.mission.winType == "boss" then
    local whichSide = math.random()
    if whichSide < 0.1 then
      -- top
      angle = math.random(316, 390)
      if angle >= 360 then
        angle -= 360
      end
    elseif whichSide < 0.2 then
      -- bottom
      angle = math.random(150, 224)
    else
      -- left
      angle = math.random(225, 315)
    end
  else
    angle = math.random() * 360
  end
  local posX, posY = polarCoordinates(250, angle)
  posX += gs.earth.pos.x
  posY += gs.earth.pos.y
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
  if posX < 0 or posX >= screenWidth then
    speed = math.random(5, 14) / 10
  else
    speed = math.random(5, 9) / 10
  end
  local velX, velY = polarCoordinates(speed, angle + (math.random() * 40 - 20))
  gs.asteroids[id] = {
    id = id,
    pos = { x = posX, y = posY },
    vel = { x = -velX, y = -velY },
    radius = asteroidRadius,
    state = 'entering',
  }
  gs.numAsteroids += 1
  return id
end

function Asteroid.despawn(id)
  gs.asteroids[id] = nil
  gs.numAsteroids -= 1

  if gs.mission.mode == 'juggling' then
    gs.lastAsteroidAt = gs.frameCount
  end
end

function Asteroid.closestAsteroidDirection()
  local dirX, dirY = 0, 0
  local minDistance = nil
  for _, asteroid in pairs(gs.asteroids) do
    local earthVecX, earthVecY = asteroid.pos.x - gs.earth.pos.x, asteroid.pos.y - gs.earth.pos.y
    local distanceSquared = earthVecX * earthVecX + earthVecY * earthVecY
    if minDistance == nil or distanceSquared < minDistance then
      minDistance = distanceSquared
      local distance = math.sqrt(distanceSquared)
      dirX, dirY = earthVecX / distance, earthVecY / distance
    end
  end
  return dirX, dirY
end

function Asteroid.isOnScreen(asteroid)
  local x, y, r = asteroid.pos.x, asteroid.pos.y, asteroid.radius
  return x + r >= sidebarWidth and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

local isAsteroidOnScreen = Asteroid.isOnScreen

function Asteroid.areCirclesColliding(centerA, radiusA, centerB, radiusB)
  local dx, dy = centerB.x - centerA.x, centerB.y - centerA.y
  local distance = math.sqrt(dx * dx + dy * dy)
  return distance <= radiusA + radiusB
end

local areCirclesColliding = Asteroid.areCirclesColliding

local function clamp(value, low, high)
  return math.min(high, math.max(low, value))
end

function Asteroid.update()
  if gs.mission.mode == 'standard' then
    if gs.frameCount - gs.lastAsteroidAt >= (gs.rampUpDifficulty or gs.mission.difficulty) then
      Asteroid.spawn()
      gs.lastAsteroidAt = gs.frameCount
      if gs.rampUpDifficulty then
        Game.updateRampUpDifficulty()
      end
    end
  elseif gs.mission.mode == 'juggling' then
    if gs.numAsteroids < gs.mission.difficulty and gs.frameCount - gs.lastAsteroidAt >= 100 then
      Asteroid.spawn()
      gs.lastAsteroidAt = gs.frameCount
    end
  end

  local idsToRemove = {}
  for id, asteroid in pairs(gs.asteroids) do
    local isOnScreen = isAsteroidOnScreen(asteroid)
    local earthVecX, earthVecY = gs.earth.pos.x - asteroid.pos.x, gs.earth.pos.y - asteroid.pos.y
    local earthMass = gs.earth.mass
    local earthDistanceSquared = earthVecX * earthVecX + earthVecY * earthVecY
    local accX = earthVecX * (earthMass / earthDistanceSquared)
    local accY = earthVecY * (earthMass / earthDistanceSquared)
    for _, moon in ipairs(gs.moons) do
      local moonVecX, moonVecY = moon.pos.x - asteroid.pos.x, moon.pos.y - asteroid.pos.y
      local moonDistanceSquared = moonVecX * moonVecX + moonVecY * moonVecY
      local moonDistance = math.sqrt(moonDistanceSquared)
      if isOnScreen and moonDistance <= moon.gravityRadius then
        local moonMass = moon.mass
        if gs.extraSuction then
          moonMass *= 2
        end
        accX += moonVecX * (moonMass / moonDistanceSquared)
        accY += moonVecY * (moonMass / moonDistanceSquared)
      end
    end
    if gs.mission.mode == 'juggling' then
      if (asteroid.pos.x < sidebarWidth + asteroid.radius and asteroid.vel.x < 0) or (asteroid.pos.x > screenWidth - asteroid.radius and asteroid.vel.x > 0) then
        asteroid.vel.x = -asteroid.vel.x
        asteroid.vel = asteroid.vel:scaledBy(0.65)
      elseif (asteroid.pos.y < asteroid.radius and asteroid.vel.y < 0) or (asteroid.pos.y > screenHeight - asteroid.radius and asteroid.vel.y > 0) then
        asteroid.vel.y = -asteroid.vel.y
        asteroid.vel = asteroid.vel:scaledBy(0.65)
      end
    end
    asteroid.vel.x += accX
    asteroid.vel.y += accY
    asteroid.pos.x += asteroid.vel.x
    asteroid.pos.y += asteroid.vel.y

    if asteroid.state == 'entering' and isOnScreen then
      asteroid.state = 'active'
    elseif asteroid.state == 'active' and not isOnScreen then
      table.insert(idsToRemove, id)
      gs.score += 1
      gs.asteroidsDiverted += 1
      if gs.mission.winType == 'asteroids' or (gs.mission.winType == 'endless' and gs.mission.mode == 'standard') then
        assets.sfx.point:play()
      end
    end
  end
  for _, id in ipairs(idsToRemove) do
    Asteroid.despawn(id)
  end

  Asteroid.checkCollisions()
end

function Asteroid.checkCollisions()
  local idsToRemove = {}
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
        Explosion.spawn(asteroid.pos.x, asteroid.pos.y)
        Explosion.screenShake(500, 5)
        assets.sfx.boom:play()
      end
      table.insert(idsToRemove, id)
      asteroid.state = 'dead'
      goto continue
    end

    for _, moon in ipairs(gs.moons) do
      if areCirclesColliding(asteroid.pos, asteroid.radius, moon.pos, moon.radius + (moon.hasShield and 3 or 0)) then
        if moon.hasShield then
          moon.hasShield = false
          assets.sfx.shieldDown:play()
        else
          gs.earth.health -= 1
          Explosion.spawn(asteroid.pos.x, asteroid.pos.y)
          Explosion.screenShake(500, 5)
          assets.sfx.boom:play()
        end
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
        goto continue
      end
    end

    for targetId, target in pairs(gs.targets) do
      if areCirclesColliding(asteroid.pos, asteroid.radius, target.pos, target.radius) then
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
        local asteroidSpeed = math.sqrt(asteroid.vel.x * asteroid.vel.x + asteroid.vel.y * asteroid.vel.y)
        target.health -= math.max(1, math.floor(asteroid.radius * asteroidSpeed / 3))
        assets.sfx.goodBoom:play()
        for _ = 1, 32 do
          local pVelX, pVelY = polarCoordinates(math.random() + 1, math.random() * 360)
          Particle.spawn(asteroid.pos.x, asteroid.pos.y, pVelX, pVelY, 10, 2, 4, 0.2)
        end
        if target.health <= 0 then
          target.health = 0
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
        gs.asteroidsCollided += 1
        if gs.mission.mode == 'juggling' then
          if gs.earth.health < gs.earth.maxHealth then
            gs.earth.health += 1
            Game.flashMessage('Nice collision! +1 health')
          else
            Game.flashMessage('Nice collision!')
          end
        elseif gs.mission.winType == 'asteroids' then
          gs.asteroidsDiverted += 4
          Game.flashMessage('2 asteroids collided, that counts double!')
        elseif gs.mission.winType == 'survive' then
          gs.mission.winGoal = math.max(0, gs.mission.winGoal - 5)
          Game.flashMessage('2 asteroids collided! -0:05')
        elseif gs.mission.winType == 'rocket' then
          gs.rocketsCaught += 1
          gs.mission.winGoal = math.max(0, gs.mission.winGoal - 1)
          Game.flashMessage('2 asteroids collided! -1 rocket needed')
        elseif gs.mission.winType == 'boss' then
          gs.boss.health = math.max(0, gs.boss.health - 2)
          Game.flashMessage('2 asteroids collided! +2 bonus damage')
        else
          Game.flashMessage('2 asteroids collided! +5 points')
        end
        local explosionPos = pd.geometry.lineSegment.new(
          asteroid.pos.x,
          asteroid.pos.y,
          asteroid2.pos.x,
          asteroid2.pos.y
        ):midPoint()
        Explosion.spawn(explosionPos.x, explosionPos.y)
        assets.sfx.goodBoom:play()
        break
      end
    end

    ::continue::
  end
  for _, id in ipairs(idsToRemove) do
    Asteroid.despawn(id)
  end
end

function Asteroid.draw()
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  for _, asteroid in pairs(gs.asteroids) do
    if Asteroid.isOnScreen(asteroid) then
      gfx.fillCircleAtPoint(asteroid.pos.x, asteroid.pos.y, asteroid.radius)
      if gs.frameCount % 2 == 0 or gs.frameCount % 3 == 0 then
        local velAngle = angleFromVec(asteroid.vel.x, asteroid.vel.y)
        local pX, pY = polarCoordinates(asteroid.radius, velAngle + math.random(-35, 35))
        local velX, velY = polarCoordinates(
          math.random(1, asteroid.radius) / 10,
          velAngle + math.random(-15, 15)
        )
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
        Particle.spawn(
          asteroid.pos.x - pX,
          asteroid.pos.y - pY,
          velX,
          velY,
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
end
