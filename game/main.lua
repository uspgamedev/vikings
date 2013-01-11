
local w,h
local camera_pos
local map
local img

function love.load ()
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  camera_pos = { x=w/2, y=h/2 }
  img = love.graphics.newImage "ice.png"
  map = {}
  for i=1,15 do
    map[i] = {}
    for j=1,20 do
      map[i][j] = {}
    end
  end
  for i=1,20 do
    map[10][i].img = img
  end
end

function love.update (dt)

end

function love.draw ()
  for i=1,15 do
    for j=1,20 do
      if map[i][j].img then
        love.graphics.draw(map[i][j].img, 32*(j-1), 32*(i-1))
      end
    end
  end
end

