
require 'thing'
require 'vec2'
require 'hitbox'

collectable = thing:new {}

function collectable:__init ()
  self.hitbox.class = 'collectable'
end
