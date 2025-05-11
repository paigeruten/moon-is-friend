---@diagnostic disable: missing-fields

import "vendor/achievements/achievements"
import "vendor/achievements/toasts"
import "vendor/achievements/viewer"

local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH

Achievement = {}

local assetPath = "vendor/achievements/assets"

achievements.initialize({
  iconPath = "images/launcher/icon",
  cardPath = "images/launcher/card",
  achievements = {
    {
      id = "first_collision",
      name = "My first collision",
      description = "Cause two meteors to collide with each other.",
    },
    {
      id = "rocket_collision",
      name = "Human shield",
      description = "Cause a meteor to destroy a rocket.",
    },
    {
      id = "big_damage",
      name = "The Big One",
      description = "Do more than 10 damage to a boss with a single meteor.",
    },
    {
      id = "chaos_averted",
      name = "Disaster averted",
      description = "Destroy 5 or more meteors with a single bomb.",
    },
    {
      id = "beat_the_game",
      name = "The Earth is safe",
      description = "Beat the game."
    },
    {
      id = "asteroid_collisions",
      name = "Collisionist",
      description = "Cause 100 pairs of meteors to collide with each other.",
      progressMax = 100
    },
    {
      id = "double_shield",
      name = "Double shield",
      description = "Have 2 shield power-ups active at the same time.",
    },
    {
      id = "triple_shield",
      name = "Triple shield",
      description = "Have 3 shield power-ups active at the same time.",
    },
    {
      id = "quadruple_shield",
      name = "Quad shield",
      description = "Have 4 shield power-ups active at the same time.",
    },
    {
      id = "max_level_endless",
      name = "Pure chaos",
      description = "Reach the maximum level in Endless mode.",
    },
    {
      id = "max_powerups_endless",
      name = "Power-up hoarder",
      description = "Catch a rocket after maxing out all your power-ups in Endless mode.",
    },
    {
      id = "complete_all_missions",
      name = "Overachiever",
      description = "Complete every mission.",
      progressMax = 13
    },
    {
      id = "no_damage_1-1",
      name = "Flawless 1-1",
      description = "Complete mission 1-1 without taking damage.",
    },
    {
      id = "no_damage_2-1",
      name = "Flawless 2-1",
      description = "Complete mission 2-1 without taking damage.",
    },
    {
      id = "no_damage_2-2",
      name = "Flawless 2-2",
      description = "Complete mission 2-2 without taking damage.",
    },
    {
      id = "no_damage_2-3",
      name = "Flawless 2-3",
      description = "Complete mission 2-3 without taking damage.",
    },
    {
      id = "no_damage_2-4",
      name = "Flawless 2-4",
      description = "Complete mission 2-4 without taking damage.",
    },
    {
      id = "no_damage_3-B",
      name = "Flawless 3-B",
      description = "Complete mission 3-B without taking damage.",
    },
    {
      id = "no_damage_4-1",
      name = "Flawless 4-1",
      description = "Complete mission 4-1 without taking damage.",
    },
    {
      id = "no_damage_4-2",
      name = "Flawless 4-2",
      description = "Complete mission 4-2 without taking damage.",
    },
    {
      id = "no_damage_4-3",
      name = "Flawless 4-3",
      description = "Complete mission 4-3 without taking damage.",
    },
    {
      id = "no_damage_4-4",
      name = "Flawless 4-4",
      description = "Complete mission 4-4 without taking damage.",
    },
    {
      id = "no_damage_5-1",
      name = "Flawless 5-1",
      description = "Complete mission 5-1 without taking damage.",
    },
    {
      id = "no_damage_5-2",
      name = "Flawless 5-2",
      description = "Complete mission 5-2 without taking damage.",
    },
    {
      id = "no_damage_6-B",
      name = "Flawless 6-B",
      description = "Complete mission 6-B without taking damage.",
    },
  }
}, false)
achievements.forceSaveOnGrantOrRevoke = true

function playdate.gameWillTerminate()
  achievements.save()
end

function playdate.deviceWillSleep()
  achievements.save()
end

achievements.toasts.initialize({
  assetPath = assetPath,
  toastFromTop = true,
  shadowColor = playdate.graphics.kColorWhite
})

achievements.viewer.initialize({
  assetPath = assetPath,
  summaryMode = "percent"
})

local achievementQueue = {}

function Achievement.draw()
  if gs.achievementTtl > 0 then
    local aFrame = 100 - gs.achievementTtl
    local aX = screenWidth - 34
    if aFrame < 17 then
      aX = screenWidth - aFrame * 2
    elseif gs.achievementTtl < 17 then
      aX = screenWidth - gs.achievementTtl * 2
    end
    assets.gfx.achievement:draw(aX, 2)
    gs.achievementTtl -= 1
  end
end

function Achievement.queue(achievementId, showIcon)
  table.insert(achievementQueue, achievementId)
  if showIcon then
    gs.achievementTtl = 100
    assets.sfx.achievement:play()
  end
end

function Achievement.displayToasts()
  local atLeastOne = false
  for _, achievementId in ipairs(achievementQueue) do
    achievements.toasts.toast(achievementId)
    atLeastOne = true
  end
  if atLeastOne then
    achievementQueue = {}
  end
end
