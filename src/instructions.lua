local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT

Instructions = {}

function Instructions.update()
  gfx.clear()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRoundRect(0, 0, screenWidth, screenHeight, 15)
  gfx.setColor(gfx.kColorBlack)
  gfx.drawRoundRect(1, 1, screenWidth - 2, screenHeight - 2, 15)

  local text
  local paddingX, paddingY = 10, 10
  local titleY
  local title
  if gs.scene == 'story' then
    title = "2038: The Moon Wakes Up"
    titleY = 16
    paddingY = 50
    text = {
      "After a large-scale asteroid mining expedition\ngone wrong, "
      .. "the Earth is now under a barrage of\nasteroids, and is very scared.",
      "Desparate to help its best friend, "
      .. "the Moon wakes\nup from its deep slumber "
      .. "and springs into action\nto protect the Earth." }
  else
    title = "How to play"
    titleY = 10
    paddingY = 36
    text = {
      "Use the crank to control the Moon and "
      .. "pull\nincoming asteroids away from the Earth. "
      .. "Get\n*+1 point* per asteroid averted, "
      .. "and *+5 points* for\ngetting two asteroids to collide with each other!",
      "Try to grab any supplies the Earth sends your\nway - "
      .. "they may contain extra health or various\npowerups.",
      "If you get *100 points*, you get a little gold star on\nthe title screen. Good luck!"
    }
  end

  local maxChars = math.floor(gs.frameCount * 1.5)

  gfx.setFont(assets.fonts.large)

  if title then
    gfx.drawTextAligned('*' .. title .. '*', screenWidth // 2, titleY, kTextAlignment.center)
  end

  local done = true
  local textY = paddingY
  for _, para in ipairs(text) do
    if maxChars < #para then
      para = string.sub(para, 1, maxChars)
      done = false
    end
    local _, paraHeight = gfx.drawText(para, paddingX, textY, screenWidth - paddingX * 2, screenHeight)
    textY += paraHeight + 10
    if maxChars < #para then
      break
    else
      maxChars -= #para
    end
  end

  local perlY = math.min(3, math.max(-3, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
  gfx.drawText("Ⓐ", screenWidth - 28, screenHeight - 28 + perlY)

  gs.frameCount += 1

  if pd.buttonJustReleased(pd.kButtonA) then
    if not done then
      gs.frameCount = 1000000
    elseif gs.scene == 'story' then
      gs.scene = 'instructions'
      gs.frameCount = 0
      assets.sfx.boop:play()
    else
      Title.switch()
      assets.sfx.boop:play()
    end
  end
end
