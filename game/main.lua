
require "vec2"

local w,h
local camera_pos
local player = {}
local map
local img
local quads = {}
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
  player.pos = vec2:new{ 1, 9 }
  player.spd = vec2:new{ 0, 5 }
  player.img = love.graphics.newImage "sprite/male_spritesheet.png"
  player.frame = { i=4, j=1 }
  for i=1,13 do
    quads[i] = {}
    for j=1,9 do
      quads[i][j] = love.graphics.newQuad(
        64*(j-1),
        64*(i-1),
        64, 64, player.img:getWidth(), player.img:getHeight()
      )
    end
  end
end

local function colliding ()
  local i,j = math.floor(player.pos.y), math.floor(player.pos.x)
  return map[i] and (map[i][j] and map[i][j].floor) or false
end

function love.update (dt)
  player.pos:add(player.spd*dt)
  if colliding() then
    player.pos.y = player.pos.y - player.spd.y*dt
  end
  for k,v in pairs(tasks) do
    v()
  end
end

local movehack = {
  up    = vec2:new{  0, -10 },
  down  = vec2:new{  0,  0 },
  left  = vec2:new{ -6,  0 },
  right = vec2:new{  6,  0 }
}

function love.keypressed (button)
  local move = movehack[button]
  if move then
    player.spd:add(move)
  end
  if button == 'right' then
    player.frame.i = 4
  elseif button == 'left' then
    player.frame.i = 2
  end
end

function love.keyreleased (button)
  local move = movehack[button]
  if move then
    player.spd:sub(move)
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
  for y,row in ipairs(map) do
    for x,tile in ipairs(row) do
      if tile.img then
        love.graphics.draw(tile.img, 32*(x-1), 32*(y-1))
      end
    end
  end
  love.graphics.drawq(
    player.img,
    quads[player.frame.i][player.frame.j],
    32*(player.pos.x-1), 32*(player.pos.y-1),
    0, 1, 1,
    32, 62)
end

