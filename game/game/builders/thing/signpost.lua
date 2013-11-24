
require 'game.builder'
require 'things.thing'
require 'game.vec2'

return function(pos)
  local sign = thing:new {
    pos       = pos,
    sprite    = builder.sprite 'signpost',
    name      = "Signpost",
  }
  return sign
end