
require 'thing'
require 'vec2'
require 'hitbox'

collectable = thing:new {}

function collectable:__init ()
  self.hitboxes.helpful.class = 'collectable'
end
