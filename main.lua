Vector = require("lib.vector")
Math = require("lib.math")
Log = require("vendor.log")


local algebra = require("algebra")


love.load = function()
  State = require("state").create()
end

love.draw = function()
  love.graphics.setBackgroundColor(.2, .2, .2)

  local camera_offset = Vector {love.graphics.getDimensions()} / 2

  for _, line in ipairs(State.lines) do
    local start = algebra.project(line.start) + camera_offset
    local finish = algebra.project(line.finish) + camera_offset

    love.graphics.line(unpack(start .. finish))
  end
end

love.keypressed = function(key)
  if key == "escape" then
    love.event.quit()
  end
end
