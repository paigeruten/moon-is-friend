import "CoreLibs/easing"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "vendor/pdfxr"

import "constants"
import "assets"
import "game"
import "util"
import "achievements"

import "asteroid"
import "particle"
import "rocket"
import "explosion"
import "target"
import "moon"
import "earth"
import "bomb"
import "sidebar"
import "mission_tree"
import "menu_box"

import "save_data"
import "menu"
import "title"
import "instructions"
import "mission_intro"
import "game_end"
import "endless"
import "high_scores"
import "settings"

local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local showFps = SHOW_FPS

Game.init()
Game.reset()

math.randomseed(pd.getSecondsSinceEpoch())
pd.display.setRefreshRate(50)
gfx.setBackgroundColor(gfx.kColorBlack)

function pd.update()
  pd.timer.updateTimers()

  if gs.scene == 'title' then
    Title.update()
  elseif gs.scene == 'instructions' then
    Instructions.update()
  elseif gs.scene == 'mission-tree' then
    MissionTree.update()
  elseif gs.scene == 'mission-intro' then
    MissionIntro.update()
  elseif gs.scene == 'endless' then
    Endless.update()
  elseif gs.scene == 'high-scores' then
    HighScores.update()
  elseif gs.scene == 'settings' then
    Settings.update()
  else
    Game.update()
  end

  if gs.scene ~= 'game' or gs.endState then
    Achievement.displayToasts()
  end

  if showFps and gs.scene ~= 'mission-tree' then
    pd.drawFPS(screenWidth - 20, screenHeight - 15)
  end
end
