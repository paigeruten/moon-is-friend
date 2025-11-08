local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

GameEnd = {}

local bannerWidth, bannerHeight, bannerCenterX, bannerX

function GameEnd.init()
  bannerWidth, bannerHeight = assets.gfx.banner:getSize()
  bannerCenterX = sidebarWidth + (screenWidth - sidebarWidth) // 2
  bannerX = bannerCenterX - bannerWidth // 2
end

function GameEnd.menuSelect(which)
  if which == 2 then
    if gs.endState == "game-over" then
      Title.switch()
    else
      MissionTree.switch()
    end
    assets.sfx.boop:play()
    Game.reset()
  else
    if gs.endState == "complete" then
      local lastMissionId = nil
      local nextMissionId = nil
      for rowIdx, row in ipairs(MISSION_TREE) do
        if rowIdx > MissionTree.highestUnlockedColumn() then
          goto foundNextMission
        end
        for _, curMissionId in ipairs(row) do
          if lastMissionId == gs.missionId then
            nextMissionId = curMissionId
            goto foundNextMission
          end
          lastMissionId = curMissionId
        end
      end
      ::foundNextMission::

      if nextMissionId then
        gs.missionId = nextMissionId
        MissionIntro.switch()
      elseif gs.missionId == "6-B" then
        Title.switch()
      else
        MissionTree.switch()
      end
    end
    assets.sfx.boop:play(77)
    Game.reset(true)
  end
end

function GameEnd.update()
  local bannerText
  if gs.endState == "complete" then
    bannerText = "*Mission Complete!*"
  elseif gs.endState == "failed" then
    bannerText = "*Mission Failed"
  else
    bannerText = "*Game Over*"
  end

  local bannerY = pd.easingFunctions.outExpo(gs.menuFrameCount, -bannerHeight, 75, 50)
  assets.gfx.banner:draw(bannerX, bannerY)
  gfx.setFont(assets.fonts.large)
  gfx.drawTextAligned(bannerText, bannerCenterX, bannerY + 5, kTextAlignment.center)

  if gs.scoreStatus or gs.isHighScore then
    local highScoreParts = gs.isHighScore and { "New high score!" } or {}
    if gs.scoreStatus == 'submitting' then
      table.insert(highScoreParts, "Submitting score...")
    elseif SCOREBOARDS_ENABLED then
      table.insert(highScoreParts, "Global rank:")
      table.insert(highScoreParts, gs.scoreGlobalRank or "?")
    end
    local highScoreText = table.concat(highScoreParts, " ")
    local highScoreWidth = assets.fonts.small:getTextWidth(highScoreText) + 16

    local highScoreY = pd.easingFunctions.outExpo(gs.menuFrameCount, screenHeight, -22, 50)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(sidebarWidth + 5, highScoreY, highScoreWidth, 18, 2)
    assets.gfx.arrowRight:draw(sidebarWidth + 1, highScoreY + 9 - 3, gfx.kImageFlippedX)
    gfx.setFont(assets.fonts.small)
    gfx.drawText(highScoreText, sidebarWidth + 13, highScoreY + 2)
  end

  if gs.firstTimeCompleted then
    local unlockText = gs.mission.unlockMessage
    if not unlockText and gs.newMissionsUnlocked then
      unlockText = "You've unlocked new missions!"
    end

    if unlockText then
      local unlockBoxY = pd.easingFunctions.outExpo(gs.menuFrameCount, screenHeight, -20, 50)

      gfx.setFont(assets.fonts.menu)
      local unlockTextWidth, _ = gfx.getTextSize(unlockText)
      local unlockBoxX = bannerCenterX - unlockTextWidth // 2 - 10

      gfx.setColor(gfx.kColorWhite)
      gfx.fillRoundRect(unlockBoxX, unlockBoxY, unlockTextWidth + 20, 25, 4)

      gfx.drawText(unlockText, unlockBoxX + 10, unlockBoxY + 4)
    end
  end

  MenuBox.update()
end
