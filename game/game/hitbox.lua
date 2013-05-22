
require 'lux.object'
require 'map.map'

hitbox = lux.object.new {
  pos         = nil,  -- vec2
  size        = nil,  -- vec2
  targetclass = ''
}

hitbox.__init = {
  pos   = vec2:new {0,0},
  size  = vec2:new {1,1}
}

local classes = {}

function hitbox:top ()
  return self.pos.y
end

function hitbox:bottom ()
  return self.pos.y + self.size.y
end

function hitbox:left ()
  return self.pos.x
end

function hitbox:right ()
  return self.pos.x + self.size.x
end

function hitbox:update(owner, dt)
  self.owner = owner
  if owner then
    self.pos   = owner.pos - self.size/2
    self:register()
  end
end

function hitbox:colliding (another)
  if self:top() > another:bottom() then
    return false
  elseif self:bottom() < another:top() then
    return false
  elseif self:left() > another:right() then
    return false
  elseif self:right() < another:left() then
    return false
  end
  return true
end

function hitbox:register (class)
  class = class or self.class
  classes[class] = classes[class] or {}
  classes[class][self] = true
end

function hitbox:unregister (class)
  if self then
    if class then
      classes[class][self] = nil
    else
      for _,possibleclass in pairs(classes) do
        possibleclass[self] = nil
      end
    end
  else
    for _,class in pairs(classes) do
      for hitbox,check in pairs(class) do
        hitbox:unregister()
      end
    end
  end
end

function hitbox:get_collisions (target)
  targetclass = classes[target or self.targetclass]
  if not targetclass then return end
  local collisions = {}
  for another,check in pairs(targetclass) do
    if check and self:colliding(another) then
      table.insert(collisions, another)
    end
  end
  return collisions
end

local function draw (graphics, box)
  local tilesize = graphics.get_tilesize()
  graphics.setColor(0, 0, 200, 50)
  graphics.rectangle(
    'fill',
    tilesize*(box.pos.x-1),
    tilesize*(box.pos.y-1),
    (tilesize*box.size):get()
  )
  graphics.setColor(255, 255, 255, 255)
end

function hitbox.check_collisions ()
  for _,class in pairs(classes) do
    for box,check in pairs(class) do
      if check then
        local collisions = box:get_collisions()
        if collisions and box.on_collision then
          box:on_collision(collisions)
        end
      end
    end
  end
end

function hitbox.draw_all (graphics)
  for _,class in pairs(classes) do
    for box,check in pairs(class) do
      if check then
        draw(graphics, box)
      end
    end
  end
end
