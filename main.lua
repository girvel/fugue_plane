love.draw = function()
  love.graphics.print("Hello, world!", 100, 100)
end

love.keypressed = function(key)
  if key == "escape" then
    love.event.quit()
  end
end
