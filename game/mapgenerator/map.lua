
module ('mapgenerator', package.seeall) do

  require 'tileset'
  require 'map'
  require 'mapgenerator.grid'
  require 'mapgenerator.procedural.cave'

  local tilesets = {}
  function get_tileset()
    if not tilesets.default then
      tilesets.default = tileset:new {
        types = {
          ["I"] = { 
            img = love.graphics.newImage 'data/tile/ice.png',
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
      tilegenerator = function (aj,ai) 
        return { type = grid[aj][ai] }
      end
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

  function from_file(path)
    local grid = load_grid_from_file(get_tileset(), path)
    if grid then
      return generate_map_with_grid(grid)
    end
  end

end