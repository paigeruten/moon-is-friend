local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets

local polarCoordinates = Util.polarCoordinates

Moon = {}

function Moon.create()
  return {
    pos = { x = 0, y = 0 },
    radius = 7,
    gravityRadius = 80,
    mass = gs.missionId == 'endless.rubdubdub' and 5 or 3,
    hasShield = gs.missionId == 'endless.rubdubdub',
  }
end

function Moon.update()
  local crankAngle = gs.moons[1].holdAngle or pd.getCrankPosition()
  local moonX, moonY = polarCoordinates(gs.earth.moonDistance, crankAngle)
  gs.moons[1].pos.x = gs.earth.basePos.x + moonX
  gs.moons[1].pos.y = gs.earth.basePos.y + moonY
  if #gs.moons == 2 then
    gs.moons[2].pos.x = gs.earth.basePos.x - moonX
    gs.moons[2].pos.y = gs.earth.basePos.y - moonY
  elseif #gs.moons == 3 then
    local moon2X, moon2Y = polarCoordinates(gs.earth.moonDistance, crankAngle + 120)
    gs.moons[2].pos.x = gs.earth.basePos.x + moon2X
    gs.moons[2].pos.y = gs.earth.basePos.y + moon2Y

    local moon3X, moon3Y = polarCoordinates(gs.earth.moonDistance, crankAngle + 240)
    gs.moons[3].pos.x = gs.earth.basePos.x + moon3X
    gs.moons[3].pos.y = gs.earth.basePos.y + moon3Y
  end

  if gs.missionId == 'endless.rubdubdub' then
    gs.earth.moonDistance -= pd.getCrankChange() / 30
  end

  if gs.earth.maxBombs == 0 and gs.bossPhase < 3 then
    local abPressed = pd.buttonIsPressed(pd.kButtonA) or pd.buttonIsPressed(pd.kButtonB)
    if abPressed and (gs.zenMode or (gs.extraSuction and gs.extraSuctionFuel > 1) or (not gs.extraSuction and gs.extraSuctionFuel == gs.extraSuctionMaxFuel)) then
      if not gs.extraSuction then
        assets.sfx.suck:start()
      end
      gs.extraSuction = true
      if not gs.zenMode then
        gs.extraSuctionFuel = math.max(0, gs.extraSuctionFuel - 2)
      end
    elseif gs.extraSuctionFuel < gs.extraSuctionMaxFuel then
      assets.sfx.suck:stop()
      gs.extraSuction = false
      if gs.frameCount % 3 < 2 then
        gs.extraSuctionFuel += 1
      end
    else
      if gs.extraSuction then
        assets.sfx.suck:stop()
      end
      gs.extraSuction = false
    end
  end
end

function Moon.draw()
  for _, moon in ipairs(gs.moons) do
    if gs.extraSuction and not gs.endState then
      gfx.setColor(gfx.kColorWhite)
      for _ = 1, 40 do
        local suctionX, suctionY = polarCoordinates(moon.radius + math.random(5, 6), math.random() * 360)
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
      if gs.missionId == 'endless.rubdubdub' then
        gfx.drawCircleAtPoint(moon.pos.x, moon.pos.y, moon.radius + 4)
      end
    end
  end
end
