
require 'game.builder'
require 'things.thing'
require 'game.vec2'

return function(pos)
  local door = thing:new {
    pos       = pos,
    sprite    = builder.sprite 'door',
    direction = 'left',
    name      = "Door",
  }
  door.hitboxes.helpful.class = 'door'
  door.hitboxes.helpful.size = vec2:new{1,2}
  return door
end