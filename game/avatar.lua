
require 'thing'
require 'slash'
require 'vec2'
require 'hitbox'
require 'message'
require 'sound'

avatar = thing:new {
  slashspr  = nil,
  life      = 200,

  dmg_delay = 0,
  charging  = -1,
  attacking = false
}

function avatar:__init() 
  self.equipment = {}
  self.hitboxes.helpful.class = "avatar"
  self.slash = slash:new{
    source = self,
    damage = 5,
    sprite = self.slashspr
  }
  self.slashspr = nil

  self.airjumpsleft = 0
end

local JUMPSPDY        = -14
local MINDASH         = 3
local DASH_THRESHOLD  = 0.25
local MAXCHARGE       = 1
local DASHCOEF        = 13
local min_equipment_slot = 1
local max_equipment_slot = 1

function avatar:apply_gravity (dt)
  if not self.dashing then
    avatar:__super().apply_gravity(self, dt)
  end
end

function avatar:update_animation (dt)
  self.frame.i =
    self.sprite:frame_from_direction(self.direction)
    +
    (self.attacking and 4 or 0)
  local moving = self.accelerated
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
    self.slash:activate()
  end
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
  avatar:__super().update(self, dt, map)
  if self.air == 0 then
    self.airjumpsleft = 1
  end
  self.slash:update(dt, map)
  self.dmg_delay = math.max(self.dmg_delay - dt, 0)
  if self.charging >= 0 then
    self.charging = math.min(self.charging + dt, DASH_THRESHOLD)
  end
end

function avatar:jump ()
  if self.airjumpsleft > 0 or self.air == 0 then
    if self.air > 0 then
      self.airjumpsleft = self.airjumpsleft - 1
    end
    self.spd.y = JUMPSPDY
    sound.effect 'jump'
  end
end

function avatar:accelerate (dv)
  if not self.attacking then
    avatar:__super().accelerate(self, dv)
  end
end

function avatar:charge ()
  if self.equipment[1] then
    self.charging = 0
  end
end

function avatar:attack ()
  if not self.attacking and self.equipment[1] then
    local charge_time = math.min(math.max(self.charging, 0), MAXCHARGE)
    sound.effect 'slash'
    self.attacking = true
    self.frametime = 0
    self.frame.j = 1
    self.dashing = (charge_time >= DASH_THRESHOLD)
    self.charging = -1
    local sign  = (self.direction=='right' and 1 or -1)
    local dash  = MINDASH+(self.dashing and 1 or 0)*DASHCOEF
    local burst = vec2:new{dash, 0}*sign
    self.spd = burst
  end
end

function avatar:stopattack ()
  self.attacking = false
  self.frame.j = 1
  self.slash:deactivate()
  self.dashing = false
end

function avatar:get_equip(slot)
  return self.equipment[slot]
end

function avatar:equip(slot, item)
  if slot >= min_equipment_slot and slot <= max_equipment_slot then
    self.equipment[slot] = item
    return true
  end
  return false
end

function avatar:take_damage (amount)
  if self.dmg_delay > 0 then return end
  self.life = math.max(self.life - amount, 0)
  self.dmg_delay = 0.5
  sound.effect 'hit'
  if self.life <= 0 then
    message.send 'game' {'kill', self}
  end
  return true
end

function avatar:draw (graphics)
  local glow = self.charging >= 0 and self.charging/DASH_THRESHOLD or 0
  if self.equipment[1] then graphics.setColor(255, 255*glow,   0) end
  self.sprite:draw(graphics, self.pos)
  if self.equipment[1] then graphics.setColor(255, 255, 255) end
  if self.slash and self.attacking and self.frame.j >= 4 then
    self.slash:draw(graphics)
  end
  for _, task in pairs(self.drawtasks) do
    task(self, graphics)
  end
end
