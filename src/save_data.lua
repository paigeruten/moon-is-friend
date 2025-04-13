local pd = playdate

SaveData = {}

SaveData.data = pd.datastore.read() or {}
if not SaveData.data.highScores then
  SaveData.data.highScores = {}
end
if not SaveData.data.missions then
  SaveData.data.missions = {}
end

function SaveData.completeMission(missionId)
  if not SaveData.data.missions[missionId] then
    SaveData.data.missions[missionId] = {}
  end
  SaveData.data.missions[missionId].complete = true
  pd.datastore.write(SaveData.data)
end

function SaveData.isMissionComplete(missionId)
  return SaveData.data.missions[missionId] and SaveData.data.missions[missionId].complete
end

function SaveData.isEndlessModeUnlocked(mode, n)
  if mode == 'standard' then
    if n == 1 then
      return SaveData.isMissionComplete('1-1'), '1-1'
    elseif n == 2 then
      return SaveData.isMissionComplete('2-4'), '2-4'
    elseif n == 3 then
      return SaveData.isMissionComplete('5-2'), '5-2'
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
