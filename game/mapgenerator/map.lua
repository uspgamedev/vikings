
module ('mapgenerator', package.seeall) do

  require 'tileset'
  require 'tiletype'
  require 'map'
  require 'mapgenerator.grid'
  require 'mapgenerator.procedural.cave'

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

  function random_map()
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

    return generate_map_with_grid(cavegrid)
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