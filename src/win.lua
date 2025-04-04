local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

Win = {}

function Win.update()
  local winBoxHeight = pd.easingFunctions.outExpo(gs.frameCount, 0, 32, 50)
  local winBoxLeft = sidebarWidth + 32
  local winBoxWidth = screenWidth - winBoxLeft
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(winBoxLeft, screenHeight - winBoxHeight, winBoxWidth, winBoxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(winBoxLeft + 4, screenHeight - winBoxHeight + 4, winBoxWidth - 4, winBoxHeight - 4)
  gfx.setFont(assets.fonts.large)
  gfx.drawText("*Mission Complete!*", winBoxLeft + 20, screenHeight - winBoxHeight + 9)

  gfx.setFont(assets.fonts.small)
  local optionY = screenHeight - winBoxHeight + 15
  local retryX = screenWidth // 2 + 16
  local backX = screenWidth // 2 + 80
  local retryWidth, retryHeight = gfx.drawText("Retry", retryX, optionY)
  local backWidth, backHeight = gfx.drawText("Back to title", backX, optionY)

  local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
  gfx.setColor(gfx.kColorBlack)
  if gs.winSelection == 'retry' then
    gfx.fillRect(retryX, optionY + retryHeight + 4 + perlY, retryWidth, 2)
  else
    gfx.fillRect(backX, optionY + backHeight + 4 + perlY, backWidth, 2)
  end

  if pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
    if gs.winSelection == 'retry' then
      gs.winSelection = 'back'
    else
      gs.winSelection = 'retry'
    end
    assets.sfx.boop:play()
  end

  if pd.buttonJustReleased(pd.kButtonA) then
    if gs.winSelection == 'retry' then
      gs.scene = 'game'
    else
      gs.scene = 'title'
      Menu.reset()
    end

    Game.reset()
    assets.sfx.boop:play(77)
  end
  gs.frameCount += 1
end
