import "CoreLibs/easing"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "vendor/pdfxr"

import "constants"
import "assets"
import "game"

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

import "menu"
import "title"
import "instructions"
import "game_end"
import "save_data"
import "endless"
import "high_scores"

local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Game.init()
Game.reset()

math.randomseed(pd.getSecondsSinceEpoch())
pd.display.setRefreshRate(50)
gfx.setBackgroundColor(gfx.kColorBlack)

function pd.update()
  pd.timer.updateTimers()

  if gs.scene == 'title' then
    Title.update()
  elseif gs.scene == 'story' or gs.scene == 'instructions' then
    Instructions.update()
  elseif gs.scene == 'mission-tree' then
    MissionTree.update()
  elseif gs.scene == 'endless' then
    Endless.update()
  elseif gs.scene == 'high-scores' then
    HighScores.update()
  else
    Game.update()
  end
end
