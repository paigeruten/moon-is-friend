local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Earth = {}

function Earth.draw()
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos.x, gs.earth.pos.y, gs.earth.radius)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos.x - 1, gs.earth.pos.y - 1, gs.earth.radius - 2)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(gs.earth.pos.x - 2, gs.earth.pos.y - 2, gs.earth.radius - 4)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos.x - 9, gs.earth.pos.y - 9, 3)
  gfx.fillCircleAtPoint(gs.earth.pos.x - 9, gs.earth.pos.y + 3, 4)
  gfx.fillCircleAtPoint(gs.earth.pos.x - 3, gs.earth.pos.y + 6, 4)
  gfx.fillCircleAtPoint(gs.earth.pos.x + 5, gs.earth.pos.y - 9, 4)
  gfx.setDitherPattern(0.6, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(gs.earth.pos.x + 8, gs.earth.pos.y + 6, 4)
  gfx.fillCircleAtPoint(gs.earth.pos.x + 9, gs.earth.pos.y + 4, 4)
  if gs.earth.hasShield then
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(gs.earth.pos.x, gs.earth.pos.y, gs.earth.radius + 4)
  end

  local leftEyeX, leftEyeY = gs.earth.pos.x - 5, gs.earth.pos.y - 5
  local rightEyeX, rightEyeY = gs.earth.pos.x + 5, gs.earth.pos.y - 5
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(leftEyeX, leftEyeY, 5)
  gfx.fillCircleAtPoint(rightEyeX, rightEyeY, 5)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer8x8)
  gfx.drawCircleAtPoint(leftEyeX, leftEyeY, 5)
  gfx.drawCircleAtPoint(rightEyeX, rightEyeY, 5)
  local lookAtX, lookAtY = Asteroid.closestAsteroidDirection()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(leftEyeX + lookAtX, leftEyeY + lookAtY, 2)
  gfx.fillCircleAtPoint(rightEyeX + lookAtX, rightEyeY + lookAtY, 2)
end
