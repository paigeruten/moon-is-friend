local pd = playdate
local gfx = pd.graphics
local gs = Game.state

Moon = {}

function Moon.create()
  return {
    radius = 7,
    gravityRadius = 75,
    mass = 2.5,
    hasShield = false,
  }
end

function Moon.update()
  local moonVec = pd.geometry.vector2D.newPolar(MOON_DISTANCE_FROM_EARTH, pd.getCrankPosition())
  gs.moons[1].pos = gs.earth.pos + moonVec
  if #gs.moons == 2 then
    gs.moons[2].pos = gs.earth.pos - moonVec
  elseif #gs.moons == 3 then
    gs.moons[2].pos = gs.earth.pos + pd.geometry.vector2D.newPolar(MOON_DISTANCE_FROM_EARTH, pd.getCrankPosition() + 120)
    gs.moons[3].pos = gs.earth.pos + pd.geometry.vector2D.newPolar(MOON_DISTANCE_FROM_EARTH, pd.getCrankPosition() + 240)
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
        gfx.drawPixel(moon.pos + pd.geometry.vector2D.newPolar(moon.radius + 3, math.random() * 360))
      end
    end

    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(moon.pos, moon.radius)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(moon.pos + pd.geometry.vector2D.new(2, 2), 3)
    gfx.fillCircleAtPoint(moon.pos + pd.geometry.vector2D.new(-4, -1), 2)
    gfx.fillCircleAtPoint(moon.pos + pd.geometry.vector2D.new(3, -3), 2)
    gfx.fillCircleAtPoint(moon.pos + pd.geometry.vector2D.new(-4, 4), 2)
    gfx.fillCircleAtPoint(moon.pos + pd.geometry.vector2D.new(-1, -5), 2)
    if moon.hasShield then
      gfx.setColor(gfx.kColorWhite)
      gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
      gfx.drawCircleAtPoint(moon.pos, moon.radius + 3)
    end
  end
end
