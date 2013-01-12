
require "vec2"
require "player"

local w,h
local camera_pos
local map
local img
local tasks = {}

function love.load ()
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  camera_pos = vec2:new{ w/2, h/2 }
  img = love.graphics.newImage "tile/ice.png"
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
  player.load(love.graphics)
  tasks.move = function (dt) player.move(map, dt) end
end


function love.update (dt)
  for k,v in pairs(tasks) do
    v(dt)
  end
end

local speedhack = {
  up    = vec2:new{  0, -10 },
  left  = vec2:new{ -6,  0 },
  right = vec2:new{  6,  0 }
}

function love.keypressed (button)
  local dv = speedhack[button]
  if dv then
    player.accelerate(dv)
  end
end

function love.keyreleased (button)
  local dv = speedhack[button]
  if dv then
    player.accelerate(-dv)
  end
end

local function getmousetile ()
  local x,y = love.mouse.getPosition()
  local i,j = math.floor(y/32)+1, math.floor(x/32)+1
  return map[i] and map[i][j]
end

local function addtile ()
  local tile = getmousetile()
  if tile then
    tile.img = img
    tile.floor = true
  end
end

local function removetile ()
  local tile = getmousetile()
  if tile then
    tile.img = nil
    tile.floor = false
  end
end

function love.mousepressed (x, y, button)
  if button == 'l' then
    tasks.addtile = addtile
  elseif button == 'r' and not tasks.addtile then
    tasks.removetile = removetile
  end
end

function love.mousereleased (x, y, button)
  if button == 'l' then
    tasks.addtile = nil
  elseif button == 'r' then
    tasks.removetile = nil
  end
end

function love.draw ()
  love.graphics.rectangle('line', 0, 0, #map[1]*32, #map*32)
  for y,row in ipairs(map) do
    for x,tile in ipairs(row) do
      if tile.img then
        love.graphics.draw(tile.img, 32*(x-1), 32*(y-1))
      end
    end
  end
  player.draw(love.graphics)
end

