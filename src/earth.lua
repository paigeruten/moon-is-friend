local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets

Earth = {}

function Earth.update()
  if gs.earth.isSafe then
    gs.earth.pos.x = gs.earth.basePos.x
    gs.earth.pos.y = gs.earth.basePos.y
  else
    local perlX = math.min(1, math.max(-1, gfx.perlin((gs.frameCount % 166) / 166, 0, 0, 0) * 10 - 5))
    local perlY = math.min(1, math.max(-1, gfx.perlin(0, (gs.frameCount % 166) / 166, 0, 0) * 10 - 5))
    gs.earth.pos.x = gs.earth.basePos.x + perlX
    gs.earth.pos.y = gs.earth.basePos.y + perlY
  end
end

function Earth.draw()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(gs.earth.pos.x, gs.earth.pos.y, gs.earth.radius)
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

  if gs.earth.isSafe then
    assets.gfx.safeEyes:draw(gs.earth.pos.x - 9, gs.earth.pos.y - 5)

    if not gs.zenMode then
      local zFrame = ((gs.bossPhaseFrame - 30) // 25) % 4 + 1
      assets.gfx.zeds:getImage(zFrame):draw(gs.earth.pos.x + 10, gs.earth.pos.y - 28)
    end
  else
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
    if gs.mission.winType == "boss" and gs.bossPhase == 0 then
      if gs.bossPhaseFrame < 30 then
        lookAtX, lookAtY = 0, 0
      elseif gs.bossPhaseFrame < 60 then
        lookAtX, lookAtY = 1, 0
      else
        lookAtX, lookAtY = 2, 0
      end
    end
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(leftEyeX + lookAtX, leftEyeY + lookAtY, 2)
    gfx.fillCircleAtPoint(rightEyeX + lookAtX, rightEyeY + lookAtY, 2)
  end
end
