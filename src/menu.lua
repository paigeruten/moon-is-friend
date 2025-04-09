local pd = playdate
local gs = Game.state
local menu = pd.getSystemMenu()

Menu = {}

menu:addCheckmarkMenuItem('screen shake', gs.screenShakeEnabled, function(checked)
  gs.screenShakeEnabled = checked
end)

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
    Title.switch()
  end)))
end

function Menu.reset()
  for _, menuItem in ipairs(inGameMenuItems) do
    menu:removeMenuItem(menuItem)
  end
  inGameMenuItems = {}
end
