
require 'vec2'
require 'map'
require 'player'

local w,h
local camera_pos
local tasks = {}

function love.load ()
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  camera_pos = vec2:new{ w/2, h/2 }
  map.load(love.graphics)
  player.load(love.graphics)
  tasks.move = player.move
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
-- these allows for double maximum speed...
speedhack.w = speedhack.up
speedhack.a = speedhack.left 
speedhack.d = speedhack.right

function love.keypressed (button)
  local dv = speedhack[button]
  if dv then
    player.accelerate(dv)
  elseif button == "escape" then
    love.event.push("quit")
  end
end

function love.keyreleased (button)
  local dv = speedhack[button]
  if dv then
    player.accelerate(-dv)
  end
end

local function mousetotile ()
  local x,y = love.mouse.getPosition()
  return math.floor(y/32)+1, math.floor(x/32)+1
end

local function tilesetter (typeid)
  return function ()
    local i, j = mousetotile()
    map.set_tile(i, j, typeid)
  end
end

function love.mousepressed (x, y, button)
  if button == 'l' then
    tasks.addtile = tilesetter 'ice'
  elseif button == 'r' and not tasks.addtile then
    tasks.removetile = tilesetter 'empty'
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
  map.draw(love.graphics)
  player.draw(love.graphics)
end

