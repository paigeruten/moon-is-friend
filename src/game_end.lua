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

  MenuBox.update()
end
