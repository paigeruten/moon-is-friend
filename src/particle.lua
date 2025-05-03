local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Particle = {}

function Particle.spawn(x, y, velX, velY, ttl, minRadius, maxRadius, ditherAlpha)
  gs.curParticleId += 1
  local id = gs.curParticleId
  gs.particles[id] = {
    x = x,
    y = y,
    velX = velX,
    velY = velY,
    ttl = ttl,
    minRadius = minRadius,
    maxRadius = maxRadius,
    ditherAlpha = ditherAlpha,
  }
end

function Particle.draw()
  local idsToRemove = {}
  for id, particle in pairs(gs.particles) do
    if math.random(1, 4) == 1 then
      gfx.setColor(gfx.kColorXOR)
    else
      gfx.setColor(gfx.kColorWhite)
    end
    gfx.setDitherPattern(particle.ditherAlpha, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(particle.x, particle.y, math.random(particle.minRadius, particle.maxRadius))
    if particle.ttl <= 0 then
      table.insert(idsToRemove, id)
    else
      particle.ttl -= 1
      particle.x += particle.velX
      particle.y += particle.velY
    end
  end
  for _, id in ipairs(idsToRemove) do
    gs.particles[id] = nil
  end
end
