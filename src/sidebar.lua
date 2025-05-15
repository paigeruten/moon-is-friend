local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

Sidebar = {}

local missionIconY = 6
local missionTextY = 35
local goalY = 185
local difficultyY = 175
local scoreY = 205

function Sidebar.draw()
  local heartsY = gs.easyMode and 70 or 60

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
    gfx.drawText(gs.score, 6, scoreY + 13)

    -- Difficulty
    if gs.rampUpDifficulty and type(gs.difficulty) == 'table' then
      gfx.setFont(assets.fonts.small)
      gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
      gfx.drawText("Level", 6, difficultyY - 12)
      gfx.setImageDrawMode(gfx.kDrawModeCopy)

      local curLevel = math.min(50, math.floor(49 * gs.frameCount / 22500) + 1)
      gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
      gfx.drawText(curLevel, 6, difficultyY + 1)
      if curLevel >= 50 then
        gfx.drawText("Max", 6, difficultyY - 25)
      end
      gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
  else
    gfx.setFont(assets.fonts.small)
    gfx.drawText(gs.missionId, 14, missionTextY)

    if gs.easyMode then
      assets.gfx.easy:draw(13, missionTextY + 15)
    end

    if not (gs.mission.winType == 'boss' and gs.bossPhase == 0) then
      -- Goal outline
      gfx.setColor(gfx.kColorBlack)
      -- gfx.drawRoundRect(3, goalY, 37, 47, 3)

      -- Goal
      local goal = gs.mission.winGoal
      local progress, progressText, leftText, label
      if gs.mission.winType == "asteroids" then
        progress = math.min(goal, gs.asteroidsDiverted)
        progressText = table.concat({ progress, '/', goal })
        label = assets.gfx.labelMeteors
      elseif gs.mission.winType == "rocket" then
        progress = math.min(goal, gs.rocketsCaught)
        progressText = table.concat({ progress, '/', goal })
        label = assets.gfx.labelRockets
      elseif gs.mission.winType == "collide" then
        progress = math.min(goal, gs.asteroidsCollided)
        progressText = table.concat({ progress, '/', goal })
        label = assets.gfx.labelCollisions
      elseif gs.mission.winType == "boss" then
        local bossHealth = Target.totalHealth()
        goal = gs.bossMaxHealth
        progress = bossHealth
        progressText = table.concat({ bossHealth, 'hp' })
      elseif gs.mission.winType == "survive" then
        progress = math.min(goal * 50, gs.surviveFrameCount)
        local totalSecondsLeft = goal - progress // 50
        local minutesLeft = totalSecondsLeft // 60
        local secondsLeft = totalSecondsLeft % 60
        leftText = table.concat({ minutesLeft, ":", secondsLeft < 10 and "0" or "", secondsLeft })
        goal *= 50

        if gs.surviveFrameCount % 50 == 0 and totalSecondsLeft > 0 and totalSecondsLeft <= 5 then
          assets.sfx.boop:play(60, 0.25)
        end
      end
      gfx.setFont(assets.fonts.small)
      gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
      if leftText then
        gfx.drawText(leftText, 10, goalY + 17)
        gfx.drawText("Left", 10, goalY + 30)
      elseif progressText then
        gfx.drawTextAligned(progressText, (sidebarWidth - 4) // 2, goalY + 17, kTextAlignment.center)
      end
      if gs.mission.winType == "boss" then
        gfx.drawText("Boss", 9, goalY - 12)
      end
      if label then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        label:drawAnchored((sidebarWidth - 4) // 2, goalY + 32, 0.5, 0.0)
      end

      -- Goal progress bar
      gfx.setColor(gfx.kColorBlack)
      gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
      gfx.fillRoundRect(4, goalY + 4, 40, 10, 2)
      gfx.setColor(gfx.kColorBlack)
      gfx.drawRoundRect(4, goalY + 4, 40, 10, 2)
      gfx.fillRoundRect(4, goalY + 4, progress / goal * 40, 10, 2)
    end
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

  -- Extra suction fuel
  if gs.earth.maxBombs == 0 then
    local height = 43
    local fuelHeight = math.floor(height * gs.extraSuctionFuel / gs.extraSuctionMaxFuel)
    local isReady = gs.extraSuctionFuel == gs.extraSuctionMaxFuel or gs.extraSuction
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(isReady and 2 or 1)
    gfx.setStrokeLocation(gfx.kStrokeInside)
    gfx.drawRoundRect(28, heartsY, 12, height, 3)
    gfx.setLineWidth(1)
    gfx.setStrokeLocation(gfx.kStrokeCentered)
    gfx.setDitherPattern(0.6, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRoundRect(28, heartsY + (height - fuelHeight), 12, fuelHeight, 3)
  end
end
