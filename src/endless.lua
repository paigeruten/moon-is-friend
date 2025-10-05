local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH

Endless = {}

function Endless.switch()
  gs.scene = 'endless'
  gs.frameCount = 0
  gs.endlessSelected = 'mode'
  gs.endlessMode = 'standard'
  gs.endlessMoons = 1
  gs.endlessAsteroids = 3
  Menu.reset()
end

local function arrowWrapIf(cond, str)
  if cond then
    return table.concat({ '<', str, '>' })
  else
    return table.concat({ ' ', str, ' ' })
  end
end

local boxX, boxY = 80, 50
local boxWidth, boxHeight = 240, 140

function Endless.update()
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

  local isModeUnlocked = SaveData.isAnyEndlessModeUnlocked(gs.endlessMode)
  local isUnlocked, requirement
  if gs.endlessMode == 'standard' then
    if gs.endlessMoons == 1 then
      gs.missionId = 'endless.s1'
    elseif gs.endlessMoons == 2 then
      gs.missionId = 'endless.s2'
    else
      gs.missionId = 'endless.s3'
    end
    isUnlocked, requirement = SaveData.isEndlessModeUnlocked('standard', gs.endlessMoons)
  else
    if gs.endlessAsteroids == 3 then
      gs.missionId = 'endless.j3'
    elseif gs.endlessAsteroids == 4 then
      gs.missionId = 'endless.j4'
    else
      gs.missionId = 'endless.j5'
    end
    isUnlocked, requirement = SaveData.isEndlessModeUnlocked('juggling', gs.endlessAsteroids)
  end

  if pd.buttonJustReleased(pd.kButtonB) then
    Title.switch()
    assets.sfx.boop:play()
  end

  if gs.endlessMode == 'standard' and not isModeUnlocked then
    gfx.setFont(assets.fonts.menu)
    gfx.drawText("Unlock Endless mode by\ncompleting mission 1-1!", boxX + 10, boxY + 10)
    gfx.drawTextAligned("Ⓑ Back", boxX + boxWidth - 10, boxY + boxHeight - 22, kTextAlignment.right)
    return
  end

  gfx.setFont(assets.fonts.menu)
  gfx.drawText("Endless", 213 - 26, boxY + 16)

  local otherText = gs.endlessMode == 'standard' and 'Moons' or 'Asteroids'
  if not isModeUnlocked then
    otherText = '???'
  end

  local modeText = gs.endlessMode == 'standard' and 'Standard' or 'Juggling'
  if not isModeUnlocked then
    modeText = '???'
  end

  gfx.setFont(assets.fonts.menu)
  local modeWidth, modeHeight = gfx.drawText("Game mode", boxX + 15, boxY + 50)
  local otherWidth, otherHeight = gfx.drawText(otherText, boxX + 15, boxY + 50 + 20)

  gfx.drawText(arrowWrapIf(gs.endlessSelected == 'mode', modeText), 220, boxY + 50)
  if gs.endlessMode == 'standard' then
    assets.gfx.missionIcons.asteroids:draw(213 - 30 - 26, boxY + 10)
    gfx.drawText(arrowWrapIf(gs.endlessSelected == 'other', isUnlocked and tostring(gs.endlessMoons) or '???'), 220,
      boxY + 50 + 20)
  else
    assets.gfx.missionIcons.collide:draw(213 - 30 - 26, boxY + 10)
    gfx.drawText(arrowWrapIf(gs.endlessSelected == 'other', isUnlocked and tostring(gs.endlessAsteroids) or '???'), 220,
      boxY + 50 + 20)
  end

  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.drawLine(boxX + 3, boxY + boxHeight - 35, boxX + boxWidth - 3, boxY + boxHeight - 35)

  gfx.setFont(assets.fonts.menu)
  local startText = isUnlocked and "Start" or "-Locked-"
  local startWidth, startHeight = gfx.drawText(startText, boxX + 15, boxY + boxHeight - 25)

  local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))

  if gs.endlessSelected == 'mode' then
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(boxX + 15, boxY + 50 + modeHeight + 4 + perlY, modeWidth, 3)

    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(boxX + 15, boxY + 50 + 20 + otherHeight + 2, otherWidth, 2)
    if isUnlocked then
      gfx.fillRect(boxX + 15, boxY + boxHeight - 25 + startHeight + 2, startWidth, 2)
    end
  elseif gs.endlessSelected == 'other' then
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(boxX + 15, boxY + 50 + 20 + otherHeight + 4 + perlY, otherWidth, 3)

    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(boxX + 15, boxY + 50 + modeHeight + 2, modeWidth, 2)
    if isUnlocked then
      gfx.fillRect(boxX + 15, boxY + boxHeight - 25 + startHeight + 2, startWidth, 2)
    end
  else
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(boxX + 15, boxY + boxHeight - 25 + startHeight + 4 + perlY, startWidth, 3)

    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(boxX + 15, boxY + 50 + modeHeight + 2, modeWidth, 2)
    gfx.fillRect(boxX + 15, boxY + 50 + 20 + otherHeight + 2, otherWidth, 2)
  end

  if isUnlocked then
    local highScore = SaveData.getHighScore(gs.missionId)
    if highScore then
      gfx.setFont(assets.fonts.small)
      local highScoreWidth = assets.fonts.small:getTextWidth("High score: " .. highScore)
      local _, highScoreHeight = gfx.drawText("High score: " .. highScore, boxX + boxWidth - 12 - highScoreWidth,
        boxY + boxHeight - 24)

      gfx.setColor(gfx.kColorBlack)
      gfx.drawRoundRect(boxX + boxWidth - 12 - 6 - highScoreWidth, boxY + boxHeight - 28, highScoreWidth + 10,
        highScoreHeight + 8, 3)
    end
  else
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(60, 215, 280, 30)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
    gfx.fillRect(60, 215, 280, 30)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(60 + 3, 215 + 3, 280 - 6, 30 - 6)

    gfx.setFont(assets.fonts.menu)
    gfx.drawTextAligned('Unlocked by completing mission ' .. requirement .. '.', screenWidth // 2, 222,
      kTextAlignment.center)
  end

  if pd.buttonJustPressed(pd.kButtonDown) then
    if gs.endlessSelected == 'mode' then
      gs.endlessSelected = 'other'
    elseif gs.endlessSelected == 'other' then
      gs.endlessSelected = isUnlocked and 'start' or 'mode'
    else
      gs.endlessSelected = 'mode'
    end
  elseif pd.buttonJustPressed(pd.kButtonUp) then
    if gs.endlessSelected == 'mode' then
      gs.endlessSelected = isUnlocked and 'start' or 'other'
    elseif gs.endlessSelected == 'other' then
      gs.endlessSelected = 'mode'
    else
      gs.endlessSelected = 'other'
    end
  end

  if pd.buttonJustPressed(pd.kButtonRight) then
    if gs.endlessSelected == 'mode' then
      if gs.endlessMode == 'standard' then
        gs.endlessMode = 'juggling'
      else
        gs.endlessMode = 'standard'
      end
    elseif gs.endlessSelected == 'other' then
      if gs.endlessMode == 'standard' then
        gs.endlessMoons += 1
        if gs.endlessMoons > 3 then
          gs.endlessMoons = 1
        end
      else
        gs.endlessAsteroids += 1
        if gs.endlessAsteroids > 5 then
          gs.endlessAsteroids = 3
        end
      end
    end
    assets.sfx.boop:play()
  elseif pd.buttonJustPressed(pd.kButtonLeft) then
    if gs.endlessSelected == 'mode' then
      if gs.endlessMode == 'standard' then
        gs.endlessMode = 'juggling'
      else
        gs.endlessMode = 'standard'
      end
    elseif gs.endlessSelected == 'other' then
      if gs.endlessMode == 'standard' then
        gs.endlessMoons -= 1
        if gs.endlessMoons == 0 then
          gs.endlessMoons = 3
        end
      else
        gs.endlessAsteroids -= 1
        if gs.endlessAsteroids < 3 then
          gs.endlessAsteroids = 5
        end
      end
    end
    assets.sfx.boop:play()
  end

  if pd.buttonJustReleased(pd.kButtonA) and isUnlocked and gs.endlessSelected == 'start' then
    gs.scene = 'game'
    Game.reset()
    assets.sfx.boop:play(77)
    Menu.addInGameMenuItems()
  end

  gs.frameCount += 1
end
