local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Earth = {}

function Earth.draw()
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos, gs.earth.radius)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(-1, -1), gs.earth.radius - 2)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(-2, -2), gs.earth.radius - 4)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(-9, -9), 3)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(-9, 3), 4)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(-3, 6), 4)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(5, -9), 4)
  gfx.setDitherPattern(0.6, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(8, 6), 4)
  gfx.fillCircleAtPoint(gs.earth.pos + pd.geometry.vector2D.new(9, 4), 4)
  if gs.earth.hasShield then
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(gs.earth.pos, gs.earth.radius + 4)
  end

  local leftEye = pd.geometry.point.new(gs.earth.pos.x - 5, gs.earth.pos.y - 5)
  local rightEye = pd.geometry.point.new(gs.earth.pos.x + 5, gs.earth.pos.y - 5)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(leftEye, 5)
  gfx.fillCircleAtPoint(rightEye, 5)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer8x8)
  gfx.drawCircleAtPoint(leftEye, 5)
  gfx.drawCircleAtPoint(rightEye, 5)
  local lookAtX, lookAtY = Asteroid.closestAsteroidDirection()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(leftEye.x + lookAtX, leftEye.y + lookAtY, 2)
  gfx.fillCircleAtPoint(rightEye.x + lookAtX, rightEye.y + lookAtY, 2)
end
