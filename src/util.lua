Util = {}

function Util.polarCoordinates(length, angle)
  local radians = (angle - 90) * math.pi / 180
  return length * math.cos(radians), length * math.sin(radians)
end
