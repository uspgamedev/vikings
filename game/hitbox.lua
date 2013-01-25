
require 'lux.object'

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
  return pos.y
end

function hitbox:bottom ()
  return pos.y + size.y
end

function hitbox:left ()
  return pos.x
end

function hitbox:right ()
  return pos.x + size.x
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
  classes[class] = classes[class] or {}
  classes[class][self] = true
end

function hitbox:unregister (class)
  if class then
    classes[class][self] = nil
  else
    for _,possibleclass in pairs(classes) do
      classes[possibleclass][self] = nil
    end
  end
end

function hitbox:get_collisions ()
  targetclass = classes[self.targetclass]
  if not targetclass then return end
  local collisions = {}
  for another,check in pairs(targetclass) do
    if check and self:colliding(another) then
      table.insert(collisions, another)
    end
  end
  return collisions
end
