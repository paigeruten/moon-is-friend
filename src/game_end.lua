local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

GameEnd = {}

local bannerWidth, bannerHeight = assets.gfx.banner:getSize()
local bannerCenterX = sidebarWidth + (screenWidth - sidebarWidth) // 2
local bannerX = bannerCenterX - bannerWidth // 2

function GameEnd.menuSelect(which)
  if which == 2 then
    if gs.endState == "game-over" then
      Title.switch()
    else
      MissionTree.switch()
    end
    assets.sfx.boop:play()
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
      else
        MissionTree.switch()
      end
    end
    assets.sfx.boop:play(77)
  end

  Game.reset()
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

  if gs.isHighScore then
    local highScoreY = pd.easingFunctions.outExpo(gs.menuFrameCount, screenHeight, -22, 50)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(sidebarWidth + 5, highScoreY, 120, 18, 2)
    assets.gfx.arrowRight:draw(sidebarWidth + 1, highScoreY + 9 - 3, gfx.kImageFlippedX)
    gfx.setFont(assets.fonts.small)
    gfx.drawText("New high score!", sidebarWidth + 13, highScoreY + 2)
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
