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

local menuBoxWidth = 200
local menuBoxHeight = 50
local menuBoxCenterX = sidebarWidth + (screenWidth - sidebarWidth) // 2
local menuBoxX = menuBoxCenterX - menuBoxWidth // 2

function GameEnd.update()
  -- Todo: move to bottom left
  if gs.isHighScore then
    local highScoreBoxWidth = pd.easingFunctions.outExpo(gs.menuFrameCount, 0, 136, 50)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(screenWidth - highScoreBoxWidth, 26, highScoreBoxWidth + 5, 24, 5)
    gfx.setFont(assets.fonts.large)
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

  local menuBoxY = pd.easingFunctions.outExpo(gs.menuFrameCount, screenHeight, -80, 50)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(menuBoxX, menuBoxY, menuBoxWidth, menuBoxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(menuBoxX + 3, menuBoxY + 3, menuBoxWidth - 6, menuBoxHeight - 6)

  gfx.setFont(assets.fonts.small)
  local retryText = "Retry"
  local backText = (gs.endState == "game-over" and "Back to title" or "Back to missions")
  local retryWidth, retryHeight = gfx.getTextSize(retryText)
  local backWidth, backHeight = gfx.getTextSize(backText)
  local retryX = menuBoxCenterX - retryWidth // 2
  local retryY = menuBoxY + 10
  local backX = menuBoxCenterX - backWidth // 2
  local backY = retryY + 20
  gfx.drawText(retryText, retryX, retryY)
  gfx.drawText(backText, backX, backY)

  local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.menuFrameCount % 100) / 100, 0, 0) * 20 - 10))
  gfx.setColor(gfx.kColorBlack)
  if gs.gameoverSelection == 'retry' then
    gfx.fillRect(retryX, retryY + retryHeight + 4 + perlY, retryWidth, 2)
  else
    gfx.fillRect(backX, backY + backHeight + 4 + perlY, backWidth, 2)
  end

  if pd.buttonJustPressed(pd.kButtonDown) or pd.buttonJustPressed(pd.kButtonUp) then
    if gs.gameoverSelection == 'retry' then
      gs.gameoverSelection = 'back'
    else
      gs.gameoverSelection = 'retry'
    end
    assets.sfx.boop:play()
  end

  if pd.buttonJustReleased(pd.kButtonA) then
    if gs.gameoverSelection == 'back' then
      if gs.endState == "game-over" then
        gs.scene = 'title'
      else
        gs.scene = 'mission-tree'
      end
      Menu.reset()
    end

    Game.reset()
    assets.sfx.boop:play(77)
  end

  gs.menuFrameCount += 1
end
