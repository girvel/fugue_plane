local algebra = {}

local F = 100

--- @param point vector
--- @return vector
algebra.project = function(point)
  return Vector {
    F * point.y / (F + point.x),
    F * point.z / (F + point.x),
  }
end

return algebra
