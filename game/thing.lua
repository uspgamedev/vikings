
require 'lux.object'
require 'vec2'
require 'hitbox'

thing = lux.object.new {
  pos       = nil,
  spd       = nil,
  sprite    = nil,
  frame     = nil,
  hitbox    = nil,

  direction = 'right',
}

thing.__init = {
  pos       = vec2:new{ 0, 0 },
  spd       = vec2:new{ 0, 0 },
  frame     = { i=1, j=1 },
  tasks     = {},
  drawtasks = {},
  hitbox    = hitbox:new {
    size  = vec2:new { 1, 1 },
    class = 'thing'
  },

  frametime = 0
}

local gravity   = vec2:new{  0,  30 }
local maxspd    = vec2:new{ 30,  30 }

function thing:die ()
  self.hitbox:unregister()
end

local function pos_to_tile (map, point)
  return map:get_tile(math.floor(point.y), math.floor(point.x))
end

function thing:colliding(map, position)
  for _,p in ipairs(self.sprite.collpts) do
    local tile = pos_to_tile(map, position-(self.sprite.hotspot-p)/32)
    if not tile or tile.floor then
      return true
    end
  end
  return false
end

function thing:update_physics (dt, map)
  -- no, negative speed doesn't increase forever
  self.spd.x = math.min(math.max(-maxspd.x, self.spd.x), maxspd.x)
  self.spd.y = math.min(math.max(-maxspd.y, self.spd.y), maxspd.y)
  if self:colliding(map, self.pos) then
    --error "Ooops, youre inside a wall"
    return
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
        if self.jumpsleft and self.jumpsleft < 2 then
          sound.effect 'land'
        end
        self.jumpsleft = 2
      end
      self.spd.y = 0
    end
  end
  self.spd:add(gravity * dt)
end

function thing:update_animation (dt)
  self.frame.i = self.sprite:frame_from_direction(self.direction)
  local moving = self.spd.x ~= 0
  if not moving then
    self.frame.j = 1
    return
  end
  self:animate_movement(dt)
end

function thing:update_hitbox (dt)
  self.hitbox.owner = self
  self.hitbox.pos   = self.pos - self.hitbox.size/2
  self.hitbox:register()
end

function thing:update (dt, map)
  self:update_physics(dt, map)
  self:update_animation(dt)
  self:update_hitbox(dt)
  for _, task in pairs(self.tasks) do
    task(self, dt)
  end
end

function thing:accelerate (dv)
  self.spd:add(dv)
  if self.spd.x > 0 then
    self.direction = 'right'
  elseif self.spd.x < 0 then
    self.direction = 'left'
  end
end

function thing:animate_movement (dt)
  self.frametime = self.frametime + dt
  while self.frametime >= 1/self.sprite.animfps do
    self.frame.j = self.frame.j % (#self.sprite.quads[self.frame.i]) + 1
    if self.frame.j == 1 then self.frame.j = 2 end
    self.frametime = self.frametime - 1/self.sprite.animfps
  end
end

function thing:draw (graphics)
  self.sprite:draw(graphics, self.frame, self.pos)
  for _, task in pairs(self.drawtasks) do
    task(self, graphics)
  end
end
