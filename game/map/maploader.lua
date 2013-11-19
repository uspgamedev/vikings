
module ('maploader', package.seeall)

require 'map.generator.map'

function create_things (newmap, debug)
  local things = {}
  for name, t in pairs(newmap.things) do
    things[name] = builder.thing(t.type, vec2:new(t.position), t.data)
  end
  return things
end

function load (map_file, debug)
  return map_file and mapgenerator.from_file(map_file) or mapgenerator.random_map(debug)
end


