
module ('maploader', package.seeall)

require 'map.generator.map'

local function create_things (newmap, debug)
  local things = {}
  for name, t in pairs(newmap.things) do
    things[name] = builder.build_thing(t.type, vec2:new(t.position), t.data)
  end
  return things
end

function load (map_file, player, debug)
  local newmap      = map_file and mapgenerator.from_file(map_file) or mapgenerator.random_map(debug)
  local things      = create_things(newmap, debug)

  things.player = player
  player.pos    = vec2:new(newmap.locations.playerstart)

  return newmap, things
end


