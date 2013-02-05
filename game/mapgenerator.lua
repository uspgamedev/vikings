
module ('mapgenerator', package.seeall)

require "map"

local tileset
function get_tileset()
  tileset = tileset or {
    empty = { img = nil, floor = false },
    ice   = { 
      img = love.graphics.newImage 'tile/ice.png',
      floor = true
    }
  }
  return tileset
end

function default_map()
  local img = love.graphics.newImage 'tile/ice.png'
  return map:new {
    width   = 25,
    height  = 18,
    tileset = get_tileset(),
    tilegenerator = function (j, i)
      if (j == 10) or (i == 14 and j == 9) then
        return { type = 'ice' }
      else
        return { type = 'empty' }
      end
    end
  }
end

local empty_block = { 
{'empty', 'empty', 'empty', 'empty'},
{'empty', 'empty', 'empty', 'empty'},
{'empty', 'empty', 'empty', 'empty'},
{'empty', 'empty', 'empty', 'empty'}, }

local function generate_blocks_grid(num_blocks_x, num_blocks_y, blocks)
  local blocks_grid = {}
  for j=1,num_blocks_y do
    blocks_grid[j] = {}
    for i=1,num_blocks_x do
      blocks_grid[j][i] = (j <= num_blocks_y/2 and empty_block) or blocks[1]
    end
  end
  return blocks_grid
end

function random_map()
  local blocks = {
    width  = 4,
    height = 4,
    { {'empty', 'empty', 'empty', 'empty'},
      {'empty',   'ice',   'ice', 'empty'},
      {'empty',   'ice',   'ice', 'empty'},
      {'empty', 'empty', 'empty', 'empty'}, }
  }

  local num_blocks_x = 8
  local num_blocks_y = 6

  local blocks_grid = generate_blocks_grid(num_blocks_x, num_blocks_y, blocks)

  return map:new {
    width   = num_blocks_x * blocks.width,
    height  = num_blocks_y * blocks.height,
    tileset = get_tileset(),
    tilegenerator = function (aj, ai)
      local block_i, block_j = math.floor((ai-1) / blocks.width) + 1, math.floor((aj-1) / blocks.height) + 1
      i, j = (ai-1) % blocks.width + 1, (aj-1) % blocks.height + 1
      print(block_i, block_j, j, i)
      return { type = blocks_grid[block_j][block_i][j][i] }
    end
  }
end