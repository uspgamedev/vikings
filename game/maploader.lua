
module ('maploader', package.seeall)

require 'mapgenerator'
require 'builder'
require 'hitbox'

local function find_grounded_open_spots(map)
  local spots = {}
  for j=1,map.height-2 do
    for i=1,map.width-1 do
      if not map.tiles[j  ][i].floor and not map.tiles[j  ][i+1].floor and
         not map.tiles[j+1][i].floor and not map.tiles[j+1][i+1].floor and
             map.tiles[j+2][i].floor and     map.tiles[j+2][i+1].floor then
        table.insert(spots, {j=j,i=i})
      end
    end
  end
  return spots
end

local function get_random_position(spots, debug)
  local i = (debug and 1) or math.random(#spots)
  local result = spots[i]
  table.remove(spots, i)
  return vec2:new{result.i+1, result.j+1}
end

local function add_things (things, valid_spots, debug)
  table.insert(things, builder.build_thing("door",   get_random_position(valid_spots, debug)))
  table.insert(things, builder.build_thing("npc",    get_random_position(valid_spots, debug)))
  table.insert(things, builder.build_thing("vendor", get_random_position(valid_spots, debug)))
  if debug then
    table.insert(things, builder.build_thing("enemy", get_random_position(valid_spots, debug)))
    for i=1,3 do
      table.insert(things, builder.build_thing("item",  get_random_position(valid_spots, debug)))
      table.insert(things, builder.build_thing("armor", get_random_position(valid_spots, debug)))
    end
  else
    for i=1,10 do
      table.insert(things, builder.build_thing("enemy", get_random_position(valid_spots, debug)))
    end
    for i=1,5 do
      table.insert(things, builder.build_thing("item",  get_random_position(valid_spots, debug)))
      table.insert(things, builder.build_thing("armor", get_random_position(valid_spots, debug)))
    end
  end
end

function load (map_file, player, debug)
  local newmap      = map_file and mapgenerator.from_file(map_file) or mapgenerator.random_map()
  local valid_spots = find_grounded_open_spots(newmap)
  local things      = {}

  things.player = player
  player.pos    = get_random_position(valid_spots, debug)
  add_things(things, valid_spots, debug)
  hitbox.unregister()

  return newmap, things
end


