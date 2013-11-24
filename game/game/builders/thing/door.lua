
require 'game.builder'
require 'things.thing'
require 'game.vec2'
require 'game.message'

return function(pos)
  local door = thing:new {
    pos       = pos,
    sprite    = builder.sprite 'door',
    direction = 'left',
    name      = "Door",
  }
  door.hitboxes.helpful.class = 'interactable'
  door.hitboxes.helpful.size = vec2:new{1,2}

  function door:interact(player)
    message.send [[game]] {'changemap'}
  end
  return door
end