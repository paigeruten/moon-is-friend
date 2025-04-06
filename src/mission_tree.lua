local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT

MissionTree = {}

MISSIONS = {
  ["0-1"] = {
    mode = "standard",
    winType = "asteroids",
    winGoal = 20,
    difficulty = 125
  },
  ["1-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 60,
    difficulty = 100,
    requires = { "0-1" }
  },
  ["1-2"] = {
    mode = "standard",
    winType = "rocket",
    winGoal = 15,
    difficulty = 100,
    requires = { "0-1" }
  },
  ["1-3"] = {
    mode = "juggling",
    winType = "collide",
    winGoal = 3,
    difficulty = 3,
    requires = { "0-1" }
  },
  ["1-4"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 60,
    difficulty = 125,
    numMoons = 2,
    requires = { "0-1" }
  },
  ["1-B"] = {
    mode = "standard",
    winType = "boss",
    winGoal = 100,
    difficulty = 75,
    requires = { "1-1", "1-2", "1-3", "1-4" },
    requiresLeeway = 1
  },
  ["2-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 120,
    difficulty = 75,
    requires = { "1-B" }
  },
  ["2-2"] = {
    mode = "standard",
    winType = "rocket",
    winGoal = 20,
    difficulty = 75,
    requires = { "1-B" }
  },
  ["2-3"] = {
    mode = "juggling",
    winType = "collide",
    winGoal = 5,
    difficulty = 4,
    requires = { "1-B" }
  },
  ["2-4"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 90,
    difficulty = 100,
    numMoons = 2,
    requires = { "1-B" }
  },
  ["3-1"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 300,
    difficulty = { 125, 50 },
    requires = { "2-1", "2-2", "2-3", "2-4" },
    requiresLeeway = 1
  },
  ["3-2"] = {
    mode = "standard",
    winType = "survive",
    winGoal = 90,
    difficulty = 100,
    numMoons = 3,
    requires = { "2-1", "2-2", "2-3", "2-4" },
    requiresLeeway = 1
  },
  ["3-B"] = {
    mode = "standard",
    winType = "boss",
    winGoal = 100,
    difficulty = 50,
    requires = { "3-1", "3-2" },
    requiresLeeway = 1
  },
}

MISSION_TREE = {
  { "0-1" },
  { "1-1", "1-2", "1-3", "1-4" },
  { "1-B" },
  { "2-1", "2-2", "2-3", "2-4" },
  { "3-1", "3-2" },
  { "3-B" }
}

function MissionTree.update()
  gfx.clear()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRoundRect(0, 0, screenWidth, screenHeight, 15)
  gfx.setColor(gfx.kColorBlack)
  gfx.drawRoundRect(1, 1, screenWidth - 2, screenHeight - 2, 15)

  gfx.setFont(assets.fonts.large)
  gfx.drawTextAligned('*Select Mission*', screenWidth // 2, 12, kTextAlignment.center)

  gfx.setFont(assets.fonts.small)
  local missionX = 40
  for _, missionRow in ipairs(MISSION_TREE) do
    local missionY = 10
    local missionSpacing = 0
    if #missionRow == 1 then
      missionY += screenHeight // 2 - 13
    elseif #missionRow == 2 then
      missionY += screenHeight // 2 - 50
      missionSpacing = 50 * 2 - 26
    elseif #missionRow == 3 then
      -- not used yet
    elseif #missionRow == 4 then
      missionY += screenHeight // 2 - 85
      missionSpacing = (85 * 2 - 26) // 3
    end
    for _, missionId in ipairs(missionRow) do
      local mission = MISSIONS[missionId]
      assets.gfx.missionIcons[mission.winType]:draw(missionX, missionY)
      gfx.drawText(missionId, missionX + 2, missionY + 28)
      missionY += missionSpacing
    end

    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(missionX + 13 - 30, 40, 61, 190)
    if missionX > 100 then
      gfx.setColor(gfx.kColorBlack)
      gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
      gfx.fillRect(missionX + 13 - 30 + 1, 40 + 1, 61 - 2, 190 - 2)
    end

    missionX += 60
  end

  if pd.buttonJustReleased(pd.kButtonA) then
    gs.scene = 'story'
    gs.frameCount = 0
    assets.sfx.boop:play()
  end
end
