local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Target = {}

function Target.spawn(x, y, r, health)
  gs.curTargetId += 1
  local id = gs.curTargetId
  gs.targets[id] = {
    id = id,
    pos = { x = x, y = y },
    basePos = { x = x, y = y },
    radius = r,
    health = health,
  }
  return gs.targets[id]
end

function Target.update()
  for _, target in pairs(gs.targets) do
    local perlX = math.min(2, math.max(-2, gfx.perlin((gs.frameCount % 200) / 200, 0, 0, 0) * 20 - 10))
    local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 200) / 200, 0, 0) * 20 - 10))
    target.pos.x = target.basePos.x + perlX
    target.pos.y = target.basePos.y + perlY
  end
end

function Target.draw()
  for _, target in pairs(gs.targets) do
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.7, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos.x, target.pos.y, target.radius)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos.x - 2, target.pos.y - 2, target.radius - 2)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos.x - 4, target.pos.y - 4, target.radius - 4)

    -- if target.health < 100 then
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRoundRect(target.pos.x - 16, target.pos.y + target.radius + 6, 33, 4, 2)
    gfx.fillRoundRect(target.pos.x - 16, target.pos.y + target.radius + 6, target.health / 3, 4, 2)
    -- end
  end
end
