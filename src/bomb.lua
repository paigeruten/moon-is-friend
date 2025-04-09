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
        Explosion.spawn(asteroid.pos)
        assets.sfx.goodBoom:play()
        Asteroid.despawn(id)
      end
    end
    if gs.bombShockwave > screenWidth then
      gs.bombShockwave = 0
      gs.asteroids = {}
    end
  end

  if gs.mission.mode == 'standard' and pd.buttonJustPressed(pd.kButtonB) and gs.earth.bombs > 0 and gs.bombShockwave == 0 then
    gs.earth.bombs -= 1
    gs.bombShockwave = 1
    gs.bombShockwavePos = gs.earth.pos
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
        gfx.drawCircleAtPoint(gs.bombShockwavePos, radius)
      end
    end
  end
end
