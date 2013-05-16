
module ('mapgenerator', package.seeall) do

  require 'map.tileset'
  require 'map.tiletype'
  require 'map.map'
  require 'map.generator.grid'
  require 'map.generator.procedural.cave'

  local tilesets = {}
  function get_tileset()
    if not tilesets.default then
      tilesets.default = tileset:new {
        types = {
          ["I"] = tiletype:new { 
            imgpath = 'data/tile/ice.png',
            floor = true
          }
        }
      }
    end
    return tilesets.default
  end

  local function generate_map_with_grid(grid)
    return map:new {
      tileset = grid.tileset,
      width   = grid.width,
      height  = grid.height,
      tiles   = grid
    }
  end

  local function find_grounded_open_spots(map)
    local spots = {}
    for j=1,map.height-2 do
      for i=1,map.width-1 do
        if not map:get_tile_floor(j  ,i) and not map:get_tile_floor(j  ,i+1) and
           not map:get_tile_floor(j+1,i) and not map:get_tile_floor(j+1,i+1) and
               map:get_tile_floor(j+2,i) and     map:get_tile_floor(j+2,i+1) then
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
    return {result.i+1, result.j+1}
  end

  function random_map(debug)
    local blocks = {
      width  = 4,
      height = 4,
      tileset = get_tileset(),
      total_rarity = 0,
      { '    ', '  I ', '    ', '    ', rarity = 1 },
      { '    ', ' I  ', '    ', '    ', rarity = 1 },
      { '    ', '    ', 'IIII', 'IIII', rarity = 2 },
      { '    ', ' III', ' III', '    ', rarity = 2 },
    }
    for _, block in ipairs(blocks) do
      blocks.total_rarity = blocks.total_rarity + block.rarity
    end
    local blocks_grid = random_grid_from_blocks(26, 18, blocks)
    local cavegrid = mapgenerator.generate_cave_from_grid(blocks_grid)
    local m = generate_map_with_grid(cavegrid)

    local valid_spots = find_grounded_open_spots(m)
    m.locations.playerstart = get_random_position(valid_spots, debug)
    table.insert(m.things, { type = "door",       position = get_random_position(valid_spots, debug) })
    table.insert(m.things, { type = "npc_cain",   position = get_random_position(valid_spots, debug) })
    table.insert(m.things, { type = "vendor",     position = get_random_position(valid_spots, debug) })
    for i=1,(debug and 1 or 10) do
      table.insert(m.things, { type = "drillbeast", position = get_random_position(valid_spots, debug) })
    end
    for i=1,5 do
      table.insert(m.things, { type = "ironaxe",      position = get_random_position(valid_spots, debug) })
      table.insert(m.things, { type = "leatherarmor", position = get_random_position(valid_spots, debug) })
    end
    return m
  end

  -- A map file is a lua script that should return a table that will be used to construct a map object.
  -- This lua script is allowed to construct tilesets and tiletypes, and nothing more.
  function from_file(path)
    local ok, chunk = pcall(love.filesystem.load, path)
    if not ok then 
      print(chunk)
      return nil, chunk
    end
    setfenv(chunk, { tileset = tileset, tiletype = tiletype })
    local ok, result = pcall(chunk)
    if not ok then 
      print(result)
      return nil, result
    end
    return map:new(result)
  end

end