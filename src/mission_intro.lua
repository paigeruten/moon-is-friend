local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH

MissionIntro = {}

local boxX, boxY = 50, 20
local boxWidth, boxHeight = 300, 200

function MissionIntro.switch()
  Menu.addInGameMenuItems()
  if MISSIONS[gs.missionId].introText then
    gs.scene = 'mission-intro'
    gs.frameCount = 0
  else
    gs.scene = 'game'
    Game.reset()
  end
end

function MissionIntro.update()
  gs.stars:draw(0, 0)

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)

  local title = "Mission " .. gs.missionId
  local titleY = boxY + 14
  local paddingX = 15

  local maxChars = math.floor(gs.frameCount * 1.5)

  if title then
    gfx.setFont(assets.fonts.large)
    gfx.drawTextAligned('*' .. title .. '*', screenWidth // 2, titleY, kTextAlignment.center)
  end

  gfx.setFont(assets.fonts.small)

  local done = true
  local textY = boxY + 40
  for _, para in ipairs(MISSIONS[gs.missionId].introText) do
    if maxChars < #para then
      para = string.sub(para, 1, maxChars)
      done = false
    end
    local _, paraHeight = gfx.drawText(para, boxX + paddingX, textY, boxWidth - paddingX * 2, boxHeight)
    textY += paraHeight + 10
    if maxChars < #para then
      break
    else
      maxChars -= #para
    end
  end

  local perlY = math.min(3, math.max(-3, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
  gfx.setFont(assets.fonts.large)
  gfx.drawText("Ⓐ", boxX + boxWidth - 28, boxY + boxHeight - 28 + perlY)

  gs.frameCount += 1

  if pd.buttonJustReleased(pd.kButtonA) then
    if not done then
      gs.frameCount = 1000000
    else
      gs.scene = 'game'
      Game.reset()
      assets.sfx.boop:play(77)
    end
  end
end
