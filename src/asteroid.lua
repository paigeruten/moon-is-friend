local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

local pathSegmentLength = 24
local maxPathLength = 48
local pathLength = maxPathLength

local polarCoordinates = Util.polarCoordinates
local angleFromVec = Util.angleFromVec

Asteroid = {}

local function nextAsteroidId()
  gs.curAsteroidId += 1
  return gs.curAsteroidId
end

function Asteroid.spawn()
  if gs.mission.winType == "boss" and math.random(7) == 1 then
    local targets = {}
    for _, target in pairs(gs.targets) do
      if target.state == 'active' then
        table.insert(targets, target)
      end
    end
    if #targets > 0 then
      Asteroid.spawnFromTarget(targets[math.random(#targets)])
      return
    end
  end

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
  local asteroidRadius
  if gs.mission.mode == 'juggling' then
    if gs.mission.winType == 'endless' and not gs.zenMode then
      if gs.frameCount < 3000 then
        asteroidRadius = math.random(5, 6)
      elseif gs.frameCount < 9000 then
        asteroidRadius = math.random(4, 5)
      elseif gs.frameCount < 15000 then
        asteroidRadius = math.random(3, 4)
      elseif gs.frameCount < 21000 then
        asteroidRadius = math.random(2, 3)
      else
        asteroidRadius = 2
      end
    else
      asteroidRadius = gs.hardMode and math.random(4, 5) or math.random(5, 6)
    end
  else
    local chooseRadius = math.random()
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
    if gs.missionId == 'endless.rubdubdub' then
      asteroidRadius = math.floor(asteroidRadius * (1 + (gs.frameCount // 250) / 5))
    end
  end
  local speed
  if posX < 0 or posX >= screenWidth then
    speed = math.random(5, 14) / 10
  else
    speed = math.random(5, 9) / 10
  end
  if gs.mission.winType == "boss" then
    speed *= 0.7
  elseif gs.missionId == 'endless.rubdubdub' then
    speed *= 1 + math.random(0, 20) / 10
  end
  local velAngle = angle
  if gs.mission.winType == "boss" and not gs.hardMode then
    if math.random() < 0.5 then
      velAngle += 10 + math.random() * 10
    else
      velAngle -= 10 + math.random() * 10
    end
  else
    velAngle += math.random() * 40 - 20
  end
  local velX, velY = polarCoordinates(speed, velAngle)
  gs.asteroids[id] = {
    id = id,
    pos = { x = posX, y = posY },
    vel = { x = -velX, y = -velY },
    initialVel = { x = -velX, y = -velY },
    radius = asteroidRadius,
    state = 'entering',
    path = {},
    lastPathState = { frame = 1, velX = 0, velY = 0 },
  }
  Asteroid.resetPath(gs.asteroids[id])
  gs.numAsteroids += 1
  return id
end

function Asteroid.spawnFromTarget(target)
  local id = nextAsteroidId()
  local posX, posY = polarCoordinates(target.radius + 3, math.random(225, 315))
  posX += target.pos.x
  posY += target.pos.y
  local speed = math.random(5, 9) / 40
  local direction = Util.angleFromVec(gs.earth.pos.x - posX, gs.earth.pos.y - posY)
  local velX, velY = polarCoordinates(speed, direction + (math.random() * 20 - 10))
  gs.asteroids[id] = {
    id = id,
    pos = { x = posX, y = posY },
    vel = { x = velX, y = velY },
    initialVel = { x = velX, y = velY },
    radius = 4,
    state = 'active',
    path = {},
    lastPathState = { frame = 1, velX = 0, velY = 0 },
    bossSafeTtl = 50,
  }
  Asteroid.resetPath(gs.asteroids[id])
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

function Asteroid.resetPath(asteroid)
  local curLength = #asteroid.path
  for i = 1, maxPathLength do
    if i > curLength then
      asteroid.path[i] = {}
    end
    asteroid.path[i].x = asteroid.pos.x
    asteroid.path[i].y = asteroid.pos.y
  end
  asteroid.lastPathState.frame = 1
end

function Asteroid.resetAllPaths()
  for _, asteroid in pairs(gs.asteroids) do
    Asteroid.resetPath(asteroid)
  end
end

local isMirror = false

function playdate.mirrorStarted()
  isMirror = true
  gs.recalcPathLengths = true
end

function playdate.mirrorEnded()
  isMirror = false
  gs.recalcPathLengths = true
end

function Asteroid.closestAsteroidDirection()
  local minDistance = nil
  local minEarthVecX = nil
  local minEarthVecY = nil
  for _, asteroid in pairs(gs.asteroids) do
    local earthVecX, earthVecY = asteroid.pos.x - gs.earth.pos.x, asteroid.pos.y - gs.earth.pos.y
    local distanceSquared = earthVecX * earthVecX + earthVecY * earthVecY
    if minDistance == nil or distanceSquared < minDistance then
      minDistance = distanceSquared
      minEarthVecX = earthVecX
      minEarthVecY = earthVecY
    end
  end

  if minDistance then
    local distance = math.sqrt(minDistance)
    return minEarthVecX / distance, minEarthVecY / distance
  elseif gs.mission.winType == 'boss' then
    return 1, 0
  else
    return 0, 0
  end
end

local function posIsOnScreen(x, y, r)
  return x + r >= sidebarWidth and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

function Asteroid.isOnScreen(asteroid)
  return posIsOnScreen(asteroid.pos.x, asteroid.pos.y, asteroid.radius)
end

local isAsteroidOnScreen = Asteroid.isOnScreen

local function areCirclesCollidingRaw(ax, ay, ar, bx, by, br)
  local dx, dy = bx - ax, by - ay
  local distanceSquared = dx * dx + dy * dy
  local radiusSum = ar + br
  return distanceSquared <= radiusSum * radiusSum
end

function Asteroid.areCirclesColliding(centerA, radiusA, centerB, radiusB)
  return areCirclesCollidingRaw(centerA.x, centerA.y, radiusA, centerB.x, centerB.y, radiusB)
end

local areCirclesColliding = Asteroid.areCirclesColliding

local function clamp(value, low, high)
  return math.min(high, math.max(low, value))
end

local function calculateAsteroidPath(steps, x, y, velX, velY, radius, isOnScreen, stopWhenOffScreen, stopOnCollision,
                                     callback)
  local earthX, earthY = gs.earth.pos.x, gs.earth.pos.y
  local earthMass = gs.earth.mass
  local moonGravityRadiusSquared = gs.moons[1].gravityRadius * gs.moons[1].gravityRadius
  local collided = false

  for i = 1, steps do
    if not collided and (not stopWhenOffScreen or posIsOnScreen(x, y, radius)) then
      local earthVecX, earthVecY = earthX - x, earthY - y
      local earthDistanceSquared = earthVecX * earthVecX + earthVecY * earthVecY
      local accX = earthVecX * (earthMass / earthDistanceSquared)
      local accY = earthVecY * (earthMass / earthDistanceSquared)

      if isOnScreen then
        for _, moon in ipairs(gs.moons) do
          local moonVecX, moonVecY = moon.pos.x - x, moon.pos.y - y
          local moonDistanceSquared = moonVecX * moonVecX + moonVecY * moonVecY
          if moonDistanceSquared <= moonGravityRadiusSquared and moonDistanceSquared > 4 then
            local moonMass = moon.mass
            if gs.extraSuction then
              moonMass *= 2
            end
            accX += moonVecX * (moonMass / moonDistanceSquared)
            accY += moonVecY * (moonMass / moonDistanceSquared)
          end
        end
      end

      if gs.mission.mode == 'juggling' then
        if (x < sidebarWidth + radius and velX < 0) or (x > screenWidth - radius and velX > 0) then
          velX = -velX
          velX *= 0.65
          velY *= 0.65
        elseif (y < radius and velY < 0) or (y > screenHeight - radius and velY > 0) then
          velY = -velY
          velX *= 0.65
          velY *= 0.65
        end
      end

      velX += accX
      velY += accY
      x += velX
      y += velY
    end

    if callback then
      callback(i, x, y)
    end

    -- Only used for showing asteroid paths. Actual collision detection is done elsewhere.
    if stopOnCollision then
      if areCirclesCollidingRaw(x, y, radius, gs.earth.pos.x, gs.earth.pos.y, gs.earth.radius + (gs.earth.hasShield and 4 or 0)) then
        collided = true
      end

      for _, moon in ipairs(gs.moons) do
        if areCirclesCollidingRaw(x, y, radius, moon.pos.x, moon.pos.y, moon.radius + (moon.hasShield and 3 or 0)) then
          collided = true
        end
      end

      for _, target in pairs(gs.targets) do
        if areCirclesCollidingRaw(x, y, radius, target.pos.x, target.pos.y, target.radius) then
          collided = true
        end
      end
    end
  end

  return x, y, velX, velY
end

function Asteroid.update()
  if gs.mission.mode == 'standard' and not gs.pauseAsteroidSpawning then
    if gs.frameCount - gs.lastAsteroidAt >= (gs.rampUpDifficulty or gs.difficulty) then
      Asteroid.spawn()
      gs.lastAsteroidAt = gs.frameCount
      if gs.rampUpDifficulty then
        Game.updateRampUpDifficulty()
      end
    end
  elseif gs.mission.mode == 'juggling' then
    if gs.numAsteroids < gs.difficulty and gs.frameCount - gs.lastAsteroidAt >= 100 then
      Asteroid.spawn()
      gs.lastAsteroidAt = gs.frameCount
    end
  end

  local showAsteroidPaths = SaveData.data.settings.showAsteroidPaths
  local nextNumAsteroidsOnScreen = 0
  local idsToRemove = {}
  for id, asteroid in pairs(gs.asteroids) do
    local isOnScreen = isAsteroidOnScreen(asteroid)

    if isOnScreen then
      nextNumAsteroidsOnScreen += 1
    end

    asteroid.pos.x, asteroid.pos.y, asteroid.vel.x, asteroid.vel.y = calculateAsteroidPath(
      1,
      asteroid.pos.x,
      asteroid.pos.y,
      asteroid.vel.x,
      asteroid.vel.y,
      asteroid.radius,
      isOnScreen,
      false,
      false
    )

    if showAsteroidPaths and isOnScreen then
      local asteroidPath = asteroid.path
      local lastFrame = asteroid.lastPathState.frame
      local pathX, pathY, pathVelX, pathVelY
      if lastFrame == 1 then
        pathX = asteroid.pos.x
        pathY = asteroid.pos.y
        pathVelX = asteroid.vel.x
        pathVelY = asteroid.vel.y
      else
        pathX = asteroid.path[lastFrame - 1].x
        pathY = asteroid.path[lastFrame - 1].y
        pathVelX = asteroid.lastPathState.velX
        pathVelY = asteroid.lastPathState.velY
      end

      local segmentLength = math.min(pathSegmentLength, pathLength - lastFrame + 1)

      local _, _, lastVelX, lastVelY = calculateAsteroidPath(
        segmentLength,
        pathX,
        pathY,
        pathVelX,
        pathVelY,
        asteroid.radius,
        isOnScreen,
        gs.mission.mode ~= 'juggling',
        true,
        function(i, curX, curY)
          asteroidPath[lastFrame + i - 1].x = curX
          asteroidPath[lastFrame + i - 1].y = curY
        end
      )

      asteroid.lastPathState.frame = lastFrame + segmentLength
      if asteroid.lastPathState.frame > pathLength then
        asteroid.lastPathState.frame = 1
      end
      asteroid.lastPathState.velX = lastVelX
      asteroid.lastPathState.velY = lastVelY
    end

    if asteroid.bossSafeTtl then
      asteroid.bossSafeTtl -= 1
      if asteroid.bossSafeTtl <= 0 then
        asteroid.bossSafeTtl = nil
      end
    end

    if asteroid.state == 'entering' and isOnScreen then
      asteroid.state = 'active'
    elseif asteroid.state == 'active' and not isOnScreen then
      table.insert(idsToRemove, id)
      Game.increaseScore(1)
      gs.asteroidsDiverted += 1
      if gs.mission.winType == 'asteroids' or (gs.mission.winType == 'endless' and gs.mission.mode == 'standard') then
        assets.sfx.point:play()
      end
    end
  end
  for _, id in ipairs(idsToRemove) do
    Asteroid.despawn(id)
  end

  if showAsteroidPaths and (nextNumAsteroidsOnScreen ~= gs.numAsteroidsOnScreen or gs.recalcPathLengths) then
    gs.recalcPathLengths = false

    local prevPathLength = pathLength
    if nextNumAsteroidsOnScreen <= 1 then
      pathLength = 40
      pathSegmentLength = 20
    elseif nextNumAsteroidsOnScreen == 2 then
      pathLength = 36
      pathSegmentLength = 18
    elseif nextNumAsteroidsOnScreen == 3 then
      pathLength = 30
      pathSegmentLength = 10
    elseif nextNumAsteroidsOnScreen == 4 then
      pathLength = 32
      pathSegmentLength = 8
    else
      pathLength = 30
      pathSegmentLength = 5
    end

    if isMirror then
      pathSegmentLength = (pathSegmentLength + 1) // 2
      pathLength -= pathSegmentLength
    end

    for _, asteroid in pairs(gs.asteroids) do
      asteroid.lastPathState.frame = 1

      if pathLength > prevPathLength then
        for i = prevPathLength + 1, pathLength do
          asteroid.path[i].x = asteroid.pos.x
          asteroid.path[i].y = asteroid.pos.y
        end
      end
    end
  end

  gs.numAsteroidsOnScreen = nextNumAsteroidsOnScreen

  Asteroid.checkCollisions()
end

function Asteroid.checkCollisions()
  local idsToRemove = {}
  for id, asteroid in pairs(gs.asteroids) do
    if asteroid.state ~= 'active' then
      goto continue
    end

    if not gs.zenMode and areCirclesColliding(asteroid.pos, asteroid.radius, gs.earth.pos, gs.earth.radius + (gs.earth.hasShield and 4 or 0)) then
      if gs.earth.hasShield then
        gs.earth.hasShield = false
        assets.sfx.shieldDown:play()
      else
        gs.earth.health -= 1
        gs.earth.pristine = false
        Explosion.spawn(asteroid.pos.x, asteroid.pos.y)
        Explosion.screenShake(500, 5)
        assets.sfx.boom:play()
      end
      table.insert(idsToRemove, id)
      asteroid.state = 'dead'
      goto continue
    end

    for _, moon in ipairs(gs.moons) do
      if not gs.zenMode and gs.missionId ~= 'endless.rubdubdub' and areCirclesColliding(asteroid.pos, asteroid.radius, moon.pos, moon.radius + (moon.hasShield and 3 or 0)) then
        if moon.hasShield then
          moon.hasShield = false
          assets.sfx.shieldDown:play()
        else
          if not gs.zenMode then
            gs.earth.health -= 1
          end
          gs.earth.pristine = false
          Explosion.spawn(asteroid.pos.x, asteroid.pos.y)
          Explosion.screenShake(500, 5)
          assets.sfx.boom:play()
        end
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
        goto continue
      end
    end

    for _, target in pairs(gs.targets) do
      if asteroid.bossSafeTtl then
        break
      end

      if areCirclesColliding(asteroid.pos, asteroid.radius, target.pos, target.radius) then
        table.insert(idsToRemove, id)
        asteroid.state = 'dead'
        for _ = 1, 32 do
          local pVelX, pVelY = polarCoordinates(math.random() + 1, math.random() * 360)
          Particle.spawn(asteroid.pos.x, asteroid.pos.y, pVelX, pVelY, 10, 2, 4, 0.2)
        end
        if target.state == 'active' then
          local asteroidSpeed = math.sqrt(asteroid.vel.x * asteroid.vel.x + asteroid.vel.y * asteroid.vel.y)
          local damage = math.floor(1.3 * math.max(1, math.floor(asteroid.radius * asteroidSpeed / 3)))
          target.health -= damage
          target.shakeTtl = damage * 2
          assets.sfx.goodBoom:play()

          Particle.spawn(asteroid.pos.x, asteroid.pos.y, asteroid.vel.x / 5, asteroid.vel.y / 5, 30, 1, 1, 1, 1, nil,
            "-" .. damage)

          if damage >= 15 and not gs.zenMode then
            if achievements.grant("big_damage") then
              Achievement.queue("big_damage", true)
            end
          end

          if target.health <= 0 then
            target.health = 0
            target.state = 'splode'
            target.splodeTtl = 100

            if Target.countActive() == 0 then
              for asteroidId, asteroid2 in pairs(gs.asteroids) do
                Explosion.spawn(asteroid2.pos.x, asteroid2.pos.y)
                Asteroid.despawn(asteroidId)
              end
              gs.asteroids = {}
              gs.pauseAsteroidSpawning = true
            end
          end
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
        Game.increaseScore(5)
        gs.asteroidsCollided += 1

        if not gs.zenMode then
          if achievements.grant("first_collision") then
            Achievement.queue("first_collision", true)
          end

          if not achievements.isGranted("asteroid_collisions") then
            achievements.advance("asteroid_collisions", 1)
            if achievements.isGranted("asteroid_collisions") then
              Achievement.queue("asteroid_collisions", true)
            end
          end

          if gs.mission.mode == 'juggling' and gs.mission.winType == 'endless' and asteroid.radius == 2 and asteroid2.radius == 2 then
            if achievements.grant("tiny_asteroid_collision") then
              Achievement.queue("tiny_asteroid_collision", true)
            end
          end
        end

        if gs.mission.mode == 'juggling' then
          if gs.earth.health < gs.earth.maxHealth then
            gs.earth.health += 1
            Game.flashMessage('Nice collision! +1 health')
          else
            Game.increaseScore(2)
            if gs.mission.winType == 'endless' then
              Game.flashMessage('Nice collision! +2 bonus points')
            else
              Game.flashMessage('Nice collision!')
            end
          end
        elseif gs.mission.winType == 'asteroids' then
          gs.asteroidsDiverted += 4
          Game.flashMessage('2 meteors collided, they count double!')
        elseif gs.mission.winType == 'survive' then
          gs.surviveFrameCount += 50 * 5
          Game.flashMessage('2 meteors collided! -0:05')
        elseif gs.mission.mode == 'standard' and gs.mission.winType == 'endless' then
          Game.flashMessage('2 meteors collided! +5 points')
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
  local showAsteroidPaths = SaveData.data.settings.showAsteroidPaths

  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  for _, asteroid in pairs(gs.asteroids) do
    if Asteroid.isOnScreen(asteroid) then
      gfx.setColor(gfx.kColorWhite)
      gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
      gfx.fillCircleAtPoint(asteroid.pos.x, asteroid.pos.y, asteroid.radius)

      local framesPerParticle, velFactor, particleTtl = 1, 10, 7
      if gs.numAsteroidsOnScreen == 3 then
        framesPerParticle, velFactor, particleTtl = 1, 6, 5
      elseif gs.numAsteroidsOnScreen >= 4 then
        framesPerParticle, velFactor, particleTtl = 2, 3, 4
      end

      if gs.frameCount % framesPerParticle == 0 then
        local velAngle = angleFromVec(asteroid.vel.x, asteroid.vel.y)
        local pX, pY = polarCoordinates(asteroid.radius, velAngle + math.random(-35, 35))
        local velX, velY = polarCoordinates(
          math.random(1, asteroid.radius) / velFactor,
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
          particleTtl,
          minRadius,
          maxRadius,
          0.5
        )
      end

      if showAsteroidPaths then
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        local path = asteroid.path
        for i = 4, pathLength, 3 do
          gfx.fillCircleAtPoint(path[i].x, path[i].y, 1)
        end
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
