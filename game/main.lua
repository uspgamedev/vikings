
require 'vec2'
require 'map'
require 'avatar'
require 'sprite'

local w,h
local camera_pos
local tasks = {}
local avatars = {}
local text = nil
local counter = 0

function love.load ()
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  camera_pos = vec2:new{ w/2, h/2 }
  map.load(love.graphics)

  local butler = sprite:new {
    img       = love.graphics.newImage "sprite/male_spritesheet.png",
    maxframe  = { i=13, j=9 },
    quadsize  = 64,
    hotspot   = vec2:new{ 32, 60 },
    collpts   = {
      vec2:new{20,60},
      vec2:new{20,15+45/2},
      vec2:new{20,15},
      vec2:new{44,60},
      vec2:new{44,15+45/2},
      vec2:new{44,15}
    }
  }

  local player = avatar:new {
    pos    = vec2:new{ 2, 9 },
    spd    = vec2:new{ 0, 0 },
    sprite = butler,
    frame  = { i=4, j=1 },
  }

  local npc = avatar:new {
    pos    = vec2:new{ 12, 9 },
    spd    = vec2:new{ 0, 0 },
    sprite = butler,
    frame  = { i=2, j=1 }
  }
  function npc:interact()
    if (avatars.player.pos - avatars.npc.pos):length() < 1.5 then
      text = "Stay a while and listen."
      counter = 2
    end
  end

  avatars.player = player
  avatars.npc = npc

  tasks.updateavatars = function (dt)
    for _,av in pairs(avatars) do
      av:update(dt)
    end
  end
end


function love.update (dt)
  for k,v in pairs(tasks) do
    v(dt)
  end
  if counter > 0 then
    counter = counter - dt
  else
    text = nil
  end
end

local speedhack = {
  left  = vec2:new{ -5,  0 },
  right = vec2:new{  5,  0 }
}

function love.keypressed (button)
  local dv = speedhack[button]
  if dv then
    avatars.player:accelerate(dv)
  elseif button == "z" then
    avatars.player:jump()
  elseif button == "up" then
    if avatars.npc.interact then
      avatars.npc:interact()
    end
  elseif button == "escape" then
    love.event.push("quit")
  end
end

function love.keyreleased (button)
  local dv = speedhack[button]
  if dv then
    avatars.player:accelerate(-dv)
  end
end

local function mousetotile ()
  local x,y       = love.mouse.getPosition()
  local tilesize  = map.get_tilesize()
  return math.floor(y/tilesize)+1, math.floor(x/tilesize)+1
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
  for _,av in pairs(avatars) do
    av:draw(love.graphics)
  end
  if text then
    love.graphics.setColor(255, 255, 255, math.min(counter, 1) * 255)
    love.graphics.print(text, 
      map.get_tilesize() * (avatars.npc.pos.x - 1),
      map.get_tilesize() * (avatars.npc.pos.y - 3)
    )
    love.graphics.setColor(255, 255, 255, 255)
  end
end

