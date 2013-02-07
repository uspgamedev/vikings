
require 'lux.object'
require 'vec2'
require 'hitbox'
require 'message'

avatar = lux.object.new {
  pos       = nil,
  spd       = nil,
  sprite    = nil,
  slashspr  = nil,
  frame     = nil,
  hitbox    = nil,

  direction = 'right',
  attacking = false
}

avatar.__init = {
  pos       = vec2:new{ 0, 0 },
  spd       = vec2:new{ 0, 0 },
  frame     = { i=1, j=1 },
  equipment = {},
  tasks     = {},
  drawtasks = {},
  hitbox    = hitbox:new {
    size  = vec2:new { 1, 1 },
    class = 'avatar'
  },
  atkhitbox = hitbox:new {
    targetclass = 'damageable',
    on_collision = function (self, collisions)
      for _,another in ipairs(collisions) do
        if another.owner then
          message.send 'game' {'kill', another.owner}
        else
          another:unregister()
        end
      end
    end
  },

  jumpsleft = 0,
  frametime = 0
}

local gravity   = vec2:new{  0,  30 }
local maxspd    = vec2:new{ 30,  30 }
local jumpspd   = -12
local min_equipment_slot = 1
local max_equipment_slot = 1
local dir_map   = {
  left = 2, right = 4
}

function avatar:die ()
  self.hitbox:unregister()
  self.atkhitbox:unregister()
end

local function pos_to_tile (map, point)
  return map:get_tile(math.floor(point.y), math.floor(point.x))
end

function avatar:colliding(map, position)
  for _,p in ipairs(self.sprite.collpts) do
    local tile = pos_to_tile(map, position-(self.sprite.hotspot-p)/32)
    if not tile or tile.floor then
      return true
    end
  end
  return false
end

function avatar:update_physics (dt, map)
  -- no, negative speed doesn't increase forever
  self.spd.x = math.min(math.max(-maxspd.x, self.spd.x), maxspd.x)
  self.spd.y = math.min(math.max(-maxspd.y, self.spd.y), maxspd.y)
  if self:colliding(map, self.pos) then
    error "Ooops, youre inside a wall"
  end
  self.pos:add(self.spd*dt)
  if self:colliding(map, self.pos) then
    local horizontal  = -vec2:new{self.spd.x*dt,0}
    local vertical    = -vec2:new{0,self.spd.y*dt}
    local hor_check   = self:colliding(map, self.pos+horizontal)
    local ver_check   = self:colliding(map, self.pos+vertical)
    if not (hor_check and not ver_check) then
      self.pos.x = self.pos.x - self.spd.x*dt
    end
    if (hor_check and not ver_check) or
       (hor_check and ver_check) then
      self.pos.y = self.pos.y - self.spd.y*dt
      if self.spd.y > 0 then
        self.jumpsleft = 2
      end
      self.spd.y = 0
    end
  end
  self.spd:add(gravity * dt)
end

function avatar:update_animation (dt)
  self.frame.i = dir_map[self.direction] + (self.attacking and 4 or 0)
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

function avatar:update_hitbox (dt)
  self.hitbox.owner = self
  self.hitbox.pos   = self.pos - self.hitbox.size/2
  self.hitbox:register()
end

function avatar:animate_movement (dt)
  self.frametime = self.frametime + dt
  while self.frametime >= 1/self.sprite.animfps do
    self.frame.j = self.frame.j % (#self.sprite.quads[self.frame.i]) + 1
    if self.frame.j == 1 then self.frame.j = 2 end
    self.frametime = self.frametime - 1/self.sprite.animfps
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
end

function avatar:get_atkhitboxpos ()
  return self.pos+vec2:new{(self.direction=='right' and 0.75 or -1.75), -.5}
end

function avatar:get_atkpos ()
  local tilesize = map.get_tilesize()
  return
    self.pos +
    vec2:new{
      (self.direction=='right' and 1 or -1),
      -4/tilesize
    }
end

function avatar:update (dt, map)
  self:update_physics(dt, map)
  self:update_animation(dt)
  self:update_hitbox(dt)
  if self.atkhitbox then
    self.atkhitbox.pos = self:get_atkhitboxpos()
  end
  for _, task in pairs(self.tasks) do
    task(self, dt)
  end
end

function avatar:jump ()
  if self.jumpsleft > 0 then
    self.jumpsleft = self.jumpsleft - 1
    self.spd.y = jumpspd
  end
end

function avatar:attack ()
  if not self.attacking then
    self.attacking = true
    self.frametime = 0
    self.frame.j = 1
    self.atkhitbox.pos = self:get_atkhitboxpos(),
    self.atkhitbox:register 'playeratk'
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

function avatar:accelerate (dv)
  self.spd:add(dv)
  if self.spd.x > 0 then
    self.direction = 'right'
  elseif self.spd.x < 0 then
    self.direction = 'left'
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
