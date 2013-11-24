
require 'game.builder'
require 'things.thing'
require 'game.vec2'
require 'network.node'

return function(pos)
  local sign = thing:new {
    pos       = pos,
    sprite    = builder.sprite 'signpost',
    name      = "Signpost",
  }
  sign.hitboxes.helpful.class = 'interactable'
  sign.hitboxes.helpful.size = vec2:new{1,2}

  function sign:interact(player)
    local server = network.node.server
    for _, node in pairs(network.node.db.known_nodes) do
      if server.node.uuid ~= node.uuid and node.services.vikings then
        print(server:send_message(node.uuid, 
                                  etherclan.commands.service,
                                  "VIKINGS",
                                  "HAS_JOINABLE_GAME",
                                  true))
      end
    end
  end
  return sign
end