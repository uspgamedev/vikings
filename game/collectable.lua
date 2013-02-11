
require 'thing'
require 'vec2'
require 'hitbox'
require 'message'

collectable = thing:new {
  pick_delay = 0
}

function collectable:__init ()
  self.hitboxes.helpful.class = 'collectable'
  self.hitboxes.helpful.targetclass = 'avatar'
  function self.hitboxes.helpful:on_collision (collisions)
    local p = collisions[1] 
    if self.owner.pick_delay == 0 and p and p.owner and p.owner:equip(1, self.owner) then
      sound.effect 'pick'
      message.send [[game]] {'kill', self.owner}
    end
  end
end

function collectable:update(dt, map)
  collectable:__super().update(self, dt, map)
  self.pick_delay = math.max(self.pick_delay - dt, 0)
end