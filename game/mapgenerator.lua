
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

local function load_grid_from_file(tileset, path)
  if not love.filesystem.exists(path) then return end
  local data, size = love.filesystem.read(path)

  local function splt_lines(str)
    local t = {}
    local function helper(line) table.insert(t, line) return "" end
    helper((str:gsub("(.-)\r?\n", helper)))
    return t
  end
  local lines = splt_lines(data)
  if #lines == 0 then return end

  local grid = {
    tileset = tileset,
    width = #lines[1],
    height = #lines - 1
  }
  for j, line in ipairs(lines) do
    if j > grid.height then break end
    if #line ~= grid.width then error("Line " .. j .. " has incorret size. " .. #line .. " != " .. grid.width) end
    grid[j] = {}
    for i=1,grid.width do
      grid[j][i] = line:sub(i,i)
    end
  end
  return grid
end

local function random_grid_from_blocks(num_blocks_x, num_blocks_y, blocks)
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

  local grid = {
    tileset = blocks.tileset,
    width   = num_blocks_x * blocks.width,
    height  = num_blocks_y * blocks.height
  }
  for block_j = 1,num_blocks_y do
    for internal_j = 1,blocks.height do
      grid[(block_j-1) * blocks.height + internal_j] = {}
      for block_i = 1,num_blocks_x do
        for internal_i = 1,blocks.width do
          grid[(block_j-1) * blocks.height + internal_j]
                 [(block_i-1) * blocks.width  + internal_i] =
                    blocks_grid[block_j][block_i][internal_j]:sub(internal_i, internal_i)
        end
      end
    end
  end

  return grid
end

local function random_grid_with_chance(tileset, width, height, chance)
  chance = chance or 0.45
  local grid = {
    tileset = tileset,
    width = width,
    height = height
  }
  for j=1,height do
    grid[j] = {}
    for i=1,width do
      grid[j][i] = math.random() < chance and 'I' or ' '
    end
  end
  return grid
end

local function generate_cave_from_grid(grid)
  local width, height = grid.width, grid.height
  
  local function walls_nearby( grid, map, j, i, range_j, range_i )
    local width, height = grid.width, grid.height
    local missing_j = math.max(range_j - j + 1, range_j - height + j, 0)
    local missing_i = math.max(range_i - i + 1, range_i - width  + i, 0)
    local count_walls = (range_j*2 + 1) * (range_i*2 + 1)--(missing_i + 1) * (missing_j + 1) - 1
    for int_j = math.max(j-range_j, 1), math.min(j+range_j, height) do
      for int_i = math.max(i-range_i, 1), math.min(i+range_i, width) do
        count_walls = count_walls + (grid.tileset[map[int_j][int_i]].floor and 0 or -1)
      end
    end
    return count_walls
  end

  local fullmap, oldmap = grid
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

  fullmap.width   = grid.width
  fullmap.height  = grid.height
  fullmap.tileset = grid.tileset
  return fullmap
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

  local cavegrid = generate_cave_from_grid(blocks_grid)

  return generate_map_with_grid(cavegrid)
end

function from_file(path)
  local grid = load_grid_from_file(get_tileset(), path)
  if grid then
    return generate_map_with_grid(grid)
  end
end