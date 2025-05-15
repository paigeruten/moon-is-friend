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
    card = "Type: Divert\nGoal: 20 meteors\nChaos: **\nMoons: 1",
    introText = {
      "You are the Moon. After a large-scale asteroid mining expedition gone wrong, "
      .. "your best friend the Earth is now under a barrage of meteors, and is very scared.",
      "You must use the crank to orbit the Earth, and "
      .. "divert 20 meteors off-screen using your gravitational pull.",
      "Good luck!"
    }
  },
  ["1-2"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 60,
    difficulty = 125,
    card = "Type: Survive\nGoal: 1 minute\nChaos: **\nMoons: 1",
  },
  ["2-1"] = {
    mode = "standard",
    winType = "rocket",
    winGoal = 20,
    difficulty = 100,
    card = "Type: Colonize\nGoal: 20 rockets\nChaos: ****\nMoons: 1",
    introText = {
      "Earth is sending a large team of scientists and astronauts up to the Moon "
      .. "to help resupply and bolster your defenses.",
      "Catch 20 rocket-fuls of Moon colonizers to complete this mission."
      .. " Remember to use your bombs (by pressing B)!"
    }
  },
  ["2-2"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 120,
    difficulty = 100,
    card = "Type: Survive\nGoal: 2 minutes\nChaos: ****\nMoons: 1",
    introText = {
      "The meteors are coming in even faster now.",
      "Protect the Earth and survive for 2 minutes to complete this mission."
    }
  },
  ["2-3"] = {
    mode = "juggling",
    winType = "collide",
    winGoal = 3,
    difficulty = 3,
    unlockMessage = "You've unlocked Endless Juggling!",
    card = "Type: Juggling\nGoal: 3 collisions\nChaos: ****\nMoons: 1",
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
    winGoal = 120,
    difficulty = 125,
    numMoons = 2,
    unlockMessage = "You've unlocked Endless mode (2 Moons)!",
    card = "Type: Survive\nGoal: 2 minutes\nChaos: ****\nMoons: 2"
  },
  ["3-B"] = {
    mode = "standard",
    winType = "boss",
    winGoal = 100,
    difficulty = 85,
    card = "Type: Boss\nGoal: ???\nChaos: ******\nMoons: 1"
  },
  ["4-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 120,
    difficulty = 75,
    card = "Type: Survive\nGoal: 2 minutes\nChaos: ******\nMoons: 1"
  },
  ["4-2"] = {
    mode = "standard",
    winType = "rocket",
    winGoal = 30,
    difficulty = 75,
    card = "Type: Colonize\nGoal: 30 rockets\nChaos: ******\nMoons: 1"
  },
  ["4-3"] = {
    mode = "juggling",
    winType = "collide",
    winGoal = 5,
    difficulty = 4,
    unlockMessage = "You've unlocked Endless Juggling (4 Meteors)!",
    card = "Type: Juggling\nGoal: 5 collisions\nChaos: ******\nMoons: 1"
  },
  ["4-4"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 120,
    difficulty = 100,
    numMoons = 2,
    card = "Type: Survive\nGoal: 2 minutes\nChaos: ****\nMoons: 2"
  },
  ["5-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 90,
    difficulty = 60,
    card = "Type: Survive\nGoal: 90 seconds\nChaos: ********\nMoons: 1"
  },
  ["5-2"] = {
    mode = "standard",
    winType = "rocket",
    winGoal = 30,
    difficulty = 100,
    numMoons = 2,
    card = "Type: Colonize\nGoal: 30 rockets\nChaos: ****\nMoons: 2"
  },
  ["5-3"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 120,
    difficulty = 100,
    numMoons = 3,
    unlockMessage = "You've unlocked Endless mode (3 Moons)!",
    card = "Type: Survive\nGoal: 2 minutes\nChaos: ****\nMoons: 3"
  },
  ["6-B"] = {
    mode = "standard",
    winType = "boss",
    winGoal = 100,
    winGoal2 = 33,
    difficulty = 75,
    unlockMessage = "You've unlocked Endless Juggling (5 Meteors)!",
    card = "Type: Boss\nGoal: ???\nChaos: ********\nMoons: 1"
  },
}

MISSION_TREE = {
  { "1-1", "1-2" },
  { "2-1", "2-2", "2-3", "2-4" },
  { "3-B" },
  { "4-1", "4-2", "4-3", "4-4" },
  { "5-1", "5-2", "5-3" },
  { "6-B" }
}

UNLOCK_REQUIREMENTS = { 2, 3, 1, 3, 2, 1 }

local columnUnlockText = { "Finish", "1 more", "mission", "from", "previous", "column", "to", "unlock" }
local columnUnlockNumMissions = 1

local function setColumnUnlockText(numMissions)
  if numMissions ~= columnUnlockNumMissions then
    columnUnlockNumMissions = numMissions
    columnUnlockText[2] = tostring(numMissions) .. " more"
    columnUnlockText[3] = numMissions == 1 and "mission" or "missions"
  end
end

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
  for colIdx, missionCol in ipairs(MISSION_TREE) do
    local numCompleted = 0
    for _, missionId in ipairs(missionCol) do
      if SaveData.isMissionComplete(missionId) then
        numCompleted += 1
      end
    end
    if numCompleted >= UNLOCK_REQUIREMENTS[colIdx] then
      highestUnlocked += 1
    else
      break
    end
  end
  return math.min(highestUnlocked, #MISSION_TREE)
end

local showUnlockMessage = false
local unlockShakeTtl = 0

function MissionTree.switch()
  gs.scene = 'mission-tree'
  gs.frameCount = 0
  gs.highestUnlocked = MissionTree.highestUnlockedColumn()
  Menu.reset()
  showUnlockMessage = false
end

function MissionTree.update()
  gfx.clear()

  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star.x, star.y)
  end

  gfx.setFont(assets.fonts.large)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawTextAligned('*Select Mission*', screenWidth // 2, 8, kTextAlignment.center)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  local checkboxX, checkboxY = screenWidth - 97, 10
  local checkboxSize = 12
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(checkboxX, checkboxY, checkboxSize, checkboxSize)

  -- gfx.setColor(gfx.kColorWhite)
  -- gfx.setLineWidth(2)
  -- gfx.drawRoundRect(checkboxX, checkboxY, checkboxSize, checkboxSize, 2)
  -- gfx.setLineWidth(1)

  if SaveData.getDifficulty() == 'easy' then
    -- gfx.setColor(gfx.kColorWhite)
    -- gfx.drawLine(checkboxX, checkboxY, checkboxX + checkboxSize, checkboxY + checkboxSize)
    -- gfx.drawLine(checkboxX, checkboxY + checkboxSize, checkboxX + checkboxSize, checkboxY)
    -- assets.gfx.whiteCheckmark:draw(checkboxX + 1, checkboxY + 2)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    assets.gfx.checkmark:draw(checkboxX, checkboxY)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
  else
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    assets.gfx.noCheckmark:draw(checkboxX, checkboxY)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
  end

  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  local easyWidth, easyHeight = gfx.drawText('easy mode', screenWidth - 80, 8)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  if gs.missionRow == 0 then
    local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(screenWidth - 80, 8 + easyHeight + 2 + perlY, easyWidth, 3)
  else
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(screenWidth - 80, 8 + easyHeight + 1, easyWidth, 2)
  end

  gfx.setFont(assets.fonts.small)
  local missionX = 25
  for columnNum, missionCol in ipairs(MISSION_TREE) do
    local shakeX = 0
    if unlockShakeTtl > 0 and columnNum == gs.highestUnlocked + 1 then
      shakeX = (unlockShakeTtl // 2) % 3 - 1
      unlockShakeTtl -= 1
    end

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(missionX + 13 - 28 + 1 + shakeX, 32 + 1, 61 - 2, 204 - 2, 5)

    if gs.missionCol == columnNum and gs.missionRow > 0 then
      gfx.setColor(gfx.kColorBlack)
      gfx.setLineWidth(2)
      gfx.drawRoundRect(missionX + 13 - 28 + 1 + 3 + shakeX, 32 + 1 + 3, 61 - 2 - 6, 204 - 2 - 6, 5)
      gfx.setLineWidth(1)
    end

    local missionY = 6
    local missionSpacing = 0
    if #missionCol == 1 then
      missionY += screenHeight // 2 - 13
    elseif #missionCol == 2 then
      missionY += screenHeight // 2 - 50
      missionSpacing = 50 * 2 - 26
    elseif #missionCol == 3 then
      missionY += screenHeight // 2 - 70
      missionSpacing = (70 * 2 - 26) // 2
    elseif #missionCol == 4 then
      missionY += screenHeight // 2 - 85
      missionSpacing = (85 * 2 - 26) // 3
    end
    for _, missionId in ipairs(missionCol) do
      local mission = MISSIONS[missionId]
      if (mission.numMoons or 1) > 1 then
        for i = 1, mission.numMoons do
          gfx.setColor(gfx.kColorBlack)
          gfx.fillCircleAtPoint(missionX + shakeX, missionY + i * 4, 1)
        end
      end
      assets.gfx.missionIcons[mission.winType]:draw(missionX + 2 + shakeX, missionY)
      if SaveData.isMissionComplete(missionId) then
        if achievements.isGranted("no_damage_" .. missionId) then
          assets.gfx.starIcon:draw(missionX + 19 + shakeX, missionY - 3)
        else
          assets.gfx.checkmark:draw(missionX + 19 + shakeX, missionY - 3)
        end
      end
      local textWidth, textHeight = gfx.drawText(missionId, missionX + 5 + shakeX, missionY + 26)
      if string.sub(missionId, 1, 1) == "1" or string.sub(missionId, -1, -1) == "1" then
        textWidth += 1
      end
      if missionId == gs.missionId then
        local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(missionX + 5 + shakeX, missionY + 26 + textHeight + 2 + perlY, textWidth, 3)
      else
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(missionX + 5 + shakeX, missionY + 26 + textHeight, textWidth, 2)
      end
      missionY += missionSpacing
    end

    if columnNum > gs.highestUnlocked then
      gfx.setColor(gfx.kColorBlack)
      gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
      gfx.fillRect(missionX + 13 - 30 + 1 + shakeX, 26 + 1, 63 - 2, 210 - 2)
    end
    if showUnlockMessage and columnNum == gs.highestUnlocked + 1 then
      local missionsCompleted = 0
      for _, missionId in ipairs(MISSION_TREE[gs.highestUnlocked]) do
        if SaveData.isMissionComplete(missionId) then
          missionsCompleted += 1
        end
      end
      setColumnUnlockText(UNLOCK_REQUIREMENTS[gs.highestUnlocked] - missionsCompleted)
      local textX = missionX + 15 + shakeX
      for i, text in ipairs(columnUnlockText) do
        local textWidth, _ = gfx.getTextSize(text)
        local textY = 70 + i * 14
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(textX - textWidth / 2 - 1, textY - 1, textWidth + 2, 14 + 1)
      end
      for i, text in ipairs(columnUnlockText) do
        local textY = 70 + i * 14
        gfx.drawTextAligned(text, textX, textY, kTextAlignment.center)
      end
    end

    missionX += 64
  end

  if gs.missionId then
    local cardWidth, cardHeight = 130, 70
    local cardX, cardY = screenWidth - cardWidth - 8, screenHeight - cardHeight - 6
    if gs.missionCol >= 4 then
      cardX = 8
    end
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(cardX - 3, cardY - 18, cardWidth + 6, cardHeight + 21, 10)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
    gfx.fillRoundRect(cardX - 3, cardY - 18, cardWidth + 6, cardHeight + 21, 10)

    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(cardX, cardY, cardWidth, cardHeight, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(cardX + 15, cardY - 15, 40, 20, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(cardX + cardWidth - 44, cardY - 15, 17, 20, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(cardX + cardWidth - 24, cardY - 15, 17, 20, 5)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(cardX + 15 + 1, cardY - 15 + 1, 40 - 2, 20, 5)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(cardX + cardWidth - 44 + 1, cardY - 15 + 1, 17 - 2, 20, 5)
    if SaveData.isMissionComplete(gs.missionId) then
      assets.gfx.checkmark:draw(cardX + cardWidth - 44 + 4, cardY - 15 + 5, gfx.kImageUnflipped, 2, 2, 9, 9)
    else
      assets.gfx.emptyCircle:draw(cardX + cardWidth - 44 + 4, cardY - 15 + 4)
    end
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(cardX + cardWidth - 24 + 1, cardY - 15 + 1, 17 - 2, 20, 5)
    if achievements.isGranted("no_damage_" .. gs.missionId) then
      assets.gfx.starIcon:draw(cardX + cardWidth - 24 + 4, cardY - 15 + 4, gfx.kImageUnflipped, 2, 2, 9, 9)
    else
      assets.gfx.emptyCircle:draw(cardX + cardWidth - 24 + 4, cardY - 15 + 4)
    end

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(cardX + 1, cardY + 1, cardWidth - 2, cardHeight - 2, 5)
    gfx.drawText(gs.missionId, cardX + 15 + 9, cardY - 15 + 2)
    gfx.drawText(MISSIONS[gs.missionId].card, cardX + 5, cardY + 5)
  else
    local cardWidth, cardHeight = 140, 70
    local cardX, cardY = screenWidth - cardWidth - 8, screenHeight - cardHeight - 6
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(cardX - 3, cardY - 3, cardWidth + 6, cardHeight + 6, 10)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
    gfx.fillRoundRect(cardX - 3, cardY - 3, cardWidth + 6, cardHeight + 6, 10)

    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(cardX, cardY, cardWidth, cardHeight, 5)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(cardX + 1, cardY + 1, cardWidth - 2, cardHeight - 2, 5)

    local easyModeDesc = SaveData.getDifficulty() == 'easy'
      and "Easy mode is on.\n\nSome achievements\nwill be disabled."
      or "Easy mode is off.\n\nTurn it on for a\nbit less stress!"
    gfx.drawText(easyModeDesc, cardX + 5, cardY + 5)
  end

  gs.frameCount += 1

  if pd.buttonJustPressed(pd.kButtonDown) then
    showUnlockMessage = false
    gs.missionRow += 1
    if gs.missionRow > #MISSION_TREE[gs.missionCol] then
      gs.missionRow = 0
    end
  elseif pd.buttonJustPressed(pd.kButtonUp) then
    showUnlockMessage = false
    gs.missionRow -= 1
    if gs.missionRow == -1 then
      gs.missionRow = #MISSION_TREE[gs.missionCol]
    end
  elseif pd.buttonJustPressed(pd.kButtonLeft) and gs.missionRow > 0 then
    showUnlockMessage = false
    if gs.missionCol > 1 then
      gs.missionCol -= 1
      gs.missionRow = 1
    end
  elseif pd.buttonJustPressed(pd.kButtonRight) and gs.missionRow > 0 then
    showUnlockMessage = false
    if gs.missionCol < gs.highestUnlocked then
      gs.missionCol += 1
      gs.missionRow = 1
    else
      showUnlockMessage = true
      unlockShakeTtl = 20
      assets.sfx.boop:play(55)
    end
  end

  gs.missionId = MISSION_TREE[gs.missionCol][gs.missionRow]

  if pd.buttonJustReleased(pd.kButtonA) then
    if gs.missionRow == 0 then
      SaveData.setDifficulty(SaveData.getDifficulty() == 'easy' and 'normal' or 'easy')
      assets.sfx.boop:play()
    else
      MissionIntro.switch()
      assets.sfx.boop:play(77)
    end
  end

  if pd.buttonJustReleased(pd.kButtonB) then
    Title.switch()
    assets.sfx.boop:play()
  end
end
