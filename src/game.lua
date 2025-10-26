local pd = playdate
local gfx = pd.graphics
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH
local scoreboardsEnabled = SCOREBOARDS_ENABLED

Game = {}

Game.state = {
  scene = 'title',
  missionId = 'endless.s1',
}
local gs = Game.state

function Game.init()
  Title.switch()
end

function Game.stopSounds()
  assets.sfx.omen:stop()
  assets.sfx.suck:stop()
end

function Game.reset()
  achievements.save()

  gs.frameCount = 0
  gs.menuFrameCount = 0
  gs.surviveFrameCount = 0
  gs.endState = nil
  gs.firstTimeCompleted = nil
  gs.newMissionsUnlocked = nil

  gs.score = 0
  gs.asteroidsDiverted = 0
  gs.asteroidsCollided = 0
  gs.rocketsCaught = 0

  gs.mission = MISSIONS[gs.missionId]
  if gs.mission.winType == 'endless' then
    if gs.mission.mode == 'standard' then
      gs.missionIcon = assets.gfx.missionIcons.asteroids
    else
      gs.missionIcon = assets.gfx.missionIcons.collide
    end
  else
    gs.missionIcon = assets.gfx.missionIcons[gs.mission.winType]
  end
  gs.difficulty = gs.mission.difficulty

  local selectedDifficulty = gs.selectedDifficulty or 'normal'
  gs.hardMode = (selectedDifficulty == 'hard' or selectedDifficulty == 'one_heart') and gs.mission.winType ~= 'endless'
  gs.oneHeartMode = selectedDifficulty == 'one_heart' and gs.mission.winType ~= 'endless'

  if gs.mission.mode == 'standard' and gs.mission.winType ~= 'endless' and selectedDifficulty == 'normal' then
    if type(gs.difficulty) == 'table' then
      gs.difficulty[1] += 25
      gs.difficulty[2] += 25
    else
      gs.difficulty += 25
    end
  end

  gs.zenMode = gs.mission.winType == 'endless' and gs.endlessZenMode
  if gs.zenMode and gs.mission.mode == 'standard' then
    gs.difficulty = 125
  end

  local maxHealth = 5
  if gs.oneHeartMode then
    maxHealth = 1
  elseif gs.hardMode then
    maxHealth = 3
  end
  gs.earth = {
    pos = { x = screenWidth // 2 + sidebarWidth // 2, y = screenHeight // 2 },
    basePos = { x = screenWidth // 2 + sidebarWidth // 2, y = screenHeight // 2 },
    radius = 14,
    mass = 0.75,
    pristine = true,
    health = maxHealth,
    maxHealth = maxHealth,
    bombs = 1,
    maxBombs = 3,
    hasShield = false,
  }
  if gs.mission.mode == "juggling" or gs.mission.winType == "boss" then
    gs.earth.bombs = 0
    gs.earth.maxBombs = 0
  end

  gs.moons = {}
  for _ = 1, (gs.mission.numMoons or 1) do
    table.insert(gs.moons, Moon.create())
  end
  Moon.update()

  gs.bombShockwave = 0
  gs.bombShockwavePos = nil
  gs.extraSuction = false
  gs.extraSuctionMaxFuel = 50
  gs.extraSuctionFuel = gs.extraSuctionMaxFuel

  gs.rockets = {}
  gs.lastRocketAt = 0
  if gs.mission.winType == 'rocket' then
    gs.maxRockets = 4
    gs.rocketSpawnRate = 150
    gs.rocketMinTime = 50
    gs.rocketMaxTime = 250
  else
    gs.maxRockets = 1
    gs.rocketSpawnRate = 500
    gs.rocketMinTime = 150
    gs.rocketMaxTime = 1000
  end

  gs.explosions = {}
  gs.curExplosionId = 0

  gs.asteroids = {}
  gs.numAsteroids = 0
  gs.numAsteroidsOnScreen = 0
  gs.curAsteroidId = 0
  gs.lastAsteroidAt = 0

  gs.targets = {}
  gs.curTargetId = 0
  gs.bossPhase = 0
  gs.bossPhaseFrame = 0
  gs.bossMaxHealth = 0
  gs.pauseAsteroidSpawning = false
  if gs.mission.winType == "boss" then
    gs.bossMaxHealth = gs.mission.winGoal(gs.hardMode)

    local bossRadius = gs.mission.winGoal2 and 120 or 75
    Target.spawn(screenWidth - 20 + 25 + bossRadius, screenHeight // 2, bossRadius, gs.mission.winGoal(gs.hardMode))
  end

  gs.particles = {}
  gs.curParticleId = 0

  gs.stars = gfx.image.new(screenWidth, screenHeight, gfx.kColorBlack)
  gs.starsOffset = 0
  gfx.pushContext(gs.stars)
  gfx.setColor(gfx.kColorWhite)
  for _ = 1, 100 do
    gfx.drawPixel(math.random(0, screenWidth), math.random(0, screenHeight))
  end
  gfx.popContext()

  gs.curMessage = nil
  gs.curMessageAt = nil

  gs.achievementTtl = 0

  gs.gameoverSelection = 'retry'
  gs.isHighScore = false
  gs.scoreStatus = nil
  gs.scoreGlobalRank = nil
  gs.asteroidPathsEverEnabled = SaveData.getShowAsteroidPaths()

  gs.rampUpDifficulty = nil
  if type(gs.difficulty) == 'table' then
    Game.updateRampUpDifficulty()
  end

  Game.stopSounds()
end

function Game.updateRampUpDifficulty()
  ---@diagnostic disable-next-line: param-type-mismatch
  local maxDifficulty, minDifficulty = table.unpack(gs.difficulty)
  local minDifficultyTime = 22500 -- 7.5 minutes

  if gs.frameCount >= minDifficultyTime then
    gs.rampUpDifficulty = minDifficulty
    if gs.mission.winType == "endless" and not gs.zenMode then
      if achievements.grant("max_level_endless") then
        Achievement.queue("max_level_endless", true)
      end
    end
  else
    gs.rampUpDifficulty = maxDifficulty - math.floor(
      pd.easingFunctions.outSine(
        gs.frameCount,
        0,
        maxDifficulty - minDifficulty,
        minDifficultyTime
      )
    )
  end
end

function Game.increaseScore(points)
  gs.score += points

  if gs.mission.winType == "endless" and not gs.zenMode then
    if not achievements.isGranted("endless_hero") then
      achievements.advance("endless_hero", points)
      if achievements.isGranted("endless_hero") then
        Achievement.queue("endless_hero", true)
      end
    end

    if not achievements.isGranted("endless_addict") then
      achievements.advance("endless_addict", points)
      if achievements.isGranted("endless_addict") then
        Achievement.queue("endless_addict", true)
      end
    end

    if gs.missionId == "endless.s1" and gs.score >= 200 then
      if achievements.grant("endless_one_moon_expert") then
        Achievement.queue("endless_one_moon_expert", true)
      end
    elseif gs.missionId == "endless.s2" and gs.score >= 100 then
      if achievements.grant("endless_two_moon_expert") then
        Achievement.queue("endless_two_moon_expert", true)
      end
    elseif gs.missionId == "endless.s3" and gs.score >= 100 then
      if achievements.grant("endless_three_moon_expert") then
        Achievement.queue("endless_three_moon_expert", true)
      end
    elseif gs.mission.mode == "juggling" and gs.score >= 50 then
      if achievements.grant("endless_expert_juggler") then
        Achievement.queue("endless_expert_juggler", true)
      end
    end
  end
end

function Game.flashMessage(message)
  gs.curMessage = message
  gs.curMessageAt = gs.frameCount
end

local function checkEndState()
  local win = false
  if gs.mission.winType == "asteroids" then
    win = gs.asteroidsDiverted >= gs.mission.winGoal
  elseif gs.mission.winType == "survive" then
    win = gs.surviveFrameCount // 50 >= gs.mission.winGoal
  elseif gs.mission.winType == "rocket" then
    win = gs.rocketsCaught >= gs.mission.winGoal
  elseif gs.mission.winType == "collide" then
    win = gs.asteroidsCollided >= gs.mission.winGoal
  elseif gs.mission.winType == "boss" then
    win = (Target.count() == 0 and not gs.mission.winGoal2) or (gs.bossPhase == 4 and gs.bossPhaseFrame > 0)
  end

  local menuOptions = {
    withSidebar = true,
    animated = true,
    adjustY = -10
  }

  if win then
    Game.stopSounds()
    gs.endState = 'complete'
    gs.firstTimeCompleted = not SaveData.isMissionComplete(gs.missionId, false)
    local prevHighestUnlocked = MissionTree.highestUnlockedColumn()
    SaveData.completeMission(gs.missionId, gs.hardMode)
    gs.newMissionsUnlocked = MissionTree.highestUnlockedColumn() > prevHighestUnlocked

    if gs.earth.health == gs.earth.maxHealth and gs.earth.bombs == gs.earth.maxBombs and gs.earth.bombs > 0 and gs.earth.hasShield then
      local allMoonShields = true
      for _, moon in ipairs(gs.moons) do
        if not moon.hasShield then
          allMoonShields = false
        end
      end
      if allMoonShields and achievements.grant("max_powerups_mission") then
        achievements.toasts.toast("max_powerups_mission")
      end
    end
    if gs.missionId == "3-B" then
      if achievements.grant("beat_first_boss") then
        achievements.toasts.toast("beat_first_boss")
      end
    end
    if gs.missionId == "6-B" then
      if achievements.grant("beat_the_game") then
        achievements.toasts.toast("beat_the_game")
      end
    end
    if gs.oneHeartMode then
      if achievements.grant("no_damage_" .. gs.missionId) then
        achievements.toasts.toast("no_damage_" .. gs.missionId)

        if not achievements.isGranted("no_damage_all") then
          achievements.advanceTo("no_damage_all", SaveData.countMissionsFlawless())
          if achievements.isGranted("no_damage_all") then
            achievements.toasts.toast("no_damage_all")
          end
        end
      end
    end
    if not gs.asteroidPathsEverEnabled then
      if achievements.grant("no_asteroid_paths") then
        achievements.toasts.toast("no_asteroid_paths")
      end
    end
    if not achievements.isGranted("complete_all_missions") then
      achievements.advanceTo("complete_all_missions", SaveData.countMissionsComplete(false))
      if achievements.isGranted("complete_all_missions") then
        achievements.toasts.toast("complete_all_missions")
      end
    end
    if gs.hardMode and not achievements.isGranted("complete_all_missions_on_hard") then
      achievements.advanceTo("complete_all_missions_on_hard", SaveData.countMissionsComplete(true))
      if achievements.isGranted("complete_all_missions_on_hard") then
        achievements.toasts.toast("complete_all_missions_on_hard")
      end
    end

    MenuBox.init(
      { gs.missionId == "6-B" and "Back to title" or 'Next mission', 'Back to missions' },
      menuOptions,
      GameEnd.menuSelect
    )
    assets.sfx.win:play()
  elseif gs.earth.health <= 0 then
    Game.stopSounds()
    if gs.mission.winType == 'endless' then
      gs.endState = 'game-over'
      gs.isHighScore = not gs.zenMode and SaveData.checkAndSaveHighScore(gs.missionId, gs.score)
      if scoreboardsEnabled and not gs.zenMode then
        gs.scoreStatus = 'submitting'
        pd.scoreboards.addScore(gs.mission.scoreboardId, gs.score, function(status, result)
          if status.code == 'OK' then
            gs.scoreStatus = 'submitted'
            gs.scoreGlobalRank = result.rank
          else
            gs.scoreStatus = 'error'
          end
        end)
      end
      MenuBox.init({ 'Retry', 'Back to title' }, menuOptions, GameEnd.menuSelect)
    else
      gs.endState = 'failed'
      MenuBox.init({ 'Retry', 'Back to missions' }, menuOptions, GameEnd.menuSelect)
    end
    assets.sfx.lose:play()
  end
end

function Game.update()
  if not gs.endState and (gs.moons[1].holdAngle or not pd.isCrankDocked()) then
    Earth.update()
    Moon.update()
    Bomb.update()
    Target.update()
    if gs.mission.winType == 'boss' and gs.bossPhase == 0 then
      gs.lastAsteroidAt = gs.frameCount
      gs.lastRocketAt = gs.frameCount
    else
      Asteroid.update()
      Rocket.update()
    end

    checkEndState()

    gs.frameCount += 1
    gs.surviveFrameCount += 1
    gs.bossPhaseFrame += 1
  end

  Game.draw()

  if gs.endState then
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
    gfx.fillRect(sidebarWidth, 0, screenWidth - sidebarWidth, screenHeight)
    GameEnd.update()
  end
end

function Game.draw()
  if gs.starsOffset <= 0 then
    gs.stars:draw(0, 0)
  else
    gs.stars:draw(0, 0, gfx.kImageUnflipped, gs.starsOffset, 0, screenWidth - gs.starsOffset, screenHeight)
    gs.stars:draw(screenWidth - gs.starsOffset, 0, gfx.kImageUnflipped, 0, 0, gs.starsOffset, screenHeight)
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
  Achievement.draw()

  if not gs.endState and not gs.moons[1].holdAngle and pd.isCrankDocked() then
    pd.ui.crankIndicator:draw()
  end

  -- Flash message
  if gs.curMessage and not gs.endState then
    if gs.frameCount - gs.curMessageAt > 100 then
      gs.curMessage = nil
    else
      gfx.setFont(assets.fonts.menu)
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
      gfx.drawTextAligned(gs.curMessage, sidebarWidth + (screenWidth - sidebarWidth) // 2, screenHeight - 24,
        kTextAlignment.center)
      gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
  end
end
