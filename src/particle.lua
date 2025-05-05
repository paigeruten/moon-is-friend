local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Particle = {}

local maxParticles = 100
local particlePool = {}
for i = 1, maxParticles do
  particlePool[i] = {}
end

function Particle.spawn(x, y, velX, velY, ttl, minRadius, maxRadius, ditherAlpha, decay, color)
  gs.curParticleId = (gs.curParticleId % maxParticles) + 1
  local id = gs.curParticleId

  local particle = particlePool[id]
  particle.x = x
  particle.y = y
  particle.velX = velX
  particle.velY = velY
  particle.ttl = ttl
  particle.decay = decay or 0.9
  particle.radius = math.random(minRadius, maxRadius)
  particle.ditherAlpha = ditherAlpha
  particle.color = color or gfx.kColorWhite

  gs.particles[id] = particle
end

function Particle.draw()
  local idsToRemove = {}
  for id, particle in pairs(gs.particles) do
    if math.random(1, 4) == 1 then
      gfx.setColor(gfx.kColorXOR)
    else
      gfx.setColor(particle.color)
    end
    gfx.setDitherPattern(particle.ditherAlpha, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(particle.x, particle.y, particle.radius)
    if particle.ttl <= 0 or particle.radius < 1 then
      table.insert(idsToRemove, id)
    else
      particle.ttl -= 1
      particle.x += particle.velX
      particle.y += particle.velY
      particle.radius *= particle.decay
    end
  end
  for _, id in ipairs(idsToRemove) do
    gs.particles[id] = nil
  end
end
