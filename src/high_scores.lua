local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local scoreboardsEnabled = SCOREBOARDS_ENABLED

HighScores = {}

local pages = {
  {
    type = 'local',
  },
  {
    type = 'global',
    boardId = 'endless1moon',
    mode = 'standard',
    desc = 'Endless, 1 moon',
    isUnlocked = function() SaveData.isEndlessModeUnlocked('standard', 1) end
  },
  {
    type = 'global',
    boardId = 'endless2moon',
    mode = 'standard',
    desc = 'Endless, 2 moons',
    isUnlocked = function() SaveData.isEndlessModeUnlocked('standard', 2) end
  },
  {
    type = 'global',
    boardId = 'endless3moon',
    mode = 'standard',
    desc = 'Endless, 3 moons',
    isUnlocked = function() SaveData.isEndlessModeUnlocked('standard', 3) end
  },
  {
    type = 'global',
    boardId = 'juggling3meteor',
    mode = 'juggling',
    desc = 'Juggling, 3 meteors',
    isUnlocked = function() SaveData.isEndlessModeUnlocked('juggling', 3) end
  },
  {
    type = 'global',
    boardId = 'juggling4meteor',
    mode = 'juggling',
    desc = 'Jugging, 4 meteors',
    isUnlocked = function() SaveData.isEndlessModeUnlocked('juggling', 4) end
  },
  {
    type = 'global',
    boardId = 'juggling5meteor',
    mode = 'juggling',
    desc = 'Juggling, 5 meteors',
    isUnlocked = function() SaveData.isEndlessModeUnlocked('juggling', 5) end
  },
}

-- Ensures scoreboards are fetched sequentially
-- See: https://devforum.play.date/t/calling-scoreboards-on-difrent-boardids-at-once-only-returns-the-first/16379/9
local scoreboardRequests = {}
local function requestScoreboard(name, callback)
  scoreboardRequests[#scoreboardRequests + 1] = { name, callback }

  local function getNextRequest()
    pd.scoreboards.getScores(scoreboardRequests[1][1], function(boardId, score)
      scoreboardRequests[1][2](boardId, score)
      table.remove(scoreboardRequests, 1)
      if #scoreboardRequests >= 1 then
        getNextRequest()
      end
    end)
  end

  if #scoreboardRequests == 1 then getNextRequest() end
end

local fakePlayers = {
  "alex",
  "sam",
  "Taylor89",
  "joey",
  "river",
  "quinn",
  "pailey",
  "morgan",
  "casey_k",
  "avery",
  "jordan",
  "skye42",
  "Drew!",
  "charlie",
  "RoWaN",
  "blake",
  "dakota#7",
  "reese",
  "phoenix",
  "2482053772263622"
}
local function fakeScores()
  local scores = {}
  local players = { table.unpack(fakePlayers) }
  local currentValue = math.random(100, 300)

  for i = 1, math.random(0, 10) do
    scores[i] = {
      rank = (i == 10) and math.random(10, 999) or i,
      player = table.remove(players, math.random(#players)),
      value = currentValue
    }
    currentValue -= math.random(1, 10)
  end

  return scores
end

function HighScores.switch()
  gs.scene = 'high-scores'
  gs.highScorePage = 1
  if scoreboardsEnabled then
    for _, page in ipairs(pages) do
      if page.type == 'global' then
        page.loading = true
        page.scores = {}
        page.error = nil
        (function(currentPage)
          requestScoreboard(currentPage.boardId, function(status, result)
            currentPage.loading = false
            if status.code == 'OK' then
              currentPage.scores = fakeScores() --result.scores
            else
              currentPage.error = status.message
            end
          end)
        end)(page)
      end
    end
  end
  Menu.reset()
end

local baseBoxX, baseBoxY = 30, 5
local boxWidth, boxHeight = 340, 230

local moonText = { [1] = "One moon:", [2] = "Two moons:", [3] = "Three moons:" }
local asteroidText = { [3] = "Three meteors:", [4] = "Four meteors:", [5] = "Five meteors:" }

local function drawBox(boxX, boxY)
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)
  gfx.setFont(assets.fonts.menu)

  if scoreboardsEnabled then
    gfx.drawText("⬅️ Previous", boxX + 20, boxY + boxHeight - 22)
    gfx.drawTextAligned("Next ➡️", boxX + boxWidth - 20, boxY + boxHeight - 22,
      kTextAlignment.right)
  else
    gfx.drawTextAligned("Ⓐ Done", boxX + boxWidth - 10, boxY + boxHeight - 22, kTextAlignment.right)
  end
end

local function drawLocalPage(boxX, boxY)
  drawBox(boxX, boxY)

  gfx.setFont(assets.fonts.large)
  gfx.drawTextAligned("*Local High Scores*", boxX + boxWidth // 2, boxY + 12, kTextAlignment.center)

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(boxX + 169, boxY + 50, 2, boxHeight - 40 - 44)

  local standardColX = boxX + 55
  local jugglingColX = boxX + 225

  gfx.setFont(assets.fonts.menu)
  local standardWidth, _ = gfx.drawText("Standard", standardColX, boxY + 78)
  local jugglingWidth, _ = gfx.drawText(SaveData.isAnyEndlessModeUnlocked('juggling') and "Juggling" or "???",
    jugglingColX, boxY + 78)

  assets.gfx.missionIcons.asteroids:drawAnchored(standardColX + standardWidth // 2, boxY + 50, 0.5, 0)
  assets.gfx.missionIcons.collide:drawAnchored(jugglingColX + jugglingWidth // 2, boxY + 50, 0.5, 0)

  gfx.setFont(assets.fonts.small)
  for numMoons = 1, 3 do
    local isUnlocked = SaveData.isEndlessModeUnlocked('standard', numMoons)
    local text, score
    if isUnlocked then
      text = moonText[numMoons]
      score = tostring(SaveData.getHighScore("endless.s" .. numMoons) or "(n/a)")
    else
      text = "???:"
      score = "(n/a)"
    end
    gfx.drawText(text, boxX + 15, boxY + 110 + 20 * (numMoons - 1))
    gfx.drawTextAligned(score, boxX + boxWidth // 2 - 15, boxY + 110 + 20 * (numMoons - 1), kTextAlignment.right)
  end
  for numAsteroids = 3, 5 do
    local isUnlocked = SaveData.isEndlessModeUnlocked('juggling', numAsteroids)
    local text, score
    if isUnlocked then
      text = asteroidText[numAsteroids]
      score = tostring(SaveData.getHighScore("endless.j" .. numAsteroids) or "(n/a)")
    else
      text = "???:"
      score = "(n/a)"
    end
    gfx.drawText(text, boxX + boxWidth // 2 + 15, boxY + 110 + 20 * (numAsteroids - 3))
    gfx.drawTextAligned(score, boxX + boxWidth - 15, boxY + 110 + 20 * (numAsteroids - 3), kTextAlignment.right)
  end
end

local function drawGlobalPage(page, boxX, boxY)
  drawBox(boxX, boxY)

  gfx.setFont(assets.fonts.large)
  gfx.drawTextAligned("*Global High Scores* (" .. page.desc .. ")", boxX + boxWidth // 2, boxY + 12,
    kTextAlignment.center)

  gfx.setFont(assets.fonts.small)
  if page.loading then
    gfx.drawTextAligned('Loading...', boxX + boxWidth // 2, screenHeight // 2, kTextAlignment.center)
  elseif page.error then
    gfx.drawTextAligned('Error: ' .. page.error, boxX + boxWidth // 2, screenHeight // 2, kTextAlignment.center)
  elseif #page.scores == 0 then
    gfx.drawTextAligned('No scores here yet!', boxX + boxWidth // 2, screenHeight // 2, kTextAlignment.center)
  else
    for idx = 1, 10 do
      local score = page.scores[idx]
      local player = (score and score.player) or ''
      local value = (score and score.value) or '--'
      local rank = (score and score.rank) or idx

      assets.fonts.small:drawText('' .. rank .. '. ' .. player, boxX + 40, boxY + 25 + 16 * idx)
      gfx.drawTextAligned(value, boxX + boxWidth - 40, boxY + 25 + 16 * idx, kTextAlignment.right)
    end
  end
end

local function drawPage(page, boxX, boxY)
  if page.type == 'local' then
    drawLocalPage(boxX, boxY)
  else
    drawGlobalPage(page, boxX, boxY)
  end
end

function HighScores.update()
  gfx.clear()

  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star.x, star.y)
  end

  local page = pages[gs.highScorePage]

  drawPage(page, baseBoxX, baseBoxY)

  if scoreboardsEnabled then
    local rightPage = pages[gs.highScorePage + 1] or pages[1]
    drawPage(rightPage, screenWidth - 12, baseBoxY)

    local leftPage = pages[gs.highScorePage - 1] or pages[#pages]
    drawPage(leftPage, 12 - boxWidth, baseBoxY)
  end

  if scoreboardsEnabled then
    if pd.buttonJustPressed(pd.kButtonRight) then
      gs.highScorePage += 1
      if gs.highScorePage > #pages then
        gs.highScorePage = 1
      end
      assets.sfx.boop:play()
    end
    if pd.buttonJustPressed(pd.kButtonLeft) then
      gs.highScorePage -= 1
      if gs.highScorePage == 0 then
        gs.highScorePage = #pages
      end
      assets.sfx.boop:play()
    end
  end

  if pd.buttonJustReleased(pd.kButtonA) or pd.buttonJustReleased(pd.kButtonB) then
    Title.switch()
    assets.sfx.boop:play()
  end
end
