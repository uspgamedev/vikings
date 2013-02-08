
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
  local blocks_grid = {
    blocks = blocks,
    num_x = num_blocks_x,
    num_y = num_blocks_y
  }
  for j=1,num_blocks_y do
    blocks_grid[j] = {}
    for i=1,num_blocks_x do
      blocks_grid[j][i] = (j <= num_blocks_y/2 and empty_block) or blocks[math.random(#blocks)]
    end
  end
  return blocks_grid
end

local function generate_map_from_grid(grid)
  return map:new {
    tileset = grid.blocks.tileset,
    width   = grid.num_x * grid.blocks.width,
    height  = grid.num_y * grid.blocks.height,
    tilegenerator = function (aj, ai)
      local block_i, block_j = math.floor((ai-1) / grid.blocks.width) + 1, math.floor((aj-1) / grid.blocks.height) + 1
      local i, j = (ai-1) % grid.blocks.width + 1, (aj-1) % grid.blocks.height + 1
      return { type = grid[block_j][block_i][j][i] }
    end
  }
end

function random_map()
  local blocks = {
    width  = 4,
    height = 4,
    tileset = get_tileset(),
    { {'empty', 'empty', 'empty', 'empty'},
      {'empty', 'empty',   'ice', 'empty'},
      {'empty', 'empty', 'empty', 'empty'},
      {'empty', 'empty', 'empty', 'empty'}, },
    { {'empty', 'empty', 'empty', 'empty'},
      {'empty',   'ice', 'empty', 'empty'},
      {'empty', 'empty', 'empty', 'empty'},
      {'empty', 'empty', 'empty', 'empty'}, },
    { {'empty', 'empty', 'empty', 'empty'},
      {'empty', 'empty', 'empty', 'empty'},
      {  'ice',   'ice',   'ice',   'ice'},
      {  'ice',   'ice',   'ice',   'ice'}, },
    { {'empty', 'empty', 'empty', 'empty'},
      {'empty',   'ice',   'ice',   'ice'},
      {'empty',   'ice',   'ice',   'ice'},
      {'empty', 'empty', 'empty', 'empty'}, },
  }

  local blocks_grid = generate_blocks_grid(12, 8, blocks)
  return generate_map_from_grid(blocks_grid)
end