local state = {}

--- @param start vector
--- @param finish vector
local line = function(start, finish)
  return {start = start, finish = finish}
end

--- @param size number
--- @param corner_position vector
local build_cube = function(size, corner_position)
  local point_000 = corner_position
  local point_100 = corner_position + Vector {1, 0, 0} * size
  local point_010 = corner_position + Vector {0, 1, 0} * size
  local point_110 = corner_position + Vector {1, 1, 0} * size
  local point_001 = corner_position + Vector {0, 0, 1} * size
  local point_101 = corner_position + Vector {1, 0, 1} * size
  local point_011 = corner_position + Vector {0, 1, 1} * size
  local point_111 = corner_position + Vector {1, 1, 1} * size

  return {
    line(point_000, point_001),
    line(point_001, point_011),
    line(point_011, point_010),
    line(point_010, point_000),

    line(point_100, point_101),
    line(point_101, point_111),
    line(point_111, point_110),
    line(point_110, point_100),

    line(point_000, point_100),
    line(point_001, point_101),
    line(point_010, point_110),
    line(point_011, point_111),
  }
end

state.create = function()
  return {
    lines = build_cube(100, Vector {1, -50, -50}),
  }
end

return state
