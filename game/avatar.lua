
require 'thing'
require 'slash'
require 'vec2'
require 'hitbox'
require 'message'
require 'sound'
require 'animationset.viking'
require 'spriteeffect.blink'

avatar = thing:new {
  slashspr      = nil,
  maxlife       = 200,
  animationset  = nil,

  dmg_delay     = 0,
  charging      = -1,
  attacking     = false,
  life          = nil, -- will be set to maxlife if not set
}

function avatar:__init()
  self.life = self.life or self.maxlife
  self.equipment = {}
  self.hitboxes.helpful.class = "avatar"
  self.animationset = self.animationset or animationset.viking
  self.slash = slash:new{
    source = self,
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
local max_equipment_slot = 2
local WEAPON_SLOT   = 1
local ARMOR_SLOT    = 2

function avatar:die ()
  avatar:__super().die(self)
  self.slash:die()
  for slot,equip in pairs(self.equipment) do
    if equip then
      self:drop(slot)
    end
  end
end

function avatar:apply_gravity (dt)
  if not self.dashing then
    avatar:__super().apply_gravity(self, dt)
  end
end

function avatar:update_sprite (dt)
  local moving = self.accelerated
  if not moving and not self.attacking then
    self.sprite:play_animation(self.animationset.standing)
  elseif self.attacking then
    self.sprite:play_animation(self.animationset.attacking)
  else
    self.sprite.speed = math.max(math.abs(self.spd.x)/5, 0.4)
    self.sprite:play_animation(self.animationset.moving)
  end
  avatar:__super().update_sprite(self, dt)
  self.sprite.speed = 1
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
    sound.effect('jump', self.pos)
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
    sound.effect('slash', self.pos)
    self.attacking = true
    self.sprite:play_animation(self.animationset.attacking)
    self.sprite:restart_animation()
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
  self.slash:deactivate()
  self.dashing = false
end

function avatar:get_equip(slot)
  return self.equipment[slot]
end

function avatar:get_damage()
  return self.equipment[WEAPON_SLOT] and self.equipment[WEAPON_SLOT].damage or 0
end

function avatar:get_armor()
  return self.equipment[ARMOR_SLOT] and self.equipment[ARMOR_SLOT].armor or 0
end

function avatar:get_weight()
  local weight = 1
  for _,equip in pairs(self.equipment) do
    weight = weight + equip.weight
  end
  return weight
end

function avatar:equip(slot, item)
  if slot >= min_equipment_slot and slot <= max_equipment_slot then
    if self.equipment[slot] then
      self:drop(slot)
    end
    self.equipment[slot] = item
    return true
  end
  return false
end

function avatar:drop (slot)
  self.equipment[slot].pos = self.pos:clone()
  self.equipment[slot].pick_delay = 1
  message.send [[game]] {'add', self.equipment[slot]}
  self.equipment[slot] = nil
end

function avatar:take_damage (amount)
  if self.dmg_delay > 0 then return end
  amount = amount - self:get_armor()
  --if amount <= 0 then return end
  self.life = math.max(self.life - amount, 0)
  self.dmg_delay = 0.5
  sound.effect('hit', self.pos)
  self.sprite.effects.blink = spriteeffect.blink:new{ color = {150, 20, 20} }
  if self.life <= 0 then
    message.send 'game' {'kill', self}
  end
  return true
end

function avatar:draw (graphics)
  local debug = message.send [[game]] {'debug'}
  local font = love.graphics.getFont()
  local s = self.life .. "/" .. self.maxlife
  if debug and self.equipment[1] then s = s .. "*" end
  graphics.setColor(255, 255, 255)
  graphics.print(
    s,
    self.pos.x * map.get_tilesize() + 1,
    self.pos.y * map.get_tilesize() + 1,
    0, 1, 1,
    font:getWidth(s),
    font:getHeight(s) + self.sprite.data.quadsize
  )
  graphics.setColor(0, 0, 0)
  graphics.print(
    s,
    self.pos.x * map.get_tilesize(),
    self.pos.y * map.get_tilesize(),
    0, 1, 1,
    font:getWidth(s),
    font:getHeight(s) + self.sprite.data.quadsize
  )
  graphics.setColor(255, 255, 255)
  if debug and self.equipment[1] then
    local glow = self.charging >= 0 and self.charging/DASH_THRESHOLD or 0
    graphics.setColor(255, 255*(1-glow), 255)
  end
  self.sprite:draw(graphics, self.pos)
  graphics.setColor(255, 255, 255)
  if self.slash and self.attacking and self.slash.activated then
    self.slash:draw(graphics)
  end
  for _, task in pairs(self.drawtasks) do
    task(self, graphics)
  end
end
