local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Moon = {}

function Moon.update()
  gs.moon.pos = gs.earth.pos + pd.geometry.vector2D.newPolar(gs.moon.distanceFromEarth, pd.getCrankPosition())
end

function Moon.draw()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(gs.moon.pos, gs.moon.radius)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(2, 2), 3)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(-4, -1), 2)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(3, -3), 2)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(-4, 4), 2)
  gfx.fillCircleAtPoint(gs.moon.pos + pd.geometry.vector2D.new(-1, -5), 2)
  if gs.moon.hasShield then
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(gs.moon.pos, gs.moon.radius + 3)
  end
end
