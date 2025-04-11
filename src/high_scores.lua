local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH

HighScores = {}

function HighScores.switch()
  gs.scene = 'high-scores'
  Menu.reset()
end

local boxX, boxY = 30, 20
local boxWidth, boxHeight = 340, 200

local moonText = { [1] = "One moon:", [2] = "Two moons:", [3] = "Three moons:" }
local asteroidText = { [3] = "Three meteors:", [4] = "Four meteors:", [5] = "Five meteors:" }

function HighScores.update()
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

  gfx.setFont(assets.fonts.large)
  gfx.drawTextAligned("*High Scores*", screenWidth // 2, boxY + 12, kTextAlignment.center)

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(199, boxY + 40, 2, boxHeight - 40 - 44)

  local standardColX = 85
  local jugglingColX = 255

  gfx.setFont(assets.fonts.menu)
  local standardWidth, _ = gfx.drawText("Standard", standardColX, boxY + 68)
  local jugglingWidth, _ = gfx.drawText("Juggling", jugglingColX, boxY + 68)

  assets.gfx.missionIcons.asteroids:drawAnchored(standardColX + standardWidth // 2, boxY + 40, 0.5, 0)
  assets.gfx.missionIcons.collide:drawAnchored(jugglingColX + jugglingWidth // 2, boxY + 40, 0.5, 0)

  gfx.setFont(assets.fonts.small)
  for numMoons = 1, 3 do
    gfx.drawText(moonText[numMoons], boxX + 15, boxY + 100 + 20 * (numMoons - 1))
    gfx.drawTextAligned(tostring(SaveData.getHighScore("endless.s" .. numMoons) or "(n/a)"), screenWidth // 2 - 15,
      boxY + 100 + 20 * (numMoons - 1),
      kTextAlignment.right)
  end
  for numAsteroids = 3, 5 do
    gfx.drawText(asteroidText[numAsteroids], screenWidth // 2 + 15,
      boxY + 100 + 20 * (numAsteroids - 3))
    gfx.drawTextAligned(tostring(SaveData.getHighScore("endless.j" .. numAsteroids) or "(n/a)"), boxX + boxWidth - 15,
      boxY + 100 + 20 * (numAsteroids - 3),
      kTextAlignment.right)
  end

  gfx.setFont(assets.fonts.menu)
  gfx.drawTextAligned("Ⓐ Done", boxX + boxWidth - 10, boxY + boxHeight - 22, kTextAlignment.right)

  if pd.buttonJustReleased(pd.kButtonA) or pd.buttonJustReleased(pd.kButtonB) then
    Title.switch()
    assets.sfx.boop:play()
  end
end
