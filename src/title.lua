local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT

Title = {}

function Title.switch()
  gs.scene = 'title'
  gs.frameCount = 0
  Menu.reset()
  MenuBox.init({ 'Missions', 'Endless', 'High scores', 'Help' }, { width = 120 }, function(selected)
    if selected == 1 then
      MissionTree.switch()
      MissionTree.selectNextMission()
      assets.sfx.boop:play()
    elseif selected == 2 then
      gs.scene = 'game'
      gs.missionId = 'endless.s1'
      Game.reset()
      Menu.addInGameMenuItems()
      assets.sfx.boop:play()
    elseif selected == 4 then
      gs.scene = 'story'
      gs.frameCount = 0
      assets.sfx.boop:play()
    end
  end)
end

function Title.update()
  gfx.clear()

  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star)
  end

  local animFrame = math.min(gs.frameCount, 700)

  -- Earth
  local earthX, earthY = screenWidth - 60, screenHeight // 4
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.45, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthX, earthY, 20)

  -- Earth eyes
  local leftEye = pd.geometry.point.new(earthX - 7, earthY - 7)
  local rightEye = pd.geometry.point.new(earthX + 7, earthY - 7)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(leftEye, 5)
  gfx.fillCircleAtPoint(rightEye, 5)
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(leftEye, 2)
  gfx.fillCircleAtPoint(rightEye, 2)

  -- Moon
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(screenWidth / 3 + animFrame / 10, screenHeight * 2 / 3 - animFrame / 20, screenWidth / 3)

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRoundRect(screenWidth // 4, screenHeight // 4 - 4, screenWidth // 2, 24, 5)

  gfx.setFont(assets.fonts.large)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawTextAligned("*The Moon is our Friend*", screenWidth // 2, screenHeight // 4, kTextAlignment.center)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  -- local perlY = math.min(3, math.max(-3, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
  -- gfx.setColor(gfx.kColorWhite)
  -- gfx.fillRoundRect(screenWidth // 2 - 70, screenHeight - screenHeight // 4 - 5 + perlY, 140, 17, 5)
  -- gfx.setColor(gfx.kColorBlack)
  -- gfx.drawRoundRect(screenWidth // 2 - 70, screenHeight - screenHeight // 4 - 5 + perlY, 140, 17, 5)
  -- gfx.setFont(assets.fonts.small)
  -- gfx.drawTextAligned("Press A to start", screenWidth // 2, screenHeight - screenHeight // 4 + perlY,
  --   kTextAlignment.center)

  MenuBox.update()

  if SaveData.data.highScore > 0 then
    local hasStar = SaveData.data.highScore >= STAR_SCORE
    gfx.setFont(assets.fonts.small)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned("High score\n" .. SaveData.data.highScore .. (hasStar and "  " or ""), screenWidth - 7,
      screenHeight - 30,
      kTextAlignment.right,
      8)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    if hasStar then
      assets.gfx.star:draw(screenWidth - 19, screenHeight - 18)
    end
  end

  gs.frameCount += 1
end
