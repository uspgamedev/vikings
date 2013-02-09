
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
  return blocks_grid
end

local function generate_cave_from_grid(grid)
  local width, height = grid.num_x * grid.blocks.width, grid.num_y * grid.blocks.height
  
  local fullmap = {}
  --[[for j=1,height do
    fullmap[j] = {}
    for i=1,width do
      fullmap[j][i] = math.random() < 0.45 and 'I' or ' '
    end
  end]]
  for block_j = 1,grid.num_y do
    for internal_j = 1,grid.blocks.height do
      fullmap[(block_j-1) * grid.blocks.height + internal_j] = {}
      for block_i = 1,grid.num_x do
        for internal_i = 1,grid.blocks.width do
          fullmap[(block_j-1) * grid.blocks.height + internal_j]
                 [(block_i-1) * grid.blocks.width  + internal_i] =
                    grid[block_j][block_i][internal_j]:sub(internal_i, internal_i)
        end
      end
    end
  end

  local function walls_nearby( grid, map, j, i, range_j, range_i )
    local width, height = grid.num_x * grid.blocks.width, grid.num_y * grid.blocks.height
    local missing_j = math.max(range_j - j + 1, range_j - height + j, 0)
    local missing_i = math.max(range_i - i + 1, range_i - width  + i, 0)
    local count_walls = (missing_i + 1) * (missing_j + 1) - 1
    for int_j = math.max(j-range_j, 1), math.min(j+range_j, height) do
      for int_i = math.max(i-range_i, 1), math.min(i+range_i, width) do
        count_walls = count_walls + (grid.blocks.tileset[map[int_j][int_i]].floor and 1 or 0)
      end
    end
    return count_walls
  end

  local oldmap
  for iterations=1,3 do
    oldmap = fullmap
    fullmap = {}
    for j=1,height do
      fullmap[j] = {}
      for i=1,width do
        nearby_walls = walls_nearby(grid, oldmap, j, i, 1, 2)
        far_walls    = walls_nearby(grid, oldmap, j, i, 2, 2)
        fullmap[j][i] = ((nearby_walls >= 7 or far_walls == 0) and 'I') or ' '
      end
    end
  end
  for iterations=1,2 do
    oldmap = fullmap
    fullmap = {}
    for j=1,height do
      fullmap[j] = {}
      for i=1,width do
        nearby_walls = walls_nearby(grid, oldmap, j, i, 1, 2)
        fullmap[j][i] = ((nearby_walls >= 8) and 'I') or ' '
      end
    end
  end

  for i,v in ipairs(fullmap) do
    print(i, table.concat(v))
  end

  local thecave = map:new {
    tileset = grid.blocks.tileset,
    width   = grid.num_x * grid.blocks.width,
    height  = grid.num_y * grid.blocks.height,
    tilegenerator = function (aj,ai) 
      return { type = fullmap[aj][ai] }
    end
    --[[function (aj, ai)
      local block_i, block_j = math.floor((ai-1) / grid.blocks.width) + 1, math.floor((aj-1) / grid.blocks.height) + 1
      local i, j = (ai-1) % grid.blocks.width + 1, (aj-1) % grid.blocks.height + 1
      return { type = grid[block_j][block_i][j]:sub(i,i) }
    end]]
  }
  return thecave
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

  local blocks_grid = generate_blocks_grid(18, 8, blocks)
  return generate_cave_from_grid(blocks_grid)
end