local pd = playdate

Util = {}

function Util.deg2rad(deg)
  return deg * math.pi / 180
end

local deg2rad = Util.deg2rad

function Util.rad2deg(rad)
  return rad * 180 / math.pi
end

function Util.polarCoordinates(length, angle)
  local radians = deg2rad(angle - 90)
  return length * math.cos(radians), length * math.sin(radians)
end

local workVec = pd.geometry.vector2D.new(0, 0)
local upVec = pd.geometry.vector2D.new(0, -1)

function Util.angleFromVec(x, y)
  workVec.dx = x
  workVec.dy = y
  local angle = upVec:angleBetween(workVec)
  if angle < 0 then
    angle += 360
  end
  return angle
end
