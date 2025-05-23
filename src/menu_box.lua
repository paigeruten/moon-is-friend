local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

MenuBox = {}

-- options: { withSidebar = boolean, animated = boolean, width = number, adjustY = number, selected = number }
function MenuBox.init(items, options, selectCallback)
  gs.menuFrameCount = 0
  gs.menuItems = items
  gs.menuSelected = options.selected or 1
  gs.menuOptions = options
  gs.menuCallback = selectCallback
  gs.menuHeight = 15 + 20 * #items
end

function MenuBox.update()
  local menuCenterX
  if gs.menuOptions.withSidebar then
    menuCenterX = sidebarWidth + (screenWidth - sidebarWidth) // 2
  else
    menuCenterX = screenWidth // 2
  end

  local menuBoxWidth = gs.menuOptions.width or 200
  local menuBoxX = menuCenterX - menuBoxWidth // 2
  local menuBoxY = screenHeight - gs.menuHeight - 30 + (gs.menuOptions.adjustY or 0)
  if gs.menuOptions.animated then
    menuBoxY = pd.easingFunctions.outExpo(gs.menuFrameCount, screenHeight, menuBoxY - screenHeight, 50)
  end
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(menuBoxX, menuBoxY, menuBoxWidth, gs.menuHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
  gfx.fillRect(menuBoxX, menuBoxY, menuBoxWidth, gs.menuHeight)
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(menuBoxX + 3, menuBoxY + 3, menuBoxWidth - 6, gs.menuHeight - 6)

  gfx.setFont(assets.fonts.menu)
  for itemId, itemText in ipairs(gs.menuItems) do
    local itemWidth, itemHeight = gfx.getTextSize(itemText)
    local itemX = menuCenterX - itemWidth // 2
    local itemY = menuBoxY + 10 + 20 * (itemId - 1)
    gfx.drawText(itemText, itemX, itemY)

    if gs.menuSelected == itemId then
      local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.menuFrameCount % 100) / 100, 0, 0) * 20 - 10))
      gfx.setColor(gfx.kColorBlack)
      gfx.fillRect(itemX, itemY + itemHeight + 2 + perlY, itemWidth, 3)
    else
      gfx.setColor(gfx.kColorBlack)
      gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
      gfx.fillRect(itemX, itemY + itemHeight, itemWidth, 2)
    end
  end

  if pd.buttonJustPressed(pd.kButtonDown) then
    gs.menuSelected += 1
    if gs.menuSelected > #gs.menuItems then
      gs.menuSelected = 1
    end
    assets.sfx.boop:play()
  elseif pd.buttonJustPressed(pd.kButtonUp) then
    gs.menuSelected -= 1
    if gs.menuSelected == 0 then
      gs.menuSelected = #gs.menuItems
    end
    assets.sfx.boop:play()
  end

  if pd.buttonJustReleased(pd.kButtonA) then
    gs.menuCallback(gs.menuSelected)
  end

  gs.menuFrameCount += 1
end
