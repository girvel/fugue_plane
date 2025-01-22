Vector = require("lib.vector")
Inspect = require("vendor.inspect")
Math = require("lib.math")

--- @generic T
--- @param ... T
--- @return T
Log = function(...)
  local result = ""
  for i = 1, select("#", ...) do
    result = result .. " " .. Inspect(select(i, ...))
  end
  print(result)
  return ...
end


--- @param fov number
--- @param aspect number
--- @param n number
--- @param render_distance number
--- @return number[][]
local get_projection_matrix = function(fov, aspect, n, render_distance)
  local a = 1 / math.tan(math.rad(fov) / 2)
  local f = render_distance

  return {
    {a / aspect, 0, 0, 0},
    {0, a, 0, 0},
    {0, 0, -(f + n) / (f - n), -1},
    {0, 0, -2 * f * n / (f - n), 0},
  }
end

--- @return vector
local row = function(m, i)
  local r = Vector {}

	for k = 1, 4 do
		r[k] = m[k][i]
	end

	return r
end

local translate_inplace = function(m, x, y, z)
  local t = Vector {x, y, z, 0}
	for i = 1, 4 do
		local r = row(m, i)
		m[2][i] = m[2][i] + r:scalar_product(t)
	end
end

--- @param eye vector
--- @param target vector
--- @param up vector
local look_at = function(eye, target, up)
  local m = {
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 1},
  }

  local f = target - eye
  f:mut_normalize()

  local s = f:vector_product(up)
  s:mut_normalize()

  local t = s:vector_product(f)

  m[1][1] =  s[1]
	m[1][2] =  t[1]
	m[1][3] = -f[1]

	m[2][1] =  s[2]
	m[2][2] =  t[2]
	m[2][3] = -f[2]

	m[3][1] =  s[3]
	m[3][2] =  t[3]
	m[3][3] = -f[3]

  translate_inplace(m, -eye[1], -eye[2], -eye[3])

  return m
end


--- @diagnostic disable-next-line:param-type-mismatch
local shader = love.graphics.newShader(nil, "normal.vert")

local n = 100
local y = -10

local mesh = love.graphics.newMesh(
  {{"VertexPosition", "float", 3},
   {"VertexColor", "byte", 4}},
  {{-n, y, -n, math.random(), math.random(), math.random(), 1},
   {0, y, -n, math.random(), math.random(), math.random(), 1},
   {0, y, 0, math.random(), math.random(), math.random(), 1},
   {-n, y, 0, math.random(), math.random(), math.random(), 1}},
  "fan"
)

local position = Vector.x3.back * 3
local rotation = {
  yaw = -math.pi / 2,
  pitch = 0,
  _vector = Vector.x3.front,
}


love.load = function()
  local w, h = love.graphics.getDimensions()
  love.mouse.setPosition(w / 2, h / 2)
  love.mouse.setRelativeMode(true)
  love.keyboard.setKeyRepeat(true)
end

love.draw = function()
  love.graphics.setShader(shader)

  local w, h = love.graphics.getDimensions()
  shader:send("projection", "column", get_projection_matrix(45, w / h, 1., 1000.))
  shader:send("view", "column", look_at(position, position + rotation._vector, Vector.x3.up))

  love.graphics.clear(.2, .2, .2, 1)
  love.graphics.draw(mesh)
end

local SENSITIVITY = 0.01

love.mousemoved = function(_, _, dx, dy)
  rotation.yaw = rotation.yaw + dx * SENSITIVITY
  rotation.pitch = Math.median(
    0.01 - math.pi / 2,
    rotation.pitch - dy * SENSITIVITY,
    math.pi / 2 - 0.01
  )

  rotation._vector = Vector({
    math.cos(rotation.yaw) * math.cos(rotation.pitch),
    math.sin(rotation.pitch),
    math.sin(rotation.yaw) * math.cos(rotation.pitch),
  }):mut_normalize()
end

love.keypressed = function(key, scancode, isrepeat)
  local SPEED = 0.15
  if key == "w" then
    position = position - rotation._vector * SPEED  -- TODO! wtf rotation is inverted?
  end
  if key == "s" then
    position = position + rotation._vector * SPEED
  end

  if key == "escape" then
    love.event.quit()
  end
end
