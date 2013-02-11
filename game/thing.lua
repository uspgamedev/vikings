
require 'lux.object'
require 'vec2'
require 'hitbox'

thing = lux.object.new {
  pos       = nil,
  spd       = nil,
  accel     = nil,
  sprite    = nil,
  hitbox    = nil,
  air       = 0,

  direction = 'right',
}

thing.__init = {
  pos       = vec2:new{ 0, 0 },
  spd       = vec2:new{ 0, 0 },
  accel     = vec2:new{ 0, 0 },
  tasks     = {},
  drawtasks = {},
  hitboxes  = {
    helpful = hitbox:new {
      size  = vec2:new { 1, 1 },
      class = 'thing'
    },
  }
}

local GRAVITY           = vec2:new{  0,  30 }
local MAXSPD            = vec2:new{ 38,  30 }
local MIN_AIRTIME       = 0.1
local SPD_THRESHOLD     = 1.5
local DYNAMIC_FRICTION  = 1.0
local STATIC_FRICTION   = 3.0

function thing:die ()
  for _,hitbox in pairs(self.hitboxes) do
    hitbox:unregister()
  end
end

local function pos_to_tile (map, point)
  return map:get_tile(math.floor(point.y), math.floor(point.x))
end

function thing:colliding(map, position)
  local tilesize = map.get_tilesize()
  for _,p in ipairs(self.sprite.data.collpts) do
    local tile = pos_to_tile(map, position-(self.sprite.data.hotspot-p)/tilesize)
    if not tile or tile.floor then
      return true
    end
  end
  return false
end

local function sign_to_dir (sign)
  return sign >= 0 and 'right' or 'left'
end

function thing:apply_gravity (dt)
    self.spd:add(GRAVITY * dt)
end

function thing:update_physics (dt, map)
  -- no, negative speed doesn't increase forever
  self.spd.x = math.min(math.max(-MAXSPD.x, self.spd.x), MAXSPD.x)
  self.spd.y = math.min(math.max(-MAXSPD.y, self.spd.y), MAXSPD.y)
  if self:colliding(map, self.pos) then
    --error "Ooops, youre inside a wall"
    return
  end
  -- Apply speed.
  self.pos:add(self.spd*dt)
  -- Check and handle collision.
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
        if self.air > MIN_AIRTIME then
          sound.effect 'land'
        end
        self.air = 0
      end
      self.spd.y = 0
    end
  end
  -- Apply acceleration.
  self.spd:add(self.accel*dt)
  -- Regulate acceleration.
  if not self.accelerated or sign_to_dir(self.spd.x) ~= self.direction then
    self.accel:set(-STATIC_FRICTION*self.spd.x, 0)
    -- Stop moving if too slow.
    if math.abs(self.spd.x) < SPD_THRESHOLD  then
      self.spd.x = 0
    end
  else
    self.accel:set(-DYNAMIC_FRICTION*self.spd.x, 0)
    self.accelerated = false
  end
  -- Check airborne status.
  if self.spd.y ~= 0 then
    self.air = self.air + dt
  end
  -- (Re)apply gravity.
  self:apply_gravity(dt)
end

function thing:update_sprite (dt)
  self.sprite:set_mirror(self.direction == 'right', false)
  self.sprite:update(self, dt)
end

function thing:update_hitbox (dt)
  for _,hitbox in pairs(self.hitboxes) do
    hitbox:update(self, dt)
  end
end

function thing:update (dt, map)
  self:update_sprite(dt)
  self:update_physics(dt, map)
  self:update_hitbox(dt)
  for _, task in pairs(self.tasks) do
    task(self, dt)
  end
end

function thing:accelerate (dv)
  self.accel:add(dv)
  self.accelerated = true
  self.direction = sign_to_dir(dv.x)
end

function thing:shove (dv)
  self.spd:add(dv)
end

function thing:draw (graphics)
  self.sprite:draw(graphics, self.pos)
  for _, task in pairs(self.drawtasks) do
    task(self, graphics)
  end
end
