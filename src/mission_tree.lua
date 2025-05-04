local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT

MissionTree = {}

MISSIONS = {
  ["endless.s1"] = {
    mode = "standard",
    winType = "endless",
    difficulty = { 125, 50 }
  },
  ["endless.s2"] = {
    mode = "standard",
    winType = "endless",
    difficulty = { 125, 50 },
    numMoons = 2
  },
  ["endless.s3"] = {
    mode = "standard",
    winType = "endless",
    difficulty = { 125, 50 },
    numMoons = 3
  },
  ["endless.j3"] = {
    mode = "juggling",
    winType = "endless",
    difficulty = 3
  },
  ["endless.j4"] = {
    mode = "juggling",
    winType = "endless",
    difficulty = 4
  },
  ["endless.j5"] = {
    mode = "juggling",
    winType = "endless",
    difficulty = 5
  },
  ["1-1"] = {
    mode = "standard",
    winType = "asteroids",
    winGoal = 20,
    difficulty = 125,
    unlockMessage = "You've unlocked Endless mode!",
    introText = {
      "You are the Moon. After a large-scale asteroid mining expedition gone wrong, "
      .. "your best friend the Earth is now under a barrage of meteors, and is very scared.",
      "You must use the crank to orbit the Earth, and "
      .. "divert 20 meteors off-screen using your gravitational pull.",
      "Good luck!"
    }
  },
  ["2-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 120,
    difficulty = 100,
    introText = {
      "The meteors are coming in even faster now.",
      "Protect the Earth and survive for 2 minutes to complete this mission."
    }
  },
  ["2-2"] = {
    mode = "standard",
    winType = "rocket",
    winGoal = 10,
    difficulty = 100,
    introText = {
      "Earth is sending a large team of scientists and astronauts up to the Moon "
      .. "to help resupply and bolster your defenses.",
      "Catch 10 rocket-fuls of Moon colonizers to complete this mission."
      .. " Remember to use your bombs (by pressing B)!"
    }
  },
  ["2-3"] = {
    mode = "juggling",
    winType = "collide",
    winGoal = 3,
    difficulty = 3,
    unlockMessage = "You've unlocked Endless Juggling!",
    introText = {
      "Some asteroids got captured in Earth's orbit, and just won't leave."
      .. " In this mission you must obliterate 3 pairs of asteroids by making"
      .. " them collide with each other.",
      "There are no power-ups in this mode, but collisions give you +1 Health, and you can boost your"
      .. " gravitational pull at any time by holding B."
    }
  },
  ["2-4"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 60,
    difficulty = 125,
    numMoons = 2,
    unlockMessage = "You've unlocked Endless mode (2 Moons)!"
  },
  ["3-B"] = {
    mode = "standard",
    winType = "boss",
    winGoal = 100,
    difficulty = 85
  },
  ["4-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 120,
    difficulty = 75
  },
  ["4-2"] = {
    mode = "standard",
    winType = "rocket",
    winGoal = 15,
    difficulty = 75
  },
  ["4-3"] = {
    mode = "juggling",
    winType = "collide",
    winGoal = 5,
    difficulty = 4,
    unlockMessage = "You've unlocked Endless Juggling (4 Meteors)!"
  },
  ["4-4"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 90,
    difficulty = 100,
    numMoons = 2
  },
  ["5-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 300,
    difficulty = { 100, 50 }
  },
  ["5-2"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 90,
    difficulty = 100,
    numMoons = 3,
    unlockMessage = "You've unlocked Endless mode (3 Moons)!"
  },
  ["6-B"] = {
    mode = "standard",
    winType = "boss",
    winGoal = 100,
    difficulty = 75,
    unlockMessage = "You've unlocked Endless Juggling (5 Meteors)!"
  },
}

MISSION_TREE = {
  { "1-1" },
  { "2-1", "2-2", "2-3", "2-4" },
  { "3-B" },
  { "4-1", "4-2", "4-3", "4-4" },
  { "5-1", "5-2" },
  { "6-B" }
}

function MissionTree.selectNextMission()
  for colIdx, missionCol in ipairs(MISSION_TREE) do
    for rowIdx, missionId in ipairs(missionCol) do
      if not SaveData.isMissionComplete(missionId) then
        gs.missionRow = rowIdx
        gs.missionCol = colIdx
        gs.missionId = missionId
        return
      end
    end
  end

  gs.missionRow = 1
  gs.missionCol = 1
  gs.missionId = MISSION_TREE[gs.missionCol][gs.missionRow]
end

function MissionTree.highestUnlockedColumn()
  local highestUnlocked = 1
  for _, missionCol in ipairs(MISSION_TREE) do
    local numCompleted = 0
    for _, missionId in ipairs(missionCol) do
      if SaveData.isMissionComplete(missionId) then
        numCompleted += 1
      end
    end
    if numCompleted == #missionCol or (#missionCol > 1 and numCompleted == #missionCol - 1) then
      highestUnlocked += 1
    else
      break
    end
  end
  return math.min(highestUnlocked, #MISSION_TREE)
end

function MissionTree.switch()
  gs.scene = 'mission-tree'
  gs.frameCount = 0
  gs.highestUnlocked = MissionTree.highestUnlockedColumn()
  Menu.reset()
end

function MissionTree.update()
  gfx.clear()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRoundRect(0, 0, screenWidth, screenHeight, 15)
  gfx.setColor(gfx.kColorBlack)
  gfx.drawRoundRect(1, 1, screenWidth - 2, screenHeight - 2, 15)

  gfx.setFont(assets.fonts.large)
  gfx.drawTextAligned('*Select Mission*', screenWidth // 2, 10, kTextAlignment.center)

  gfx.setFont(assets.fonts.small)
  local missionX = 40
  for columnNum, missionCol in ipairs(MISSION_TREE) do
    local missionY = 6
    local missionSpacing = 0
    if #missionCol == 1 then
      missionY += screenHeight // 2 - 13
    elseif #missionCol == 2 then
      missionY += screenHeight // 2 - 50
      missionSpacing = 50 * 2 - 26
    elseif #missionCol == 3 then
      -- not used yet
    elseif #missionCol == 4 then
      missionY += screenHeight // 2 - 85
      missionSpacing = (85 * 2 - 26) // 3
    end
    for _, missionId in ipairs(missionCol) do
      local mission = MISSIONS[missionId]
      assets.gfx.missionIcons[mission.winType]:draw(missionX, missionY)
      if SaveData.isMissionComplete(missionId) then
        assets.gfx.checkmark:draw(missionX + 20, missionY - 3)
      end
      local textWidth, textHeight = gfx.drawText(missionId, missionX + 3, missionY + 26)
      if missionId == gs.missionId then
        local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(missionX + 3, missionY + 26 + textHeight + 2 + perlY, textWidth, 3)
      else
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(missionX + 3, missionY + 26 + textHeight, textWidth, 2)
      end
      missionY += missionSpacing
    end

    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(missionX + 13 - 30, 36, 61, 198)
    if columnNum > gs.highestUnlocked then
      gfx.setColor(gfx.kColorBlack)
      gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
      gfx.fillRect(missionX + 13 - 30 + 1, 36 + 1, 61 - 2, 198 - 2)
    end

    missionX += 60
  end

  gs.frameCount += 1

  if pd.buttonJustPressed(pd.kButtonDown) then
    if gs.missionRow < #MISSION_TREE[gs.missionCol] then
      gs.missionRow += 1
    elseif gs.missionCol < gs.highestUnlocked then
      gs.missionCol += 1
      gs.missionRow = 1
    end
  elseif pd.buttonJustPressed(pd.kButtonUp) then
    if gs.missionRow > 1 then
      gs.missionRow -= 1
    elseif gs.missionCol > 1 then
      gs.missionCol -= 1
      gs.missionRow = #MISSION_TREE[gs.missionCol]
    end
  elseif pd.buttonJustPressed(pd.kButtonLeft) then
    if gs.missionCol > 1 then
      gs.missionCol -= 1
      gs.missionRow = 1
    end
  elseif pd.buttonJustPressed(pd.kButtonRight) then
    if gs.missionCol < gs.highestUnlocked then
      gs.missionCol += 1
      gs.missionRow = 1
    end
  end

  gs.missionId = MISSION_TREE[gs.missionCol][gs.missionRow]

  if pd.buttonJustReleased(pd.kButtonA) then
    MissionIntro.switch()
    assets.sfx.boop:play(77)
  end

  if pd.buttonJustReleased(pd.kButtonB) then
    Title.switch()
    assets.sfx.boop:play()
  end
end
