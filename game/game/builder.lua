
module ('builder', package.seeall)

require 'game.vec2'
require 'things.avatar'
require 'things.collectable'
require 'game.sprite'
require 'game.spritedata'
require 'game.message'
require 'game.sound'
require 'spriteeffect.speech'


local sprite_class = sprite
local spritedata_cache = {}
function sprite(name)
  local data = spritedata_cache[name]
  if not data then
    local filedata = love.filesystem.load('game/builders/sprite/' .. name .. '.lua')()
    filedata.img = love.graphics.newImage(filedata.img)
    filedata.hotspot = vec2:new(filedata.hotspot)
    for i, val in ipairs(filedata.collpts) do
      filedata.collpts[i] = vec2:new(val)
    end
    data = spritedata:new(filedata)
    spritedata_cache[name] = data
  end
  return sprite_class:new{ data = data }
end

function thing(name, ...)
  local create = love.filesystem.load('game/builders/thing/' .. name .. '.lua')()
  return create(...)
end

function bumpbox (type)
  return hitbox:new {
    class         = 'bump_'..type,
    targetclass   = 'bump_'..type,
    on_collision  = function (self, collisions)
      for _,another in ipairs(collisions) do
        if not self.owner then return end
        if self ~= another and another.owner then
          local dir = another.owner.pos - self.owner.pos
          another.owner:shove(2*dir:normalized()/(dir:length()^2))
        end
      end
    end
  }
end

local speedhack = {
  left  = vec2:new{ -10,  0 },
  right = vec2:new{  10,  0 }
}
function add_keyboard_input(player)
  function player.tasks.check_input(self, dt)
    if love.keyboard.isDown "left" then
      self:accelerate(speedhack.left)
    end
    if love.keyboard.isDown "right" then
      self:accelerate(speedhack.right)
    end
  end
  function player:input_pressed(button, joystick, mouse)
    if joystick or mouse then return end
    if button == "z" then
      self:jump()
    elseif button == "x" then
      self:attack()
    elseif button == 'c' then
      self:dash()
    elseif button == "up" then
      self:try_interact()
    end
  end
  function player:input_released(button, joystick, mouse)
    if joystick or mouse then return end
  end
end

function add_joystick_input(player, joystick)
  joystick = joystick or 1
  local joystick_database = {
    ["Twin USB Joystick"] = {
      jump = 3,
      attack = 4,
      dash = 8,
      direction = function(dir)
        return love.joystick.getHat(joystick,1):find(dir, 1, true) ~= nil
      end
    },
    {
      jump = 1,
      attack = 2,
      dash = 3,
      direction = function(dir)
        if dir == "l" then
          return love.joystick.getAxis(joystick,1) < -0.2
        elseif dir == "r" then
          return love.joystick.getAxis(joystick,1) > 0.2
        elseif dir == "u" then
          return love.joystick.getAxis(joystick,2) < -0.2
        elseif dir == "d" then
          return love.joystick.getAxis(joystick,2) > 0.2
        end
      end
    }
  }
  local joy = joystick_database[love.joystick.getName(joystick)] or joystick_database[1]
  local up_pressed = false
  function player.tasks.check_input(self, dt)
    if joy.direction("l") then
      self:accelerate(speedhack.left)
    end
    if joy.direction("r") then
      self:accelerate(speedhack.right)
    end
    if joy.direction("u") then
      if not up_pressed then
        self:try_interact()
        up_pressed = true
      end
    else
      up_pressed = false
    end
  end
  function player:input_pressed(button, joystick, mouse)
    if not joystick then return end
    if button == joy.jump then
      self:jump()
    elseif button == joy.attack then
      self:charge()
    elseif button == joy.dash then
      self:dash()
    end
  end
  function player:input_released(button, joystick, mouse)
    if not joystick then return end
    if button == joy.attack then
      self:attack()
    end
  end
end

