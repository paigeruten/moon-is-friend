local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

Sidebar = {}

local missionIconY = 6
local missionTextY = 35
local heartsY = 64
local goalY = 185
local scoreY = 205

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
  gs.missionIcon:draw(11, missionIconY)

  if gs.mission.winType == 'endless' then
    assets.gfx.endless:draw(12, missionTextY + 2)

    -- Score
    gfx.setFont(assets.fonts.small)
    gfx.drawText("Score", 6, scoreY)
    gfx.drawText("" .. gs.score, 6, scoreY + 13)
  else
    gfx.setFont(assets.fonts.small)
    gfx.drawText(gs.missionId, 14, missionTextY)

    -- Goal outline
    gfx.setColor(gfx.kColorBlack)
    -- gfx.drawRoundRect(3, goalY, 37, 47, 3)

    -- Goal
    local goal = gs.mission.winGoal
    local progress, progressText, leftText
    if gs.mission.winType == "asteroids" then
      progress = gs.asteroidsDiverted
      progressText = table.concat({ progress, '/', goal })
    elseif gs.mission.winType == "rocket" then
      progress = gs.rocketsCaught
      progressText = table.concat({ progress, '/', goal })
    elseif gs.mission.winType == "collide" then
      progress = gs.asteroidsCollided
      progressText = table.concat({ progress, '/', goal })
    elseif gs.mission.winType == "boss" then
      local bossHealth, bossMaxHealth = Target.totalHealth()
      goal = bossMaxHealth
      progress = bossMaxHealth - bossHealth
      progressText = table.concat({ bossHealth, ' HP' })
    elseif gs.mission.winType == "survive" then
      progress = gs.frameCount
      local totalSecondsLeft = math.max(0, goal - progress // 50)
      local minutesLeft = totalSecondsLeft // 60
      local secondsLeft = totalSecondsLeft % 60
      leftText = table.concat({ minutesLeft, ":", secondsLeft < 10 and "0" or "", secondsLeft })
      goal *= 50
    end
    gfx.setFont(assets.fonts.small)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    if leftText then
      gfx.drawText(leftText, 10, goalY + 17)
      gfx.drawText("Left", 10, goalY + 30)
    elseif progressText then
      gfx.drawTextAligned(progressText, (sidebarWidth - 4) // 2, goalY + 17, kTextAlignment.center)
    end

    -- Goal progress bar
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRoundRect(4, goalY + 4, 40, 10, 2)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(4, goalY + 4, 40, 10, 2)
    gfx.fillRoundRect(4, goalY + 4, progress / goal * 40, 10, 2)
  end

  -- Hearts
  gfx.setImageDrawMode(gfx.kDrawModeInverted)
  for i = 1, gs.earth.maxHealth do
    (gs.earth.health >= i and assets.gfx.heart or assets.gfx.heartEmpty):draw(10, heartsY + (i - 1) * 15)
  end

  -- Bombs
  for i = 1, gs.earth.bombs do
    assets.gfx.bomb:draw(28, heartsY + (i - 1) * 15)
  end
  gfx.setImageDrawMode(gfx.kDrawModeCopy)
end
