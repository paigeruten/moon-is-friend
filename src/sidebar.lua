local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

Sidebar = {}

local missionIconY = 6
local missionTextY = 35
local goalY = 59
local heartsY = 110

function Sidebar.draw()
  -- Sidebar
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(sidebarWidth - 8, 0, 8, screenHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(sidebarWidth - 8, 0, 8, screenHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0, 0, sidebarWidth - 4, screenHeight)

  -- Mission / game mode
  assets.gfx.missionIcons[gs.mission.winType]:draw(9, missionIconY)
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.drawText('LVL', 12, missionTextY)
  gfx.drawText(gs.missionId, 12, missionTextY + 10)

  -- Goal outline
  gfx.setColor(gfx.kColorBlack)
  gfx.drawRoundRect(3, goalY, 37, 40, 3)

  -- Goal
  local goal = gs.mission.winGoal
  local progress, left
  if gs.mission.winType == "asteroids" then
    progress = gs.asteroidsDiverted
    left = tostring(math.max(0, goal - progress))
  elseif gs.mission.winType == "rocket" then
    progress = gs.rocketsCaught
    left = tostring(math.max(0, goal - progress))
  elseif gs.mission.winType == "collide" then
    progress = gs.asteroidsCollided
    left = tostring(math.max(0, goal - progress))
  elseif gs.mission.winType == "boss" then
    progress = 0
    left = tostring(math.max(0, goal))
  elseif gs.mission.winType == "survive" then
    progress = gs.frameCount
    local totalSecondsLeft = math.max(0, goal - progress // 50)
    local minutesLeft = totalSecondsLeft // 60
    local secondsLeft = totalSecondsLeft % 60
    left = table.concat({ minutesLeft, ":", secondsLeft < 10 and "0" or "", secondsLeft })
    goal *= 50
  end
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.drawText(left, 7, goalY + 19)
  gfx.drawText("LEFT", 7, goalY + 29)

  -- Goal progress bar
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillRoundRect(7, goalY + 4, 30, 10, 2)
  gfx.setColor(gfx.kColorBlack)
  gfx.drawRoundRect(7, goalY + 4, 30, 10, 2)
  gfx.fillRoundRect(7, goalY + 4, progress / goal * 30, 10, 2)

  -- Hearts
  gfx.setImageDrawMode(gfx.kDrawModeInverted)
  for i = 1, gs.earth.maxHealth do
    (gs.earth.health >= i and assets.gfx.heart or assets.gfx.heartEmpty):draw(8, heartsY + (i - 1) * 15)
  end

  -- Bombs
  for i = 1, gs.earth.bombs do
    assets.gfx.bomb:draw(26, heartsY + (i - 1) * 15)
  end
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  -- Score
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.drawText("" .. gs.score, 7, 215)
  gfx.drawText("PTS", 7, 225)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)
end
