
require 'vec2'
require 'map'
require 'avatar'
require 'builder'
require 'message'

local w,h
local camera_pos
local tasks = {}
local avatars = {}

function love.load ()
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  camera_pos = vec2:new{ w/2, h/2 }
  map.load(love.graphics)


  local player = avatar:new {
    pos    = vec2:new{ 2, 9 },
    spd    = vec2:new{ 0, 0 },
    sprite = builder.build_sprite(),
    frame  = { i=4, j=1 },
  }
  function player:try_interact()
    collisions = player.hitbox:get_collisions("avatar")
    for _,target in pairs(collisions) do
      if target.owner and target.owner ~= self
         and (self.pos - target.owner.pos):length() < 1.5 then
        target.owner:interact(self)
      end
    end
  end

  tasks.check_collisions = hitbox.check_collisions

  hitbox
    :new {
      pos = vec2:new{ 17, 8 },
      size = vec2:new{ 2, 2 }
    }
    :register 'damageable'
  avatars.player = player
  table.insert(avatars, builder.build_npc())
  table.insert(avatars, builder.build_vendor())
  table.insert(avatars, builder.build_enemy())
  table.insert(avatars, builder.build_item())

  tasks.updateavatars = function (dt)
    for _,av in pairs(avatars) do
      av:update(dt)
    end
  end

  message.add_receiver(
    'game',
    function (cmd, ...)
      if cmd == 'kill' then
        for _,avatar in ipairs{...} do
          for i,check in ipairs(avatars) do
            if avatar == check then
              avatar:die()
              table.remove(avatars, i)
            end
          end
        end
      end
    end
  )
end


function love.update (dt)
  for k,v in pairs(tasks) do
    v(dt)
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
  elseif button == "x" then
    avatars.player:attack()
  elseif button == "a" then
    if avatars.player.equipment[1] then
      avatars.player:equip(1, nil)
    else
      avatars.player:equip(1, {})
    end
  elseif button == "up" then
    if avatars.player.try_interact then
      avatars.player:try_interact()
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
  screencenter = vec2:new{ love.graphics.getWidth(), love.graphics.getHeight() } * 0.5
  love.graphics.translate((screencenter - avatars.player.pos * map.get_tilesize()):get())
  map.draw(love.graphics)
  for _,av in pairs(avatars) do
    av:draw(love.graphics)
  end
  hitbox.draw_all(love.graphics)
end

