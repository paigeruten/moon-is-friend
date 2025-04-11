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
