local module_mt = {}
--- @overload fun(coordinates: number[]): vector
local vector = setmetatable({}, module_mt)

--- @class vector
--- @field [1] number
--- @field [2] number
--- @field [3] number
--- @field [4] number
--- @field x number
--- @field y number
--- @field z number
--- @field w number
--- @operator add(vector): vector
--- @operator sub(vector): vector
--- @operator mul(number): vector
--- @operator div(number): vector
--- @operator unm(): vector
--- @operator concat(vector): vector
local vector_methods = {}
local vector_mt = {}


-- CONSTRUCTOR --

module_mt.__call = function(_, coordinates)
  return setmetatable(coordinates, vector_mt)
end


-- CONSTANTS --

vector.x3 = {
  zero = vector {0, 0, 0},
  front = vector {1, 0, 0},
  back = vector {-1, 0, 0},
  left = vector {0, 1, 0},
  right = vector {0, -1, 0},
  down = vector {0, 0, -1},
  up = vector {0, 0, 1},
}

vector.swizzle_base = {
  x = 1,
  y = 2,
  z = 3,
  w = 4,
}


-- OPERATORS --

vector_mt.__index = function(self, key)
  return self[vector.swizzle_base[key]] or vector_methods[key] or rawget(self, key)
end

vector_mt.__newindex = function(self, key, value)
  local coordinate_n = vector.swizzle_base[key]
  if coordinate_n then
    rawset(self, coordinate_n, value)
    return
  end

  rawset(self, key, value)
end

vector_mt.__add = function(self, other)
  local size = #self
  assert(
    size == #other,
    ("Can not add vectors of different lengths: %s and %s"):format(size, #other)
  )

  local result = vector {}
  for i = 1, size do
    result[i] = self[i] + other[i]
  end
  return result
end

vector_mt.__sub = function(self, other)
  local size = #self
  assert(
    size == #other,
    ("Can not subtract vectors of different lengths: %s and %s"):format(size, #other)
  )

  local result = vector {}
  for i = 1, size do
    result[i] = self[i] - other[i]
  end
  return result
end

vector_mt.__unm = function(self)
  local result = vector {}
  for i = 1, #self do
    result[i] = -self[i]
  end
  return result
end

vector_mt.__mul = function(self, n)
  local result = vector {}
  for i = 1, #self do
    result[i] = self[i] * n
  end
  return result
end

vector_mt.__div = function(self, n)
  local result = vector {}
  for i = 1, #self do
    result[i] = self[i] / n
  end
  return result
end

vector_mt.__concat = function(self, other)
  local result = vector {}
  for i = 1, #self do
    result[i] = self[i]
  end
  for i = 1, #other do
    result[i + #self] = other[i]
  end
  return result
end

vector_mt.__tostring = function(self)
  return ("{%s}"):format(table.concat(self, "; "))
end


-- METHODS --

--- @param self vector
--- @param other vector
--- @return number
--- @nodiscard
vector_methods.scalar_product = function(self, other)
  local size = #self
  assert(
    size == #other,
    ("Can not calculate dot product vectors of different lengths: %s and %s"):format(size, #other)
  )

  local result = 0
  for i = 1, size do
    result = result + self[i] * other[i]
  end
  return result
end

--- @param self vector
--- @return number
--- @nodiscard
vector_methods.square_length = function(self)
  return self:scalar_product(self)
end

--- @param self vector
--- @return number
--- @nodiscard
vector_methods.length = function(self)
  return math.sqrt(self:square_length())
end

--- @generic T: vector
--- @param self T
--- @return T
vector_methods.mut_normalize = function(self)
  ---@cast self vector

  local length = self:length()
  if length ~= 0 then
    for i = 1, #self do
      self[i] = self[i] / length
    end
  end
  return self
end

--- @param self vector
--- @param other vector
--- @return vector
--- @nodiscard
vector_methods.vector_product = function(self, other)
  assert(#self == #other and #self == 3)

  local result = vector {}

  result[1] = self[2] * other[3] - self[3] * other[2]
	result[2] = self[3] * other[1] - self[1] * other[3]
	result[3] = self[1] * other[2] - self[2] * other[1]

  return result
end

--- @generic T
--- @param self T
--- @return T
vector_methods.clone = function(self)
  return vector(unpack(self))
end


return vector
