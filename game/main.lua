
local w,h

function love.load ()
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
end

function love.draw ()
  love.graphics.print("VIKINGS", w/2, h/2, 0, 1, 1)
end

