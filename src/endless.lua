local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT

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

local boxX, boxY = 80, 60
local boxWidth, boxHeight = 240, 120

function Endless.update()
  gfx.clear()

  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star)
  end

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)

  gfx.setFont(assets.fonts.small)
  local modeWidth, modeHeight = gfx.drawText("Game Mode", boxX + 15, boxY + 50)
  local otherWidth, _ = gfx.drawText(gs.endlessMode == 'standard' and 'Moons' or 'Asteroids', boxX + 15, boxY + 50 + 20)

  gfx.drawText(arrowWrapIf(gs.endlessSelected == 'mode', gs.endlessMode == 'standard' and 'Standard' or 'Juggling'), 220,
    boxY + 50)
  if gs.endlessMode == 'standard' then
    assets.gfx.missionIcons.asteroids:draw(200 - 13, boxY + 10)
    gfx.drawText(arrowWrapIf(gs.endlessSelected == 'other', tostring(gs.endlessMoons)), 220, boxY + 50 + 20)
  else
    assets.gfx.missionIcons.collide:draw(200 - 13, boxY + 10)
    gfx.drawText(arrowWrapIf(gs.endlessSelected == 'other', tostring(gs.endlessAsteroids)), 220, boxY + 50 + 20)
  end

  local selectedWidth, selectedY
  if gs.endlessSelected == 'mode' then
    selectedWidth = modeWidth
    selectedY = boxY + 50
  else
    selectedWidth = otherWidth
    selectedY = boxY + 50 + 20
  end
  local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(boxX + 15, selectedY + modeHeight + 4 + perlY, selectedWidth, 2)

  gfx.setFont(assets.fonts.large)
  gfx.drawText("Ⓐ", boxX + boxWidth - 67, boxY + boxHeight - 25)
  gfx.setFont(assets.fonts.small)
  gfx.drawText("Start", boxX + boxWidth - 45, boxY + boxHeight - 19)

  if pd.buttonJustPressed(pd.kButtonDown) or pd.buttonJustPressed(pd.kButtonUp) then
    if gs.endlessSelected == 'mode' then
      gs.endlessSelected = 'other'
    else
      gs.endlessSelected = 'mode'
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

  if pd.buttonJustReleased(pd.kButtonA) then
    gs.scene = 'game'
    if gs.endlessMode == 'standard' then
      if gs.endlessMoons == 1 then
        gs.missionId = 'endless.s1'
      elseif gs.endlessMoons == 2 then
        gs.missionId = 'endless.s2'
      else
        gs.missionId = 'endless.s3'
      end
    else
      if gs.endlessAsteroids == 3 then
        gs.missionId = 'endless.j3'
      elseif gs.endlessAsteroids == 4 then
        gs.missionId = 'endless.j4'
      else
        gs.missionId = 'endless.j5'
      end
    end
    Game.reset()
    assets.sfx.boop:play(77)
    Menu.addInGameMenuItems()
  end

  if pd.buttonJustReleased(pd.kButtonB) then
    Title.switch()
    assets.sfx.boop:play()
  end

  gs.frameCount += 1
end
