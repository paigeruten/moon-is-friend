local pd = playdate
local gfx = pd.graphics
local gs = Game.state

local polarCoordinates = Util.polarCoordinates

Moon = {}

function Moon.create()
  return {
    pos = { x = 0, y = 0 },
    radius = 7,
    gravityRadius = 75,
    mass = 2.5,
    hasShield = false,
  }
end

function Moon.update()
  local moonX, moonY = polarCoordinates(MOON_DISTANCE_FROM_EARTH, pd.getCrankPosition())
  gs.moons[1].pos.x = gs.earth.pos.x + moonX
  gs.moons[1].pos.y = gs.earth.pos.y + moonY
  if #gs.moons == 2 then
    gs.moons[2].pos.x = gs.earth.pos.x - moonX
    gs.moons[2].pos.y = gs.earth.pos.y - moonY
  elseif #gs.moons == 3 then
    local moon2X, moon2Y = polarCoordinates(MOON_DISTANCE_FROM_EARTH, pd.getCrankPosition() + 120)
    gs.moons[2].pos.x = gs.earth.pos.x + moon2X
    gs.moons[2].pos.y = gs.earth.pos.y + moon2Y

    local moon3X, moon3Y = polarCoordinates(MOON_DISTANCE_FROM_EARTH, pd.getCrankPosition() + 240)
    gs.moons[3].pos.x = gs.earth.pos.x + moon3X
    gs.moons[3].pos.y = gs.earth.pos.y + moon3Y
  end

  if gs.earth.maxBombs == 0 then
    gs.extraSuction = pd.buttonIsPressed(pd.kButtonB)
  end
end

function Moon.draw()
  for _, moon in ipairs(gs.moons) do
    if gs.extraSuction then
      gfx.setColor(gfx.kColorWhite)
      for _ = 1, 20 do
        local suctionX, suctionY = polarCoordinates(moon.radius + 3, math.random() * 360)
        gfx.drawPixel(moon.pos.x + suctionX, moon.pos.y + suctionY)
      end
    end

    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(moon.pos.x, moon.pos.y, moon.radius)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(moon.pos.x + 2, moon.pos.y + 2, 3)
    gfx.fillCircleAtPoint(moon.pos.x - 4, moon.pos.y - 1, 2)
    gfx.fillCircleAtPoint(moon.pos.x + 3, moon.pos.y - 3, 2)
    gfx.fillCircleAtPoint(moon.pos.x - 4, moon.pos.y + 4, 2)
    gfx.fillCircleAtPoint(moon.pos.x - 1, moon.pos.y - 5, 2)
    if moon.hasShield then
      gfx.setColor(gfx.kColorWhite)
      gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
      gfx.drawCircleAtPoint(moon.pos.x, moon.pos.y, moon.radius + 3)
    end
  end
end
