
require 'thing'
require 'vec2'
require 'hitbox'
require 'message'
require 'sound'

avatar = thing:new {
  slashspr  = nil,
  life      = 200,
  dmg_delay = 0,

  attacking = false
}

function avatar:__init() 
  self.equipment = {}
  self.hitbox.class = "avatar"
  self.atkhitbox = hitbox:new {
    targetclass = 'damageable',
    on_collision = function (self, collisions)
      for _,another in ipairs(collisions) do
        if another.owner then
          another.owner:take_damage(5)
        else
          another:unregister()
        end
      end
    end
  }

  self.jumpsleft = 0
end

local jumpspd   = -12
local min_equipment_slot = 1
local max_equipment_slot = 1

function avatar:die ()
  self.hitbox:unregister()
  self.atkhitbox:unregister()
end

function avatar:update_animation (dt)
  self.frame.i = self.sprite:frame_from_direction(self.direction) + (self.attacking and 4 or 0)
  local moving = self.spd.x ~= 0
  if not moving and not self.attacking then
    self.frame.j = 1
    return
  end
  if self.attacking then
    self:animate_attack(dt)
  else
    self:animate_movement(dt)
  end
end

function avatar:animate_attack (dt)
  self.frametime = self.frametime + dt
  while self.frametime >= 1/self.sprite.animfps do
    if self.frame.j > 6 then
      self:stopattack()
    else
      self.frame.j = self.frame.j + 1
      self.frametime = self.frametime - 1/self.sprite.animfps
    end
  end
  if self.frame.j > 6 then
    self:stopattack()
  end
  if self.attacking and self.frame.j >= 5 then
    self.atkhitbox:register 'playeratk'
  end
end

function avatar:get_atkhitboxpos ()
  return self.pos+vec2:new{(self.direction=='right' and 0.75 or -1.75), -.5}
end

function avatar:get_atkpos ()
  local tilesize = map.get_tilesize()
  return
    self.pos +
    vec2:new{
      (self.direction=='right' and 1 or -1)*0.75,
      -4/tilesize
    }
end

function avatar:update (dt, map)
  if self.atkhitbox then
    self.atkhitbox.pos = self:get_atkhitboxpos()
  end
  self.dmg_delay = math.max(self.dmg_delay - dt, 0)
  avatar:__super().update(self, dt, map)
end

function avatar:jump ()
  if self.jumpsleft > 0 then
    self.jumpsleft = self.jumpsleft - 1
    self.spd.y = jumpspd
    sound.effect 'jump'
  end
end

function avatar:attack ()
  if not self.attacking and self.equipment[1] then
    sound.effect 'slash'
    self.attacking = true
    self.frametime = 0
    self.frame.j = 1
    self.atkhitbox.pos = self:get_atkhitboxpos()
    --self.atkhitbox:register 'playeratk'
  end
end

function avatar:stopattack ()
  if self.attacking then
    self.attacking = false
    self.frame.j = 1
    self.atkhitbox:unregister()
  end
end

function avatar:equip(slot, item)
  if slot >= min_equipment_slot and slot <= max_equipment_slot then
    self.equipment[slot] = item
  end
end

function avatar:take_damage (amount)
  if self.dmg_delay > 0 then return end
  self.life = math.max(self.life - amount, 0)
  self.dmg_delay = 0.5
  sound.effect 'hit'
  if self.life <= 0 then
    message.send 'game' {'kill', self}
  end
end

function avatar:draw (graphics)
  if self.equipment[1] then graphics.setColor(255,   0,   0) end
  self.sprite:draw(graphics, self.frame, self.pos)
  if self.equipment[1] then graphics.setColor(255, 255, 255) end
  if self.slashspr and self.attacking and self.frame.j >= 4 then
    self.slashspr:draw(
      graphics,
      {i=self.frame.j-3, j=1},
      self:get_atkpos(),
      self.direction=='right' and 'h' or nil
    )
  end
  for _, task in pairs(self.drawtasks) do
    task(self, graphics)
  end
end
