local pd = playdate
local gs = Game.state
local menu = pd.getSystemMenu()

Menu = {}

-- menu:addOptionsMenuItem('difficulty', { 'easy', 'normal', 'ramp-up', 'hard', 'aaaah' }, gs.difficulty, function(selected)
--   gs.difficulty = selected
--   updateRampUpDifficulty()
-- end)
-- menu:addOptionsMenuItem('mode', { 'standard', 'juggling' }, gs.gameMode, function(selected)
--   gs.gameMode = selected
--   Game.reset()
-- end)
local missions = {}
for missionKey, _ in pairs(MISSIONS) do
  table.insert(missions, missionKey)
end
menu:addOptionsMenuItem('mission', missions, gs.missionId, function(selected)
  gs.missionId = selected
  Game.reset()
end)
-- menu:addCheckmarkMenuItem('screen shake', gs.screenShakeEnabled, function(checked)
--   gs.screenShakeEnabled = checked
-- end)

-- Menu items that should be removed when going back to the title screen
local inGameMenuItems = {}

function Menu.addInGameMenuItems()
  Menu.reset()
  table.insert(inGameMenuItems, (menu:addMenuItem('restart game', function()
    Game.reset()
    gs.scene = 'game'
  end)))
  table.insert(inGameMenuItems, (menu:addMenuItem('back to title', function()
    Game.reset()
    gs.scene = 'title'
    Menu.reset()
  end)))
end

function Menu.reset()
  for _, menuItem in ipairs(inGameMenuItems) do
    menu:removeMenuItem(menuItem)
  end
  inGameMenuItems = {}
end
