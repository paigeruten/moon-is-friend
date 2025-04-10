local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
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
  -- Todo: move to bottom left
  if gs.isHighScore then
    local highScoreBoxWidth = pd.easingFunctions.outExpo(gs.menuFrameCount, 0, 136, 50)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(screenWidth - highScoreBoxWidth, 26, highScoreBoxWidth + 5, 24, 5)
    gfx.setFont(assets.fonts.menu)
    gfx.drawText("New high score!", screenWidth - highScoreBoxWidth + 11, 29)
  end

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

  MenuBox.update()
end
