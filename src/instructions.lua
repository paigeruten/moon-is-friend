local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT

Instructions = {}

local pages = {
  {
    title = "Story",
    text = {
      "After a large-scale asteroid mining\nexpedition gone wrong, "
      .. "the Earth is now\nunder a barrage of meteors, and is very\nscared.",
      "Desparate to help its best friend, "
      .. "the\nMoon wakes up from its deep slumber "
      .. "and\nsprings into action to protect the Earth."
    }
  },
  {
    title = "How to play",
    text = {
      "Use the crank to move the Moon and pull\nincoming meteors away from the Earth.",
      "The Moon has strong gravity, but it only\naffects meteors close to it.",
      "Try to grab any supplies the Earth sends\nyour way. They may contain extra health\nor various power-ups.",
    }
  },
  {
    title = "Power-ups",
    text = {
      "Shield: Protects the Moon or the Earth\nfrom 1 hit.",
      "Bomb: Destroys all meteors in its path.\nPress B to use. You can hold up to 3.",
      "Gravity booster: Replaces bombs in some\ngame modes. Press and hold B to double\nyour gravitational pull for a short time."
    }
  },
  {
    title = "Missions",
    text = {
      "Missions take you on a journey to save\nthe Earth from the meteors, for good.",
      "They can be played on 3 difficulty levels,\neach one earning a different badge:\nCheckmark, Star, and Heart.",
      "Some missions unlock new game modes.\nNot all missions need to be completed to\nreach the end of the game."
    }
  },
  {
    title = "Endless mode",
    text = {
      "In Endless mode, try to score as many\npoints as you can until game over.\n"
      .. "Meteors will spawn more frequently as\ntime goes on.",
      "+1 point for diverting a meteor off-screen\n"
      .. "+3 points for catching a rocket when you\nare already at max health/bombs/shields\n"
      .. "+5 points when two meteors collide"
    }
  },
  {
    title = "Juggling",
    text = {
      "In Juggling mode, meteors stay on-screen\nuntil they are destroyed by making them\ncollide with each other.",
      "Collisions give you +1 Health and +5 Points\n(or +7 Points if at full health). In Endless\nJuggling, meteors slowly shrink over time.",
      "Use your gravity booster (by holding B) to\nmaneuver the meteors in this mode."
    }
  },
  {
    title = "About",
    text = {
      "Made by Paige Ruten (aka pailey)",
      "Feedback is welcome!\n  paige.ruten@gmail.com",
      "Source code:\n  github.com/paigeruten/moon-is-friend",
      "Version: " .. VERSION
    }
  }
}

local boxX, boxY = 50, 20
local boxWidth, boxHeight = 300, 200
local curPage = 1

function Instructions.switch()
  gs.scene = 'instructions'
  gs.frameCount = 0
  curPage = 1
end

function Instructions.update()
  gs.stars:draw(0, 0)

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(boxX + 3, boxY + 3, boxWidth - 6, boxHeight - 6)

  local titleY = boxY + 12
  local paddingX, paddingY = boxX + 10, titleY + 24
  local page = pages[curPage]

  local maxChars = math.floor(gs.frameCount * 3)

  gfx.setFont(assets.fonts.large)
  gfx.drawTextAligned('*' .. page.title .. '*', screenWidth // 2, titleY, kTextAlignment.center)

  gfx.setFont(assets.fonts.small)

  local done = true
  local textY = paddingY
  for _, para in ipairs(page.text) do
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
  gfx.setFont(assets.fonts.large)
  gfx.drawText("Ⓐ", boxX + boxWidth - 28, boxY + boxHeight - 28 + perlY)

  gfx.setFont(assets.fonts.menu)
  gfx.drawText(table.concat({ curPage, "/", #pages }), boxX + 10, boxY + boxHeight - 22)

  gs.frameCount += 1

  if pd.buttonJustReleased(pd.kButtonA) then
    if not done then
      gs.frameCount = 1000000
    elseif curPage < #pages then
      curPage += 1
      gs.frameCount = 0
      assets.sfx.boop:play()
    else
      curPage = 1
      Title.switch()
      assets.sfx.boop:play()
    end
  end

  if pd.buttonJustReleased(pd.kButtonB) then
    if curPage > 1 then
      curPage -= 1
      gs.frameCount = 1000000
      assets.sfx.boop:play()
    else
      Title.switch()
      assets.sfx.boop:play()
    end
  end
end
