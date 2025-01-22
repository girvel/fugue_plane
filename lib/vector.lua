local module_mt = {}
--- @overload fun(coordinates: number[]): vector
local vector = setmetatable({}, module_mt)

--- @class vector
--- @field [1] number
--- @field [2] number
--- @field [3] number
--- @field [4] number
--- @operator add(vector): vector
--- @operator sub(vector): vector
--- @operator mul(number): vector
--- @operator div(number): vector
--- @operator unm(): vector
local vector_methods = {}
local vector_mt = {
  __index = vector_methods,
}


-- CONSTRUCTOR --

module_mt.__call = function(_, coordinates)
  return setmetatable(coordinates, vector_mt)
end


-- CONSTANTS --

vector.x3 = {
  zero = vector {0, 0, 0},
  up = vector {0, 1, 0},
  down = vector {0, -1, 0},
  front = vector {0, 0, -1},
  back = vector {0, 0, 1},
}


-- OPERATORS --

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

vector_mt.__mul = function(self, n)
  local result = vector {}
  for i = 1, #self do
    result[i] = self[i] * n
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
  for i = 1, #self do
    self[i] = self[i] / length
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
