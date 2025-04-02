local pd = playdate
local gfx = pd.graphics
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

Game = {}

Game.state = {
  scene = 'title',
  gameMode = 'standard', -- 'standard' | 'juggling'
  difficulty = 'ramp-up',
  screenShakeEnabled = not pd.getReduceFlashing()
}
local gs = Game.state

function Game.reset()
  gs.frameCount = 0
  gs.score = 0

  gs.earth = {
    pos = pd.geometry.point.new(screenWidth // 2 + sidebarWidth // 2, screenHeight // 2),
    radius = 14,
    mass = 0.75,
    health = 5,
    maxHealth = 5,
    bombs = 2,
    maxBombs = 5,
    hasShield = false,
  }

  gs.moon = {
    pos = pd.geometry.point.new(gs.earth.pos.x, gs.earth.pos.y - MOON_DISTANCE_FROM_EARTH),
    distanceFromEarth = MOON_DISTANCE_FROM_EARTH,
    radius = 7,
    gravityRadius = 75,
    mass = 2.5,
    hasShield = false,
  }

  gs.bombShockwave = 0
  gs.bombShockwavePos = nil

  gs.curRocket = nil
  gs.lastRocketAt = 0

  gs.explosions = {}
  gs.curExplosionId = 0

  gs.asteroids = {}
  gs.curAsteroidId = 0
  gs.lastAsteroidAt = 0

  gs.targets = {}
  gs.curTargetId = 0

  gs.particles = {}
  gs.curParticleId = 0

  gs.stars = {}
  for _ = 1, 100 do
    table.insert(gs.stars, pd.geometry.point.new(math.random() * screenWidth, math.random() * screenHeight))
  end

  gs.curMessage = nil
  gs.curMessageAt = nil

  gs.gameoverSelection = 'retry'
  gs.isHighScore = false

  Game.updateRampUpDifficulty()
end

function Game.updateRampUpDifficulty()
  gs.rampUpDifficulty = MAX_RAMP_UP_DIFFICULTY - math.floor(
    pd.easingFunctions.outSine(
      gs.frameCount,
      0,
      MAX_RAMP_UP_DIFFICULTY - MIN_RAMP_UP_DIFFICULTY,
      22500 -- 7.5 minutes
    )
  )
end

Game.reset()

function Game.flashMessage(message)
  gs.curMessage = message
  gs.curMessageAt = gs.frameCount
end

local function checkGameOver()
  if gs.earth.health <= 0 then
    gs.scene = 'gameover'
    gs.frameCount = 0
    if gs.score > SaveData.highScore then
      SaveData.highScore = gs.score
      pd.datastore.write(SaveData)
      gs.isHighScore = true
    end
  end
end

function Game.update()
  if not pd.isCrankDocked() then
    Moon.update()
    Bomb.update()
    Target.update()
    Asteroid.update()
    Rocket.update()

    checkGameOver()

    gs.frameCount += 1
  end

  Game.draw()
end

function Game.draw()
  gfx.clear()

  -- Stars
  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star)
  end

  Earth.draw()
  Rocket.draw()
  Moon.draw()
  Target.draw()
  Particle.draw()
  Asteroid.draw()
  Explosion.draw()
  Bomb.draw()
  Sidebar.draw()

  if pd.isCrankDocked() then
    pd.ui.crankIndicator:draw()
  end

  -- Flash message
  if gs.curMessage then
    if gs.frameCount - gs.curMessageAt > 100 then
      gs.curMessage = nil
    else
      gfx.setFont(assets.fonts.large)
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
      gfx.drawTextAligned(gs.curMessage, screenWidth // 2, screenHeight - 24, kTextAlignment.center)
      gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
  end

  --pd.drawFPS(screenWidth - 20, screenHeight - 15)
end
