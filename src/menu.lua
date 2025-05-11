local pd = playdate
local gs = Game.state
local menu = pd.getSystemMenu()

Menu = {}

menu:addCheckmarkMenuItem('easy mode', SaveData.getDifficulty() == 'easy', function(checked)
  SaveData.setDifficulty(checked and 'easy' or 'normal')
end)

menu:addCheckmarkMenuItem('screen shake', SaveData.isScreenShakeEnabled(), function(checked)
  SaveData.setScreenShakeEnabled(checked)
end)

-- Menu items that should be removed when going back to the title screen
local inGameMenuItems = {}

function Menu.addInGameMenuItems()
  Menu.reset()
  table.insert(inGameMenuItems, (menu:addMenuItem('back to title', function()
    Game.reset()
    Title.switch()
  end)))
end

function Menu.reset()
  achievements.save()
  for _, menuItem in ipairs(inGameMenuItems) do
    menu:removeMenuItem(menuItem)
  end
  inGameMenuItems = {}
end
