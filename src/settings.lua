local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH

Settings = {}

function Settings.switch()
  gs.scene = 'settings'
  gs.frameCount = 0
  gs.settingsSelected = 'paths'
  Menu.reset()
end

local boxX, boxY = 80, 60
local boxWidth, boxHeight = 240, 120

function Settings.update()
  gfx.clear()

  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star.x, star.y)
  end

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)

  gfx.setFont(assets.fonts.menu)
  gfx.drawTextAligned("Settings", boxX + boxWidth // 2, boxY + 16, kTextAlignment.center)

  local checkboxX, pathsCheckboxY = boxX + 15, boxY + 50
  local checkboxWidth = 12
  local checkboxSpacing = 23

  if SaveData.getShowAsteroidPaths() then
    assets.gfx.checkmark:draw(checkboxX, pathsCheckboxY)
  else
    assets.gfx.noCheckmark:draw(checkboxX, pathsCheckboxY)
  end

  gfx.setFont(assets.fonts.small)
  local pathsWidth, pathsHeight = gfx.drawText('Show asteroid paths', checkboxX + checkboxWidth + 5, pathsCheckboxY - 1)

  local shakeCheckboxY = pathsCheckboxY + checkboxSpacing
  if SaveData.isScreenShakeEnabled() then
    assets.gfx.checkmark:draw(checkboxX, shakeCheckboxY)
  else
    assets.gfx.noCheckmark:draw(checkboxX, shakeCheckboxY)
  end

  gfx.setFont(assets.fonts.small)
  local shakeWidth, shakeHeight = gfx.drawText('Screen shake', checkboxX + checkboxWidth + 5, shakeCheckboxY - 1)

  local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
  if gs.settingsSelected == 'paths' then
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(checkboxX + checkboxWidth + 5, pathsCheckboxY - 2 + pathsHeight + 4 + perlY, pathsWidth, 3)

    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(checkboxX + checkboxWidth + 5, shakeCheckboxY - 2 + shakeHeight + 2, shakeWidth, 2)

    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(60, 215, 280, 30)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
    gfx.fillRect(60, 215, 280, 30)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(60 + 3, 215 + 3, 280 - 6, 30 - 6)

    gfx.setFont(assets.fonts.menu)
    gfx.drawTextAligned('Turn off paths to improve performance.', screenWidth // 2, 222,
      kTextAlignment.center)
  else
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(checkboxX + checkboxWidth + 5, shakeCheckboxY - 2 + shakeHeight + 4 + perlY, shakeWidth, 3)

    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(checkboxX + checkboxWidth + 5, pathsCheckboxY - 2 + pathsHeight + 2, pathsWidth, 2)
  end

  gfx.setFont(assets.fonts.menu)
  gfx.drawTextAligned("Ⓑ Back", boxX + boxWidth - 10, boxY + boxHeight - 24, kTextAlignment.right)

  if pd.buttonJustPressed(pd.kButtonDown) or pd.buttonJustPressed(pd.kButtonUp) then
    if gs.settingsSelected == 'paths' then
      gs.settingsSelected = 'shake'
    else
      gs.settingsSelected = 'paths'
    end
  end

  if pd.buttonJustReleased(pd.kButtonA) then
    if gs.settingsSelected == 'paths' then
      SaveData.setShowAsteroidPaths(not SaveData.getShowAsteroidPaths())
      Menu.showPathsItem:setValue(SaveData.getShowAsteroidPaths())
    else
      SaveData.setScreenShakeEnabled(not SaveData.isScreenShakeEnabled())
    end
    assets.sfx.boop:play()
  end

  if pd.buttonJustReleased(pd.kButtonB) then
    Title.switch()
    assets.sfx.boop:play()
  end

  gs.frameCount += 1
end
