local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH

local polarCoordinates = Util.polarCoordinates

Target = {}

function Target.spawn(x, y, r, health)
  gs.curTargetId += 1
  local id = gs.curTargetId
  gs.targets[id] = {
    id = id,
    state = 'active',
    pos = { x = x, y = y },
    basePos = { x = x, y = y },
    radius = r,
    health = health,
    maxHealth = health,
    shakeTtl = 0
  }
  return gs.targets[id]
end

function Target.totalHealth()
  local totalHealth, totalMaxHealth = 0, 0
  for _, target in pairs(gs.targets) do
    totalHealth += target.health
    totalMaxHealth += target.maxHealth
  end
  return totalHealth, totalMaxHealth
end

function Target.update()
  for id, target in pairs(gs.targets) do
    local perlX = math.min(2, math.max(-2, gfx.perlin((gs.frameCount % 200) / 200, 0, 0, 0) * 20 - 10))
    local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 200) / 200, 0, 0) * 20 - 10))
    target.pos.x = target.basePos.x + perlX
    target.pos.y = target.basePos.y + perlY
    if target.shakeTtl > 0 then
      target.pos.x += math.random(-target.shakeTtl, target.shakeTtl) / 2
      target.pos.y += math.random(-target.shakeTtl, target.shakeTtl) / 2
      target.shakeTtl -= 1
    end

    if target.state == 'splode' then
      target.splodeTtl -= 1
      target.shakeTtl = 5
      if target.splodeTtl <= 0 then
        gs.targets[id] = nil

        local totalHealth, _ = Target.totalHealth()
        if totalHealth <= 0 and gs.mission.winGoal2 and gs.bossPhase == 1 then
          gs.bossPhase = 2
          Target.spawn(screenWidth - 40, 120, 20, gs.mission.winGoal2)
          Target.spawn(screenWidth - 65, 40, 20, gs.mission.winGoal2)
          Target.spawn(screenWidth - 65, 200, 20, gs.mission.winGoal2)
        end
        --elseif target.splodeTtl % 10 == 0 then
      elseif math.random(1, 5) == 1 then
        if math.random(1, 2) == 1 then
          assets.sfx.boom:play()
        end
        for _ = 1, 32 do
          local pVelX, pVelY = polarCoordinates(math.random() + 1, math.random() * 360)
          local minRadius = math.floor((100 - target.splodeTtl) / 20) + 2
          Particle.spawn(
            target.pos.x + math.random(-target.radius, target.radius),
            target.pos.y + math.random(-target.radius, target.radius),
            pVelX,
            pVelY,
            10,
            minRadius,
            minRadius + 2,
            0.2,
            0.9,
            gfx.kColorBlack
          )
        end
      end
    end
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

    gfx.setColor(gfx.kColorWhite)
    gfx.drawRoundRect(target.pos.x - 16, target.pos.y + target.radius + 6, 33, 4, 2)
    gfx.fillRoundRect(target.pos.x - 16, target.pos.y + target.radius + 6, 33 * target.health / target.maxHealth, 4, 2)
  end
end
