
module ('mapgenerator', package.seeall)

require "map"

local tileset
function get_tileset()
  tileset = tileset or {
    [" "] = { img = nil, floor = false },
    ["I"] = { 
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
        return { type = 'I' }
      else
        return { type = ' ' }
      end
    end
  }
end

local empty_block = { '    ', '    ', '    ', '    ', rarity = 0.5 }

local function generate_blocks_grid(num_blocks_x, num_blocks_y, blocks)
  local blocks_grid = {
    blocks = blocks,
    num_x = num_blocks_x,
    num_y = num_blocks_y
  }
  for j=1,num_blocks_y do
    blocks_grid[j] = {}
    for i=1,num_blocks_x do
      if j <= num_blocks_y/2 then
        blocks_grid[j][i] = empty_block
      else
        rarity = math.random() * blocks.total_rarity
        for _, block in ipairs(blocks) do
          if rarity < block.rarity then
            blocks_grid[j][i] = block
            break
          else
            rarity = rarity - block.rarity
          end
        end
      end
    end
  end
  return blocks_grid
end

local function generate_cave_from_grid(grid)
  local thecave = map:new {
    tileset = grid.blocks.tileset,
    width   = grid.num_x * grid.blocks.width,
    height  = grid.num_y * grid.blocks.height,
    tilegenerator = function (aj, ai)
      local block_i, block_j = math.floor((ai-1) / grid.blocks.width) + 1, math.floor((aj-1) / grid.blocks.height) + 1
      local i, j = (ai-1) % grid.blocks.width + 1, (aj-1) % grid.blocks.height + 1
      return { type = grid[block_j][block_i][j]:sub(i,i) }
    end
  }
  return thecave
end

function random_map()
  local blocks = {
    width  = 4,
    height = 4,
    tileset = get_tileset(),
    total_rarity = 0,
    empty_block,
    { '    ', '  I ', '    ', '    ', rarity = 1 },
    { '    ', ' I  ', '    ', '    ', rarity = 1 },
    { '    ', '    ', 'IIII', 'IIII', rarity = 2 },
    { '    ', ' III', ' III', '    ', rarity = 2 },
  }
  for _, block in ipairs(blocks) do
    blocks.total_rarity = blocks.total_rarity + block.rarity
  end

  local blocks_grid = generate_blocks_grid(12, 8, blocks)
  return generate_cave_from_grid(blocks_grid)
end