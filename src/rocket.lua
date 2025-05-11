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

function Rocket.spawn()
  local direction = rocketDirections[math.random(#rocketDirections)]
  local directionInfo = rocketDirectionInfo[direction]
  local pX, pY = polarCoordinates(gs.earth.radius + 1, directionInfo.angle)
  gs.curRocket = {
    frame = 0,
    pos = { x = gs.earth.pos.x + pX, y = gs.earth.pos.y + pY },
    vel = { x = 0, y = 0 },
    acc = { x = 0, y = 0 },
    direction = direction,
    info = directionInfo
  }
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

function Rocket.update()
  if gs.curRocket then
    if gs.curRocket.frame == 100 then
      -- Liftoff!
      gs.curRocket.acc.x, gs.curRocket.acc.y = polarCoordinates(0.005, gs.curRocket.info.angle)
    end
    if gs.frameCount % 2 == 0 then
      Particle.spawn(
        gs.curRocket.pos.x,
        gs.curRocket.pos.y,
        -gs.curRocket.vel.x + (math.random() - 0.5),
        -gs.curRocket.vel.y + (math.random() - 0.5),
        5,
        1,
        2,
        0.2
      )
    end
    gs.curRocket.vel.x += gs.curRocket.acc.x
    gs.curRocket.vel.y += gs.curRocket.acc.y
    gs.curRocket.pos.x += gs.curRocket.vel.x
    gs.curRocket.pos.y += gs.curRocket.vel.y

    gs.curRocket.frame += 1

    local collidingMoon = isRocketCollidingWithMoon(gs.curRocket)

    if not isRocketOnScreen(gs.curRocket) then
      gs.curRocket = nil
      gs.lastRocketAt = gs.frameCount
    elseif collidingMoon then
      gs.rocketsCaught += 1

      local powerups = {}
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
          gs.score += 3
          Game.flashMessage("Maxed power-ups! +3 bonus points")
          assets.sfx.powerup:play()
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
        Game.flashMessage('+1 Bomb! (Ⓑ to use)')
        assets.sfx.powerup:play()
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

      gs.curRocket = nil
      gs.lastRocketAt = gs.frameCount
    else
      for id, asteroid in pairs(gs.asteroids) do
        if asteroid.state == 'active' and isRocketCollidingWithCircle(gs.curRocket, asteroid.pos, asteroid.radius) then
          local explosionPos = pd.geometry.lineSegment.new(
            asteroid.pos.x,
            asteroid.pos.y,
            gs.curRocket.pos.x,
            gs.curRocket.pos.y
          ):midPoint()
          Explosion.spawn(explosionPos.x, explosionPos.y)
          assets.sfx.goodBoom:play()
          Asteroid.despawn(id)
          gs.curRocket = nil
          gs.lastRocketAt = gs.frameCount
          if achievements.grant("rocket_collision") then
            Achievement.queue("rocket_collision", true)
          end
          break
        end
      end
    end
  elseif ((gs.frameCount - gs.lastRocketAt) > 150 and math.random(500) == 1)
      or (gs.frameCount - gs.lastRocketAt) > 1000 -- every 3 + ~10 seconds, max 20 seconds
  then
    if gs.mission.mode == 'standard' and gs.bossPhase < 3 then
      Rocket.spawn()
      Game.flashMessage('Supplies incoming!')
    end
  end
end

function Rocket.draw()
  if gs.curRocket then
    gs.curRocket.info.image:drawAnchored(gs.curRocket.pos.x, gs.curRocket.pos.y, gs.curRocket.info.anchor.x,
      gs.curRocket.info.anchor.y, gs.curRocket.info.flip)
  end
end
