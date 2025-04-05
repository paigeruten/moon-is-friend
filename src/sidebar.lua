local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

Sidebar = {}

function Sidebar.draw()
  -- Sidebar
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(sidebarWidth - 8, 0, 8, screenHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(sidebarWidth - 8, 0, 8, screenHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0, 0, sidebarWidth - 4, screenHeight)

  -- Mission icon
  assets.gfx.missionIcons[gs.mission.winType]:draw(9, 6)

  -- Hearts
  gfx.setImageDrawMode(gfx.kDrawModeInverted)
  for i = 1, gs.earth.maxHealth do
    (gs.earth.health >= i and assets.gfx.heart or assets.gfx.heartEmpty):draw(8, 42 + (i - 1) * 15)
  end

  -- Bombs
  for i = 1, gs.earth.bombs do
    assets.gfx.bomb:draw(26, 42 + (i - 1) * 15)
  end
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  -- Time
  local totalSecondsElapsed = gs.frameCount // 50
  local minutesElapsed = totalSecondsElapsed // 60
  local secondsElapsed = totalSecondsElapsed % 60
  local timeElapsed = table.concat({ minutesElapsed, ":", secondsElapsed < 10 and "0" or "", secondsElapsed })
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.drawText(timeElapsed, 7, 180)
  gfx.drawText("TIME", 7, 190)

  -- Score
  gfx.setFont(assets.fonts.small)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.drawText("" .. gs.score, 7, 215)
  gfx.drawText("PTS", 7, 225)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)
end
