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
  MenuBox.init({ 'Missions', 'Endless', 'High scores', 'Achievements', 'How to play', 'Settings' },
    { width = 120, adjustY = 14, selected = gs.titleSelected },
    function(selected)
      gs.titleSelected = selected
      if selected == 1 then
        MissionTree.switch()
        MissionTree.selectNextMission()
        assets.sfx.boop:play()
      elseif selected == 2 then
        Endless.switch()
        assets.sfx.boop:play()
      elseif selected == 3 then
        HighScores.switch()
        assets.sfx.boop:play()
      elseif selected == 4 then
        assets.sfx.boop:play()
        achievements.viewer.launch()
      elseif selected == 5 then
        Instructions.switch()
        assets.sfx.boop:play()
      elseif selected == 6 then
        Settings.switch()
        assets.sfx.boop:play()
      end
    end)
end

function Title.update()
  gs.stars:draw(0, 0)

  local animFrame = math.min(gs.frameCount, 700)

  -- Earth
  local earthX = screenWidth - 60
  local earthY = screenHeight // 4
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthX, earthY, 28)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthX - 2, earthY - 2, 28 - 4)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillCircleAtPoint(earthX - 4, earthY - 4, 28 - 8)
  gfx.setColor(gfx.kColorBlack)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthX - 18, earthY - 18, 6)
  gfx.fillCircleAtPoint(earthX - 18, earthY + 6, 8)
  gfx.fillCircleAtPoint(earthX - 6, earthY + 12, 8)
  gfx.fillCircleAtPoint(earthX + 10, earthY - 18, 8)
  gfx.setDitherPattern(0.6, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(earthX + 16, earthY + 12, 8)
  gfx.fillCircleAtPoint(earthX + 18, earthY + 8, 8)

  -- Earth eyes
  local leftEyeX, leftEyeY = earthX - 9, earthY - 9
  local rightEyeX, rightEyeY = earthX + 9, earthY - 9
  if SaveData.isMissionComplete("6-B") then
    assets.gfx.eyelid:draw(leftEyeX - 5, leftEyeY)
    assets.gfx.eyelid:draw(rightEyeX - 5, rightEyeY)

    local zFrame = (gs.frameCount // 35) % 4 + 1
    assets.gfx.zeds:getImage(zFrame):draw(earthX + 20, earthY - 42)
  else
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(leftEyeX, leftEyeY, 8)
    gfx.fillCircleAtPoint(rightEyeX, rightEyeY, 8)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer8x8)
    gfx.drawCircleAtPoint(leftEyeX, leftEyeY, 8)
    gfx.drawCircleAtPoint(rightEyeX, rightEyeY, 8)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(leftEyeX, leftEyeY, 3)
    gfx.fillCircleAtPoint(rightEyeX, rightEyeY, 3)
  end

  -- Moon
  local moonX = screenWidth / 3 + animFrame / 10
  local moonY = screenHeight * 2 / 3 - animFrame / 20
  local moonRadius = screenWidth // 3
  gfx.setColor(gfx.kColorBlack)
  gfx.fillCircleAtPoint(moonX, moonY, moonRadius)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonX, moonY, moonRadius)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonX - 2, moonY - 2, moonRadius - 4)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.3, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonX - 4, moonY - 4, moonRadius - 8)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonX - 6, moonY - 6, moonRadius - 12)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
  gfx.fillCircleAtPoint(moonX - 8, moonY - 8, moonRadius - 16)

  -- Logo
  local logoWidth, logoHeight = 75, 49
  local logoX, logoY = screenWidth // 2 - logoWidth // 2, 19
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRoundRect(logoX - 5, logoY - 5, logoWidth + 10, logoHeight + 10, 5)
  assets.gfx.logo:draw(logoX, logoY)

  MenuBox.update()

  gs.frameCount += 1
end
