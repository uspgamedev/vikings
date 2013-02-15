
require 'thing'
require 'vec2'
require 'hitbox'
require 'message'

collectable = thing:new {
  pick_delay = 0,
  slot = 1
}

function collectable:__init ()
  self.hitboxes.helpful.class = 'collectable'
end

function collectable:update(dt, map)
  collectable:__super().update(self, dt, map)
  self.pick_delay = math.max(self.pick_delay - dt, 0)
end
