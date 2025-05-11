local pd = playdate
local gs = Game.state
local assets = Assets

Explosion = {}

function Explosion.spawn(x, y)
  gs.curExplosionId += 1
  local id = gs.curExplosionId
  gs.explosions[id] = {
    x = x,
    y = y,
    frame = 0,
  }
end

function Explosion.screenShake(shakeTime, shakeMagnitude)
  if not SaveData.isScreenShakeEnabled() then
    return
  end

  local shakeTimer = pd.timer.new(shakeTime, shakeMagnitude, 0)

  shakeTimer.updateCallback = function(timer)
    -- Using the timer value, so the shaking magnitude
    -- gradually decreases over time
    local magnitude = math.floor(timer.value)
    local shakeX = math.random(-magnitude, magnitude)
    local shakeY = math.random(-magnitude, magnitude)
    pd.display.setOffset(shakeX, shakeY)
  end

  shakeTimer.timerEndedCallback = function()
    pd.display.setOffset(0, 0)
  end
end

function Explosion.draw()
  local idsToRemove = {}
  for id, explosion in pairs(gs.explosions) do
    local animFrame = explosion.frame // 5 + 1
    if animFrame <= #assets.gfx.explosion then
      assets.gfx.explosion:getImage(animFrame):drawAnchored(explosion.x, explosion.y, 0.5, 0.5)
      explosion.frame += 1
    else
      table.insert(idsToRemove, id)
    end
  end
  for _, id in ipairs(idsToRemove) do
    gs.explosions[id] = nil
  end
end
