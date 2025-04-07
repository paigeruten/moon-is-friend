local pd = playdate

SaveData = {}

SaveData.data = pd.datastore.read() or { highScore = 0, missions = {} }

function SaveData.completeMission(missionId)
  if not SaveData.data.missions then
    SaveData.data.missions = {}
  end
  if not SaveData.data.missions[missionId] then
    SaveData.data.missions[missionId] = {}
  end
  SaveData.data.missions[missionId].complete = true
  pd.datastore.write(SaveData.data)
end

function SaveData.isMissionComplete(missionId)
  return SaveData.data.missions and SaveData.data.missions[missionId] and SaveData.data.missions[missionId].complete
end
