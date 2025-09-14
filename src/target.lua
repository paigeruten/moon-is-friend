local pd = playdate
local gfx = pd.graphics
local gs = Game.state
local assets = Assets
local screenWidth = SCREEN_WIDTH
local screenHeight = SCREEN_HEIGHT
local sidebarWidth = SIDEBAR_WIDTH

local polarCoordinates = Util.polarCoordinates

Target = {}

function Target.spawn(x, y, r, health)
  gs.curTargetId += 1
  local id = gs.curTargetId
  gs.targets[id] = {
    id = id,
    state = 'active',
    pos = { x = x, y = y },
    basePos = { x = x, y = y },
    radius = r,
    health = health,
    maxHealth = health,
    shakeTtl = 0
  }
  return gs.targets[id]
end

function Target.count()
  local count = 0
  for _, _ in pairs(gs.targets) do
    count += 1
  end
  return count
end

function Target.totalHealth()
  local totalHealth = 0
  for _, target in pairs(gs.targets) do
    totalHealth += target.health
  end
  return totalHealth
end

function Target.update()
  if gs.mission.winType == "boss" and gs.bossPhase == 0 then
    if gs.bossPhaseFrame == 100 then
      assets.sfx.omen:start()
    end
    if gs.bossPhaseFrame > 100 then
      if gs.bossPhaseFrame % 4 == 0 then
        gs.earth.basePos.x -= 1
        for _, star in ipairs(gs.stars) do
          star.x -= 1
          if star.x < 0 then
            star.x = screenWidth - 1
          end
        end
      end
      if gs.bossPhaseFrame % 2 == 0 then
        for _, target in pairs(gs.targets) do
          target.basePos.x -= 1
        end
      end
    end

    if gs.bossPhaseFrame == 300 then
      gs.bossPhase = 1
      assets.sfx.omen:stop()
    end
  elseif gs.mission.winType == "boss" and gs.bossPhase == 3 then
    if gs.bossPhaseFrame < 200 then
      if gs.bossPhaseFrame % 4 == 0 then
        gs.earth.basePos.x += 1
        for _, star in ipairs(gs.stars) do
          star.x += 1
          if star.x >= screenWidth then
            star.x = 0
          end
        end
      end
    elseif gs.bossPhaseFrame == 230 then
      gs.earth.isSafe = true
    end

    if gs.bossPhaseFrame >= 100 then
      local moon = gs.moons[1]
      if moon.holdAngle then
        moon.holdAngle += 0.75
        if moon.holdAngle >= 360 then
          moon.holdAngle -= 360
        end
      else
        moon.holdAngle = math.floor(Util.angleFromVec(moon.pos.x - gs.earth.basePos.x, moon.pos.y - gs.earth.basePos.y))
      end
    end

    if gs.bossPhaseFrame >= 500 and pd.buttonJustReleased(pd.kButtonA) then
      gs.bossPhase = 4
      gs.bossPhaseFrame = 0
    end
  end

  for id, target in pairs(gs.targets) do
    local perlX = math.min(2, math.max(-2, gfx.perlin((gs.frameCount % 200) / 200, 0, 0, 0) * 20 - 10))
    local perlY = math.min(2, math.max(-2, gfx.perlin(0, (gs.frameCount % 200) / 200, 0, 0) * 20 - 10))
    target.pos.x = target.basePos.x + perlX
    target.pos.y = target.basePos.y + perlY
    if target.shakeTtl > 0 then
      target.pos.x += math.random(-target.shakeTtl, target.shakeTtl) / 2
      target.pos.y += math.random(-target.shakeTtl, target.shakeTtl) / 2
      target.shakeTtl -= 1
    end

    if target.state == 'splode' then
      target.splodeTtl -= 1
      target.shakeTtl = 5
      if target.splodeTtl <= 0 then
        gs.targets[id] = nil

        local targetsLeft = 0
        for _, _ in pairs(gs.targets) do
          targetsLeft += 1
        end

        if targetsLeft == 0 and gs.mission.winGoal2 and gs.bossPhase == 1 then
          gs.bossPhase = 2
          gs.bossMaxHealth = gs.mission.winGoal2 * 3
          Target.spawn(screenWidth - 40, 120, 20, gs.mission.winGoal2)
          Target.spawn(screenWidth - 65, 40, 20, gs.mission.winGoal2)
          Target.spawn(screenWidth - 65, 200, 20, gs.mission.winGoal2)
        elseif targetsLeft == 0 and gs.bossPhase == 2 then
          gs.bossPhase = 3
          gs.bossPhaseFrame = 0
          gs.extraSuction = false
          gs.earth.hasShield = false
          for _, moon in ipairs(gs.moons) do
            moon.hasShield = false
          end
          gs.rockets = {}
          gs.curMessage = nil
          Game.stopSounds()

          for asteroidId, asteroid in pairs(gs.asteroids) do
            Explosion.spawn(asteroid.pos.x, asteroid.pos.y)
            Asteroid.despawn(asteroidId)
          end
          gs.asteroids = {}
        end
      else
        if math.random(1, 10) == 1 then
          assets.sfx.boom:play()
        end
        for _ = 1, math.random(1, target.radius // 10) do
          local minRadius = math.floor((100 - target.splodeTtl) / 100 * target.radius * 0.15) + 2
          local pVelX, pVelY = polarCoordinates(math.random() + 1, math.random() * 360)
          Particle.spawn(
            target.pos.x + math.random(-target.radius, target.radius),
            target.pos.y + math.random(-target.radius, target.radius),
            pVelX,
            pVelY,
            15,
            minRadius,
            minRadius + 2,
            0.2,
            0.9,
            gfx.kColorBlack
          )
        end
      end
    end
  end
end

function Target.draw()
  if gs.mission.winType == "boss" and gs.bossPhase == 0 then
    if gs.bossPhaseFrame < 100 and (gs.frameCount // 10) % 3 ~= 0 then
      assets.gfx.arrowRight:drawAnchored(screenWidth - 1, screenHeight // 2, 1, 0.5)
    end
  end

  if gs.bossPhase == 3 and gs.bossPhaseFrame >= 300 then
    local fadeAmount = (gs.bossPhaseFrame - 300) / 60
    local fadeAmount2 = (gs.bossPhaseFrame - 400) / 60

    gfx.setFont(assets.fonts.large)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    local textWidth, textHeight = gfx.getTextSize("*The Earth is safe.")
    local textX = sidebarWidth + (screenWidth - sidebarWidth) // 2 - textWidth // 2
    local textY = 15
    gfx.drawText("*The Earth is safe.*", textX, textY)
    if fadeAmount < 1.0 then
      gfx.setColor(gfx.kColorBlack)
      gfx.setDitherPattern(fadeAmount, gfx.image.kDitherTypeBayer8x8)
      gfx.fillRect(textX, textY, textWidth, textHeight)
    end

    if fadeAmount2 >= 0.0 then
      gfx.setFont(assets.fonts.menu)
      textWidth, textHeight = gfx.getTextSize("Thank you for playing!")
      textX = sidebarWidth + (screenWidth - sidebarWidth) // 2 - textWidth // 2
      textY = screenHeight - 30
      gfx.drawText("Thank you for playing!", textX, textY)
      if fadeAmount2 < 1.0 then
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(fadeAmount2, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(textX, textY, textWidth, textHeight)
      end
    end

    gfx.setImageDrawMode(gfx.kDrawModeCopy)
  end

  if gs.bossPhase == 3 and gs.bossPhaseFrame >= 500 then
    local perlY = math.min(3, math.max(-3, gfx.perlin(0, (gs.frameCount % 100) / 100, 0, 0) * 20 - 10))
    gfx.setFont(assets.fonts.menu)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("Ⓐ", screenWidth - 16, screenHeight - 16 + perlY)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
  end

  for _, target in pairs(gs.targets) do
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.7, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos.x, target.pos.y, target.radius)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos.x - 2, target.pos.y - 2, target.radius - 2)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
    gfx.fillCircleAtPoint(target.pos.x - 4, target.pos.y - 4, target.radius - 4)

    if target.state == 'active' then
      gfx.setColor(gfx.kColorWhite)
      gfx.drawRoundRect(target.pos.x - 16, target.pos.y + target.radius + 6, 33, 4, 2)
      gfx.fillRoundRect(target.pos.x - 16, target.pos.y + target.radius + 6, 33 * target.health / target.maxHealth, 4, 2)
    end
  end
end
