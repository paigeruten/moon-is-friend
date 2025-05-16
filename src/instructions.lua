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
    text = { "After a large-scale asteroid mining expedition gone wrong, "
    .. "the Earth is now under a barrage of meteors, and is very scared.",
      "Desparate to help its best friend, "
      .. "the Moon wakes up from its deep slumber "
      .. "and springs into action to protect the Earth." }
  },
  {
    title = "How to play",
    text = {
      "Use the crank to move the Moon and pull incoming meteors away from the Earth.",
      "The Moon has strong gravity, but only affects meteors close to it.",
      "Try to grab any supplies the Earth sends your way - they may contain extra health or various power-ups.",
    }
  },
  {
    title = "Power-ups",
    text = {
      "Shield: Protects the Moon or the Earth from 1 hit.",
      "Bomb: Destroys all meteors in its path. Press B to use. You can hold up to 3.",
      "Extra suction: Replaces bombs in some game modes. Press and hold B to double your gravitational pull for a short time."
    }
  },
  {
    title = "Missions",
    text = {
      "Complete missions to unlock new game modes, and ultimately to save the Earth for good.",
      "Each mission gets a checkmark upon completion, and a star if you completed it without taking damage.",
      "Most, but not all missions need to be completed to reach the end of the game."
    }
  },
  {
    title = "Easy mode",
    text = {
      "If you are struggling with some missions, try turning on easy mode from the Select Mission screen. This changes the game in a few ways:",
      "- Asteroids spawn less often\n"
      .. "- You have 5 hearts instead of 3\n"
      .. "- You do higher damage to bosses\n"
      .. "- No rewards for not taking damage"
    }
  },
  {
    title = "Endless mode",
    text = {
      "In Endless mode, try to score as many points as you can until game over. "
      .. "Meteors will spawn more frequently as time goes on.",
      "+1 point for diverting a meteor off-screen\n"
      .. "+3 points for catching a rocket when you are already at max health/bombs/shields\n"
      .. "+5 points when two meteors collide"
    }
  },
  {
    title = "Juggling",
    text = {
      "In Juggling mode, meteors stay on-screen until they are destroyed. "
      .. "The only way to destroy them is to make them collide with each other.",
      "Each collision gives you +1 Health (and +5 Points in Endless mode).",
      "Use extra suction (by holding B) to help maneuver the meteors in this mode."
    }
  },
  {
    title = "About",
    text = {
      "Made by Paige Ruten (aka pailey)",
      "Source code:\n  github.com/paigeruten/moon-is-friend"
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
  gfx.clear()

  gfx.setColor(gfx.kColorWhite)
  for _, star in ipairs(gs.stars) do
    gfx.drawPixel(star.x, star.y)
  end

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

  local maxChars = math.floor(gs.frameCount * 1.5)

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
