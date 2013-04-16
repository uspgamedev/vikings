
require 'things.thing'
require 'things.slash'
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
  dashtime      = 0,
  dashcooldown  = 0,
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

local JUMPSPDY        = -13.64 -- sqrt(3.1 * 2gravity)

local DASHSPD         = 16
local DASHTIME        = 0.3
local DASHCOOLDOWN    = 0.2

local ATKMOVE         = 3

local DASH_THRESHOLD  = 0.5
local MAXCHARGE       = 1
local min_equipment_slot = 1
local max_equipment_slot = 2
local WEAPON_SLOT   = 1
local ARMOR_SLOT    = 2

function avatar:die ()
  avatar:__super().die(self)
  self.slash:die()
  for _,slot in pairs{WEAPON_SLOT, ARMOR_SLOT} do
    if self.equipment[slot] and math.random() > .5 then
      self:drop(slot)
    end
  end
end

function avatar:apply_gravity (dt)
  if not self:dashing() then
    avatar:__super().apply_gravity(self, dt)
  end
end

function avatar:update_sprite (dt)
  local moving = self.accelerated
  if not moving and not self.attacking and not self:dashing() then
    self.sprite:play_animation(self.animationset.standing)
  elseif self.attacking then
    self.sprite:play_animation(self.animationset.attacking)
  elseif self:dashing() then
    self.sprite:play_animation(self.animationset.dashing)
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
  if self.dashtime > 0 then
    self.dashtime = math.max(self.dashtime - dt, 0)
  elseif self.dashcooldown > 0 then
    self.dashcooldown = math.max(self.dashcooldown - dt, 0)
  end
end

function avatar:jump ()
  if self.airjumpsleft > 0 or self.air == 0 then
    if self.air > 0 then
      self.airjumpsleft = self.airjumpsleft - 1
    end
    local jumpspd = JUMPSPDY
    if self:dashing() and self.airjumpsleft > 0 then
      jumpspd = jumpspd*self:get_slowdown()*2^.5
      self.airjumpsleft = 0
    end
    self.spd.y    = jumpspd
    self:stopdash()
    sound.effect('jump', self.pos)
  end
end

function avatar:accelerate (dv)
  if not self.attacking and not self:dashing() then
    avatar:__super().accelerate(self, dv*self:get_slowdown())
  end
end

function avatar:charge ()
  if self.equipment[1] then
    self.charging = 0
  end
end

function avatar:dashing ()
  return self.dashtime > 0
end

function avatar:dash ()
  if self.attacking or self.dashtime > 0 or self.dashcooldown > 0 then return end
  local sign        = (self.direction=='right' and 1 or -1)
  local burst       = vec2:new{DASHSPD, 0}*sign*self:get_slowdown()
  self.spd          = burst
  self.dashtime     = DASHTIME
  self.dashcooldown = DASHCOOLDOWN
  self.sprite:play_animation(self.animationset.dashing)
  self.sprite:restart_animation()
end

function avatar:stopdash ()
  self.dashtime = 0
end

function avatar:attack ()
  if not self.attacking and self.equipment[1] then
    self:stopdash()
    --local charge_time = math.min(math.max(self.charging, 0), MAXCHARGE)
    local sign        = (self.direction=='right' and 1 or -1)
    sound.effect('slash', self.pos)
    self.attacking = true
    self.sprite:play_animation(self.animationset.attacking)
    self.sprite:restart_animation()
    --self.charging = -1
    self:shove(vec2:new{ATKMOVE, 0}*sign)
  end
end

function avatar:get_slowdown ()
  return 1/(math.max(1, self:get_weight()/10))
end

function avatar:stopattack ()
  self.attacking = false
  self.slash:deactivate()
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
  amount = math.max(amount - self:get_armor(), 0)
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

local function shadowed_text(graphics, text, pos, kx, ky)
  graphics.setColor(255, 255, 255)
  graphics.print(
    text,
    pos.x + 1, pos.y + 1,
    0, 1, 1,
    kx, ky
  )
  graphics.setColor(0, 0, 0)
  graphics.print(
    text,
    pos.x, pos.y,
    0, 1, 1,
    kx, ky
  )
  graphics.setColor(255, 255, 255)
end

function avatar:draw (graphics)
  local debug = message.send [[game]] {'debug'}
  local font = love.graphics.getFont()
  local life_bar = self.life .. "/" .. self.maxlife
  if debug and self.equipment[1] then life_bar = life_bar .. "*" end
  shadowed_text(graphics, 
    life_bar,
    self.pos * map.get_tilesize(),
    font:getWidth(life_bar),
    font:getHeight(life_bar) + self.sprite.data.quadsize
  )
  shadowed_text(graphics, 
    self.name,
    self.pos * map.get_tilesize(),
    font:getWidth(life_bar),
    font:getHeight(life_bar) * 2 + self.sprite.data.quadsize
  )
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
