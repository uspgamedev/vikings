
require 'game.builder'
require 'things.thing'
require 'game.vec2'
require 'network.node'
require 'map.generator.map'
require 'game.message'

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
        local response = server:send_message(node.uuid, 
                                  etherclan.commands.service,
                                  "VIKINGS",
                                  "HAS_JOINABLE_GAME",
                                  true)
        if response == 'YES' then
          local map_string = server:send_message(node.uuid, 
                                  etherclan.commands.service,
                                  "VIKINGS",
                                  "JOIN_GAME",
                                  true)
          local map = mapgenerator.from_string(map_string)
          local file = love.filesystem.newFile('tmp.lua')
          if not file:open("w") then return end
          file:write(map_string)
          file:close()
          if map then
            message.send [[game]] {'changemap', map}
          end
        end
      end
    end
  end
  return sign
end