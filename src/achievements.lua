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
  cardPath = "images/launcher/achievement-card",
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
      id = "no_asteroid_paths",
      name = "Taking off the training wheels",
      description = "Complete any mission with asteroid paths turned off the entire time.",
    },
    {
      id = "big_damage",
      name = "The Big One",
      description = "Do more than 10 damage to a boss with a single meteor in normal mode.",
    },
    {
      id = "chaos_averted",
      name = "Disaster averted",
      description = "Destroy 5 or more meteors with a single bomb.",
    },
    {
      id = "beat_first_boss",
      name = "Halfway there",
      description = "Beat the first boss."
    },
    {
      id = "beat_the_game",
      name = "The Earth is safe",
      description = "Beat the game."
    },
    {
      id = "complete_all_missions",
      name = "Overachiever",
      description = "Complete every mission.",
      progressMax = 15
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
      id = "max_powerups_endless",
      name = "Power-up hoarder",
      description = "Catch a rocket after maxing out all your power-ups in Endless mode.",
    },
    {
      id = "endless_one_moon_expert",
      name = "Single moon expert",
      description = "Get 200 points in an Endless run with one moon."
    },
    {
      id = "endless_two_moon_expert",
      name = "Double moon expert",
      description = "Get 100 points in an Endless run with two moons."
    },
    {
      id = "endless_three_moon_expert",
      name = "Triple moon expert",
      description = "Get 100 points in an Endless run with three moons."
    },
    {
      id = "max_level_endless",
      name = "Pure chaos",
      description = "Reach the maximum level in Endless mode.",
    },
    {
      id = "endless_expert_juggler",
      name = "Expert juggler",
      description = "Get 50 points in any Endless Juggling run."
    },
    {
      id = "endless_hero",
      name = "Endless hero",
      description = "Accumulate 2,500 points over the course of all your Endless runs.",
      progressMax = 2500
    },
    {
      id = "endless_addict",
      name = "Endless addict",
      description = "Accumulate 10,000 points over the course of all your Endless runs.",
      progressMax = 10000
    },
    {
      id = "no_damage_1-1",
      name = "Flawless 1-1",
      description = "Complete mission 1-1 in normal mode without taking damage.",
    },
    {
      id = "no_damage_1-2",
      name = "Flawless 1-2",
      description = "Complete mission 1-2 in normal mode without taking damage.",
    },
    {
      id = "no_damage_2-1",
      name = "Flawless 2-1",
      description = "Complete mission 2-1 in normal mode without taking damage.",
    },
    {
      id = "no_damage_2-2",
      name = "Flawless 2-2",
      description = "Complete mission 2-2 in normal mode without taking damage.",
    },
    {
      id = "no_damage_2-3",
      name = "Flawless 2-3",
      description = "Complete mission 2-3 in normal mode without taking damage.",
    },
    {
      id = "no_damage_2-4",
      name = "Flawless 2-4",
      description = "Complete mission 2-4 in normal mode without taking damage.",
    },
    {
      id = "no_damage_3-B",
      name = "Flawless 3-B",
      description = "Complete mission 3-B in normal mode without taking damage.",
    },
    {
      id = "no_damage_4-1",
      name = "Flawless 4-1",
      description = "Complete mission 4-1 in normal mode without taking damage.",
    },
    {
      id = "no_damage_4-2",
      name = "Flawless 4-2",
      description = "Complete mission 4-2 in normal mode without taking damage.",
    },
    {
      id = "no_damage_4-3",
      name = "Flawless 4-3",
      description = "Complete mission 4-3 in normal mode without taking damage.",
    },
    {
      id = "no_damage_4-4",
      name = "Flawless 4-4",
      description = "Complete mission 4-4 in normal mode without taking damage.",
    },
    {
      id = "no_damage_5-1",
      name = "Flawless 5-1",
      description = "Complete mission 5-1 in normal mode without taking damage.",
    },
    {
      id = "no_damage_5-2",
      name = "Flawless 5-2",
      description = "Complete mission 5-2 in normal mode without taking damage.",
    },
    {
      id = "no_damage_5-3",
      name = "Flawless 5-3",
      description = "Complete mission 5-3 in normal mode without taking damage.",
    },
    {
      id = "no_damage_6-B",
      name = "Flawless 6-B",
      description = "Complete mission 6-B in normal mode without taking damage.",
    },
    {
      id = "no_damage_all",
      name = "Perfectionist",
      description = "Complete all missions in normal mode without taking damage.",
      progressMax = 15
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
  if #achievementQueue >= 10 then
    -- failsafe to protect against any endlessly looping achievements
    return
  end
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
