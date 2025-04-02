local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Target = {}

function Target.spawn(x, y, r)
  gs.curTargetId += 1
  local id = gs.curTargetId
  gs.targets[id] = {
    id = id,
    pos = pd.geometry.point.new(x, y),
    radius = r,
    health = 100,
  }
  return id
end

function Target.update()
  if gs.frameCount == 2 then
    --spawnTarget(100, 30, 26)
    --spawnTarget(screenWidth - 30, 100, 20)
    --spawnTarget(35, 130, 22)
    --spawnTarget(280, screenHeight - 40, 18)
  end
end

function Target.draw()
  for _, target in pairs(gs.targets) do
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.7, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos, target.radius)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos + pd.geometry.vector2D.new(-2, -2), target.radius - 2)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos + pd.geometry.vector2D.new(-4, -4), target.radius - 4)

    if target.health < 100 then
      gfx.setColor(gfx.kColorWhite)
      gfx.drawRoundRect(target.pos.x - 10, target.pos.y + target.radius + 4, 20, 4, 2)
      gfx.fillRoundRect(target.pos.x - 10, target.pos.y + target.radius + 4, target.health / 5, 4, 2)
    end
  end
end
