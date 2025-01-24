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

local matrix = require("matrix")


math.randomseed(os.clock())

local SQUARE_MESH_FORMAT = {
  {"VertexPosition", "float", 3},
  {"VertexColor", "byte", 4},
}

local n = 100
local y = -10

--- @param position vector
--- @param size vector
--- @param color vector
--- @return love.Mesh
local rect_mesh = function(position, size, color)
  local edge1 = Vector {0, 0, n}
  local edge2 = Vector {n, 0, 0}
  return love.graphics.newMesh(
    SQUARE_MESH_FORMAT,
    Log {(position + edge1 + edge2) .. color,
     (position + edge1) .. color,
     (position) .. color,
     (position + edge2) .. color},
    -- {{n, y, n, unpack(color)},
    --  {0, y, n, unpack(color)},
    --  {0, y, 0, unpack(color)},
    --  {n, y, 0, unpack(color)}},
    "fan"
  )
end


--- @diagnostic disable-next-line:param-type-mismatch
local shader = love.graphics.newShader(nil, "normal.vert")

local n = 100
local y = -10

local meshes = {
  rect_mesh(Vector.x3.down * 10, nil, Vector {1, 0, 0, 1}),
  rect_mesh(Vector.x3.down * 25 + Vector.x3.front * 100, nil, Vector {0, 1, 0, 1}),
}

local position = Vector.x3.back * 3
local rotation = {
  yaw = math.pi / 2,
  pitch = 0,
  _vector = Vector.x3.back,
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
  shader:send("projection", "column", matrix.get_projection_matrix(45, w / h, 1., 1000.))
  shader:send("view", "column", matrix.look_at(position, position + rotation._vector, Vector.x3.up))
  --shader:send("view", "column", {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}})

  love.graphics.clear(.2, .2, .2, 1)
  for _, mesh in ipairs(meshes) do
    love.graphics.draw(mesh)
  end
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

love.update = function(dt)
  local delta = Vector.x3.zero

  local forward = -rotation._vector  -- TODO! wtf rotation is inverted?
  local left = rotation._vector:vector_product(Vector.x3.up)
  for _, pair in ipairs({
    {"w", forward},
    {"a", left},
    {"s", -forward},
    {"d", -left},
  }) do
    local key, direction = unpack(pair)
    if love.keyboard.isDown(key --[[@as string]]) then
      delta = delta + direction
    end
  end

  local SPEED = 0.15
  position = position + delta:mut_normalize() * SPEED
end

love.keypressed = function(key)
  if key == "escape" then
    love.event.quit()
  end
end
