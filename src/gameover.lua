local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

GameOver = {}

function GameOver.update()
  if gs.isHighScore then
    local highScoreBoxWidth = pd.easingFunctions.outExpo(gs.frameCount, 0, 136, 50)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(screenWidth - highScoreBoxWidth, 26, highScoreBoxWidth + 5, 24, 5)
    gfx.setFont(assets.fonts.large)
    gfx.drawText("New high score!", screenWidth - highScoreBoxWidth + 11, 29)
  end

  local gameoverBoxHeight = pd.easingFunctions.outExpo(gs.frameCount, 0, 32, 50)
  local gameoverBoxLeft = sidebarWidth + 32
  local gameoverBoxWidth = screenWidth - gameoverBoxLeft
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(gameoverBoxLeft, screenHeight - gameoverBoxHeight, gameoverBoxWidth, gameoverBoxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(gameoverBoxLeft + 4, screenHeight - gameoverBoxHeight + 4, gameoverBoxWidth - 4, gameoverBoxHeight - 4)
  gfx.setFont(assets.fonts.large)
  gfx.drawText("*Game Over*", gameoverBoxLeft + 20, screenHeight - gameoverBoxHeight + 9)

  gfx.setFont(assets.fonts.small)
  local optionY = screenHeight - gameoverBoxHeight + 15
  local retryX = screenWidth // 2 + 16
  local backX = screenWidth // 2 + 80
  local retryWidth, retryHeight = gfx.drawText("Retry", retryX, optionY)
  local backWidth, backHeight = gfx.drawText("Back to title", backX, optionY)

  local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
  gfx.setColor(gfx.kColorBlack)
  if gs.gameoverSelection == 'retry' then
    gfx.fillRect(retryX, optionY + retryHeight + 4 + perlY, retryWidth, 2)
  else
    gfx.fillRect(backX, optionY + backHeight + 4 + perlY, backWidth, 2)
  end

  if pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
    if gs.gameoverSelection == 'retry' then
      gs.gameoverSelection = 'back'
    else
      gs.gameoverSelection = 'retry'
    end
    assets.sfx.boop:play()
  end

  if pd.buttonJustReleased(pd.kButtonA) then
    if gs.gameoverSelection == 'retry' then
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
