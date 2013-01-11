
local w,h
local camera_pos = {}
local player = {}
local map
local img
--zuei
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
    local tile = map[10][i]
    tile.img = img
    tile.floor = true
  end
  player.pos = { x=1, y=9 }
  player.spd = { x=0, y=0 }
end

function love.update (dt)
  player.pos.x = player.pos.x + player.spd.x*dt
  player.pos.y = player.pos.y + player.spd.y*dt
end

local movehack = {
  up = { x=0, y=-1 },
  down = { x=0, y=1 },
  left = { x=-1, y=0 },
  right = { x=1, y=0 }
}

function love.keypressed (button)
  local move = movehack[button]
  if move then
    player.spd.x = player.spd.x + move.x*3
    player.spd.y = player.spd.y + move.y*3
  end
end

function love.keyreleased (button)
  local move = movehack[button]
  if move then
    player.spd.x = player.spd.x - move.x*3
    player.spd.y = player.spd.y - move.y*3
  end
end

function love.draw ()
  for y,row in ipairs(map) do
    for x,tile in ipairs(row) do
      if tile.img then
        love.graphics.draw(tile.img, 32*(x-1), 32*(y-1))
      end
    end
  end
  love.graphics.print("VIKING", 32*(player.pos.x-1), 32*(player.pos.y-1))
end

