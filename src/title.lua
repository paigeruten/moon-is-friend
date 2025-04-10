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
      Endless.switch()
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
  local earthPos = pd.geometry.point.new(screenWidth - 60, screenHeight // 4)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthPos, 28)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(-2, -2), 28 - 4)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(-4, -4), 28 - 8)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(-18, -18), 6)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(-18, 6), 8)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(-6, 12), 8)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(10, -18), 8)
  gfx.setDitherPattern(0.6, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(16, 12), 8)
  gfx.fillCircleAtPoint(earthPos + pd.geometry.vector2D.new(18, 8), 8)

  -- Earth eyes
  local leftEye = pd.geometry.point.new(earthPos.x - 10, earthPos.y - 10)
  local rightEye = pd.geometry.point.new(earthPos.x + 10, earthPos.y - 10)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(leftEye, 10)
  gfx.fillCircleAtPoint(rightEye, 10)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer8x8)
  gfx.drawCircleAtPoint(leftEye, 10)
  gfx.drawCircleAtPoint(rightEye, 10)
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(leftEye, 4)
  gfx.fillCircleAtPoint(rightEye, 4)

  -- Moon
  local moonPos = pd.geometry.point.new(screenWidth / 3 + animFrame / 10, screenHeight * 2 / 3 - animFrame / 20)
  local moonRadius = screenWidth // 3
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonPos, moonRadius)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonPos + pd.geometry.vector2D.new(-2, -2), moonRadius - 4)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.3, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonPos + pd.geometry.vector2D.new(-4, -4), moonRadius - 8)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonPos + pd.geometry.vector2D.new(-6, -6), moonRadius - 12)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonPos + pd.geometry.vector2D.new(-8, -8), moonRadius - 16)

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRoundRect(screenWidth // 4, screenHeight // 4 - 4, screenWidth // 2, 24, 5)

  gfx.setFont(assets.fonts.large)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawTextAligned("*The Moon is our Friend*", screenWidth // 2, screenHeight // 4, kTextAlignment.center)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

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
