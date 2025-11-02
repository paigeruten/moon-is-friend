local pd = playdate
local gs = Game.state

SaveData = {}

SaveData.data = pd.datastore.read() or {}
if not SaveData.data.highScores then
  SaveData.data.highScores = {}
end
if not SaveData.data.missions then
  SaveData.data.missions = {}
end
if not SaveData.data.settings then
  SaveData.data.settings = {}
end
if SaveData.data.settings.screenShakeEnabled == nil then
  SaveData.data.settings.screenShakeEnabled = not pd.getReduceFlashing()
end
if SaveData.data.settings.showAsteroidPaths == nil then
  SaveData.data.settings.showAsteroidPaths = true
end

function SaveData.completeMission(missionId, difficulty)
  if not SaveData.data.missions[missionId] then
    SaveData.data.missions[missionId] = {}
  end
  SaveData.data.missions[missionId].complete = true
  if difficulty == 'hard' or difficulty == 'one_heart' then
    SaveData.data.missions[missionId].completeOnHard = true
  end
  if difficulty == 'one_heart' then
    SaveData.data.missions[missionId].completeOnOneHeart = true
  end
  pd.datastore.write(SaveData.data)
end

function SaveData.countMissionsComplete(difficulty)
  local count = 0
  for _, row in ipairs(MISSION_TREE) do
    for _, missionId in ipairs(row) do
      if SaveData.isMissionComplete(missionId, difficulty) then
        count += 1
      end
    end
  end
  return count
end

function SaveData.isMissionComplete(missionId, difficulty)
  return SaveData.data.missions[missionId] and SaveData.data.missions[missionId].complete and
      (difficulty ~= 'hard' or SaveData.data.missions[missionId].completeOnHard) and
      (difficulty ~= 'one_heart' or SaveData.data.missions[missionId].completeOnOneHeart)
end

function SaveData.isEndlessModeUnlocked(mode, n)
  if mode == 'standard' then
    if n == 1 then
      return true
    elseif n == 2 then
      return SaveData.isMissionComplete('2-4'), '2-4'
    elseif n == 3 then
      return SaveData.isMissionComplete('5-3'), '5-3'
    end
  elseif mode == 'juggling' then
    if n == 3 then
      return SaveData.isMissionComplete('2-3'), '2-3'
    elseif n == 4 then
      return SaveData.isMissionComplete('4-3'), '4-3'
    elseif n == 5 then
      return SaveData.isMissionComplete('6-B'), '6-B'
    end
  end
  return false, nil
end

function SaveData.isAnyEndlessModeUnlocked(mode)
  if mode == 'standard' then
    return SaveData.isEndlessModeUnlocked(mode, 1) or
        SaveData.isEndlessModeUnlocked(mode, 2) or
        SaveData.isEndlessModeUnlocked(mode, 3)
  elseif mode == 'juggling' then
    return SaveData.isEndlessModeUnlocked(mode, 3) or
        SaveData.isEndlessModeUnlocked(mode, 4) or
        SaveData.isEndlessModeUnlocked(mode, 5)
  end
  return false
end

function SaveData.getHighScore(missionId)
  return SaveData.data.highScores[missionId]
end

function SaveData.checkAndSaveHighScore(missionId, score)
  if not SaveData.data.highScores[missionId] or score > SaveData.data.highScores[missionId] then
    SaveData.data.highScores[missionId] = score
    pd.datastore.write(SaveData.data)
    return true
  end
  return false
end

function SaveData.isScreenShakeEnabled()
  return SaveData.data.settings.screenShakeEnabled
end

function SaveData.setScreenShakeEnabled(enabled)
  SaveData.data.settings.screenShakeEnabled = enabled
  pd.datastore.write(SaveData.data)
end

function SaveData.getShowAsteroidPaths()
  return SaveData.data.settings.showAsteroidPaths
end

function SaveData.setShowAsteroidPaths(enabled)
  SaveData.data.settings.showAsteroidPaths = enabled
  pd.datastore.write(SaveData.data)
end

function SaveData.loadLastEndlessOptions()
  if not SaveData.data.settings.lastEndlessOptions then
    SaveData.data.settings.lastEndlessOptions = {}
  end

  gs.endlessMode = SaveData.data.settings.lastEndlessOptions.mode
  if gs.endlessMode ~= 'standard' and gs.endlessMode ~= 'juggling' then
    gs.endlessMode = 'standard'
  end

  gs.endlessMoons = SaveData.data.settings.lastEndlessOptions.moons
  if gs.endlessMoons ~= 1 and gs.endlessMoons ~= 2 and gs.endlessMoons ~= 3 then
    gs.endlessMoons = 1
  end

  gs.endlessAsteroids = SaveData.data.settings.lastEndlessOptions.asteroids
  if gs.endlessAsteroids ~= 3 and gs.endlessAsteroids ~= 4 and gs.endlessAsteroids ~= 5 then
    gs.endlessAsteroids = 3
  end

  gs.endlessZenMode = SaveData.data.settings.lastEndlessOptions.zen
  if type(gs.endlessZenMode) ~= 'boolean' then
    gs.endlessZenMode = false
  end
end

function SaveData.saveLastEndlessOptions()
  SaveData.data.settings.lastEndlessOptions = {
    mode = gs.endlessMode,
    moons = gs.endlessMoons,
    asteroids = gs.endlessAsteroids,
    zen = gs.endlessZenMode,
  }
  pd.datastore.write(SaveData.data)
end
