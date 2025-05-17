local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

local areCirclesColliding = Asteroid.areCirclesColliding
local polarCoordinates = Util.polarCoordinates

Rocket = {}

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

local nextRocketId = 1

function Rocket.spawn()
  local direction
  while not direction do
    direction = rocketDirections[math.random(#rocketDirections)]
    for _, rocket in pairs(gs.rockets) do
      if rocket.direction == direction then
        direction = nil
        break
      end
    end
  end

  local directionInfo = rocketDirectionInfo[direction]
  local pX, pY = polarCoordinates(gs.earth.radius + 1, directionInfo.angle)
  gs.rockets[nextRocketId] = {
    frame = 0,
    pos = { x = gs.earth.pos.x + pX, y = gs.earth.pos.y + pY },
    vel = { x = 0, y = 0 },
    acc = { x = 0, y = 0 },
    direction = direction,
    info = directionInfo
  }
  nextRocketId += 1
end

local function isRocketOnScreen(rocket)
  local x, y, r = rocket.pos.x, rocket.pos.y, 3
  return x + r >= sidebarWidth and x - r <= screenWidth and y + r >= 0 and y - r <= screenHeight
end

local tempPos = {}
local function isRocketCollidingWithCircle(rocket, center, radius)
  local dirX, dirY = polarCoordinates(1, rocket.info.angle)
  -- Collision zone consists of three small circles along the length of the rocket
  for section = 0, 2 do
    tempPos.x = rocket.pos.x + dirX * section * 2
    tempPos.y = rocket.pos.y + dirY * section * 2
    if areCirclesColliding(tempPos, 1.5, center, radius) then
      return true
    end
  end
  return false
end

local function isRocketCollidingWithMoon(rocket)
  for _, moon in ipairs(gs.moons) do
    if isRocketCollidingWithCircle(rocket, moon.pos, moon.radius) then
      return moon
    end
  end
  return nil
end

local function isMaxPowerUps()
  if not gs.earth.hasShield or gs.earth.health < gs.earth.maxHealth or gs.earth.bombs < gs.earth.maxBombs then
    return false
  end

  for _, moon in ipairs(gs.moons) do
    if not moon.hasShield then
      return false
    end
  end

  return true
end

function Rocket.update()
  local numRockets = 0
  for rocketId, rocket in pairs(gs.rockets) do
    numRockets += 1

    if rocket.frame == 100 then
      -- Liftoff!
      rocket.acc.x, rocket.acc.y = polarCoordinates(0.005, rocket.info.angle)
    end
    if gs.frameCount % 2 == 0 then
      Particle.spawn(
        rocket.pos.x,
        rocket.pos.y,
        -rocket.vel.x + (math.random() - 0.5),
        -rocket.vel.y + (math.random() - 0.5),
        5,
        1,
        2,
        0.2
      )
    end
    rocket.vel.x += rocket.acc.x
    rocket.vel.y += rocket.acc.y
    rocket.pos.x += rocket.vel.x
    rocket.pos.y += rocket.vel.y

    rocket.frame += 1

    local collidingMoon = isRocketCollidingWithMoon(rocket)

    if not isRocketOnScreen(rocket) then
      gs.rockets[rocketId] = nil
      if gs.mission.winType ~= 'rocket' then
        gs.lastRocketAt = gs.frameCount
      end
    elseif collidingMoon then
      gs.rocketsCaught += 1

      local powerups = {}
      if gs.mission.winType == 'rocket' then
        table.insert(powerups, 'nothing')
        table.insert(powerups, 'nothing')
        table.insert(powerups, 'nothing')
        table.insert(powerups, 'nothing')
      end
      if gs.earth.health < gs.earth.maxHealth then
        table.insert(powerups, 'health')
        table.insert(powerups, 'health')
      end
      if gs.earth.bombs < gs.earth.maxBombs then
        table.insert(powerups, 'bomb')
      end
      if not collidingMoon.hasShield then
        table.insert(powerups, 'moon-shield')
      end
      if not gs.earth.hasShield then
        table.insert(powerups, 'earth-shield')
      end
      if #powerups == 0 then
        table.insert(powerups, 'bonus-points')
      end

      local powerup = powerups[math.random(#powerups)]

      if powerup == 'health' then
        gs.earth.health += 1
        Game.flashMessage('+1 Health!')
        assets.sfx.powerup:play()
      elseif powerup == 'max-health' then
        -- unused for now
        gs.earth.maxHealth += 1
        gs.earth.health = gs.earth.maxHealth
        Game.flashMessage('+1 Max Health!')
        assets.sfx.powerup:play()
      elseif powerup == 'bonus-points' then
        if gs.mission.winType == 'endless' then
          Game.increaseScore(3)
          Game.flashMessage("Max power-ups! +3 bonus points")
          assets.sfx.powerup:play()
          if achievements.grant("max_powerups_endless") then
            Achievement.queue("max_powerups_endless", true)
          end
        end
      elseif powerup == 'moon-shield' then
        collidingMoon.hasShield = true
        Game.flashMessage('You got a shield!')
        assets.sfx.shieldUp:play()
      elseif powerup == 'earth-shield' then
        gs.earth.hasShield = true
        Game.flashMessage('Earth got a shield!')
        assets.sfx.shieldUp:play()
      elseif powerup == 'bomb' then
        gs.earth.bombs += 1
        Game.flashMessage('+1 Bomb!')
        assets.sfx.powerup:play()
      elseif powerup == 'nothing' then
        assets.sfx.point:play()
      end

      -- Check for shield achievements
      if powerup == 'moon-shield' or powerup == 'earth-shield' then
        local numShields = gs.earth.hasShield and 1 or 0
        for _, moon in ipairs(gs.moons) do
          if moon.hasShield then
            numShields += 1
          end
        end

        if numShields == 2 then
          if achievements.grant("double_shield") then
            Achievement.queue("double_shield", true)
          end
        end
        if numShields == 3 then
          if achievements.grant("triple_shield") then
            Achievement.queue("triple_shield", true)
          end
        end
        if numShields == 4 then
          if achievements.grant("quadruple_shield") then
            Achievement.queue("quadruple_shield", true)
          end
        end
      end

      gs.rockets[rocketId] = nil
      if gs.mission.winType ~= 'rocket' then
        gs.lastRocketAt = gs.frameCount
      end
    else
      for id, asteroid in pairs(gs.asteroids) do
        if asteroid.state == 'active' and isRocketCollidingWithCircle(rocket, asteroid.pos, asteroid.radius) then
          local explosionPos = pd.geometry.lineSegment.new(
            asteroid.pos.x,
            asteroid.pos.y,
            rocket.pos.x,
            rocket.pos.y
          ):midPoint()
          Explosion.spawn(explosionPos.x, explosionPos.y)
          assets.sfx.goodBoom:play()
          Asteroid.despawn(id)
          gs.rockets[rocketId] = nil
          if gs.mission.winType == 'rocket' then
            if gs.rocketsCaught > 0 then
              gs.rocketsCaught -= 1
              Game.flashMessage('Ouch! -1 rocket')
            end
          else
            gs.lastRocketAt = gs.frameCount
          end
          if achievements.grant("rocket_collision") then
            Achievement.queue("rocket_collision", true)
          end
          break
        end
      end
    end
  end

  if numRockets < gs.maxRockets then
    if (gs.frameCount - gs.lastRocketAt > gs.rocketMinTime and math.random(gs.rocketSpawnRate) == 1)
        or gs.frameCount - gs.lastRocketAt > gs.rocketMaxTime
    then
      if gs.mission.mode == 'standard' and gs.bossPhase < 3 then
        if gs.mission.winType == 'endless' or gs.mission.winType == 'rocket' or not isMaxPowerUps() then
          Rocket.spawn()
          if gs.mission.winType == 'rocket' then
            gs.lastRocketAt = gs.frameCount
          else
            Game.flashMessage('Supplies incoming!')
          end
        end
      end
    end
    return
  end
end

function Rocket.draw()
  for _, rocket in pairs(gs.rockets) do
    rocket.info.image:drawAnchored(rocket.pos.x, rocket.pos.y, rocket.info.anchor.x, rocket.info.anchor.y,
      rocket.info.flip)
  end
end
