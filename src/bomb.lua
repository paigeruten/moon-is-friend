local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH

local areCirclesColliding = Asteroid.areCirclesColliding

Bomb = {}

function Bomb.update()
  if gs.bombShockwave > 0 then
    gs.lastAsteroidAt = gs.frameCount
    gs.bombShockwave += 10
    for id, asteroid in pairs(gs.asteroids) do
      if asteroid.state == 'active' and areCirclesColliding(gs.bombShockwavePos, gs.bombShockwave, asteroid.pos, asteroid.radius) then
        Explosion.spawn(asteroid.pos.x, asteroid.pos.y)
        assets.sfx.goodBoom:play()
        Asteroid.despawn(id)
        gs.bombedAsteroids += 1
      end
    end
    if gs.bombShockwave > screenWidth then
      for _, _ in pairs(gs.asteroids) do
        gs.bombedAsteroids += 1
      end
      if gs.bombedAsteroids >= 5 and not gs.zenMode then
        if achievements.grant("chaos_averted") then
          Achievement.queue("chaos_averted", true)
        end
      end

      gs.asteroids = {}
      gs.bombShockwave = 0
      gs.bombedAsteroids = 0
    end
  end

  local abPressed = pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB)
  if gs.earth.maxBombs > 0 and abPressed and gs.earth.bombs > 0 and gs.bombShockwave == 0 then
    gs.earth.bombs -= 1
    gs.bombShockwave = 1
    gs.bombShockwavePos = gs.earth.pos
    gs.bombedAsteroids = 0
    Explosion.screenShake(500, 5)
  end
end

function Bomb.draw()
  if gs.bombShockwave > 0 then
    for i, alpha in ipairs({ 0.8, 0.4, 0.1, 0.4, 0.8 }) do
      local radius = gs.bombShockwave - i * 4
      if radius > 0 then
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(alpha, gfx.image.kDitherTypeBayer8x8)
        gfx.drawCircleAtPoint(gs.bombShockwavePos.x, gs.bombShockwavePos.y, radius)
      end
    end
  end
end
