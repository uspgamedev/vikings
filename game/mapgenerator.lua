
module ('mapgenerator', package.seeall)

require "map"

local function pertile(table, fun)
  for j,row in ipairs(table) do
    for i,tile in ipairs(row) do
      fun(tile, j, i)
    end
  end 
end
local function matrix_get(table, j, i)
  return table[j] and table[j][i]
end
local function array_remove_if(array, fun)
  local result = {}
  for _,v in ipairs(array) do
    if not fun(v) then table.insert(result, v) end
  end
  return result
end
local function create_matrix(height, width, fun)
  local matrix = {}
  for j=1,height do
    matrix[j] = {}
    if fun then
      for i=1,width do
        matrix[j][i] = fun(j,i)
      end
    end
  end
  return matrix
end

local tileset
function get_tileset()
  tileset = tileset or {
    [" "] = { img = nil, floor = false },
    ["I"] = { 
      img = love.graphics.newImage 'data/tile/ice.png',
      floor = true
    }
  }
  return tileset
end

function default_map()
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
    fullmap = create_matrix(height, width, function(j, i)
      local nearby_walls = walls_nearby(grid, oldmap, j, i, 1, 2)
      local far_walls    = walls_nearby(grid, oldmap, j, i, 2, 2)
      return ((nearby_walls >= 7 or far_walls == 0) and 'I') or ' '
    end)
  end
  for iterations=1,2 do
    oldmap = fullmap
    fullmap = create_matrix(height, width, function(j, i)
      local nearby_walls = walls_nearby(grid, oldmap, j, i, 1, 2)
      return ((nearby_walls >= 8) and 'I') or ' '
    end)
  end

  -- Each tile needs to be a table for extra informations and ease of use
  -- Since in the grid a tile is just a char, we create a new table
  local advdata = create_matrix(height, width, function(j, i)
    return { j=j, i=i, type=fullmap[j][i] }
  end)

  -- Depth search function.
  -- All tiles you can reach from a tile belongs to the same group.
  local function depth_set_group(tile, newgroup)
    if not tile or tile.group == newgroup then return false end
    if tile.type ~= ' ' then return true  end
    assert(not tile.group, "If groups not the same then i has no group.")
    tile.group = newgroup
    newgroup.size = newgroup.size + 1
    local border
    border = depth_set_group(matrix_get(advdata, tile.j-1, tile.i), newgroup) or border
    border = depth_set_group(matrix_get(advdata, tile.j+1, tile.i), newgroup) or border
    border = depth_set_group(matrix_get(advdata, tile.j, tile.i-1), newgroup) or border
    border = depth_set_group(matrix_get(advdata, tile.j, tile.i+1), newgroup) or border
    if border then
      table.insert(newgroup.border, tile)
    end
    return false
  end
  
  local groups  = {}
  -- Find the groups
  pertile(advdata, function(tile)
    if tile.type == ' ' and not tile.group then
      local newgroup = { size = 0, border = {} }
      table.insert(groups, newgroup)
      depth_set_group(tile, newgroup)
    end
  end)

  -- Fill small groups
  local MINGROUP_SIZE = 20
  pertile(advdata, function(tile)
    if tile.group and tile.group.size < MINGROUP_SIZE then
      tile.type = 'I'
      tile.group.size = tile.group.size - 1
      tile.group = nil
    end
  end)
  groups = array_remove_if(groups, function(group) return group.size == 0 end)

  -- Ignore the biggest group
  local maxgroup = 1
  for id,group in ipairs(groups) do
    maxgroup = (group.size > groups[maxgroup].size) and id or maxgroup
  end
  table.remove(groups, maxgroup)

  local function find_nearest_from_other_group(tile)
    local group = tile.group
    local already_searched = { tile = true } 
    local queue = { tile }
    repeat
      local t = table.remove(queue, 1)
      for _,v in ipairs{{j=t.j-1, i=t.i},{j=t.j+1, i=t.i},{j=t.j, i=t.i-1},{j=t.j, i=t.i+1}} do
        if v.j >= 1 and v.j <= height and v.i >= 1 and v.i <= width then
          local target = advdata[v.j][v.i]
          -- found a tile from another group
          if target.group and target.group ~= group then
            return target
          end
          if not already_searched[target] then
            table.insert(queue, target)
            already_searched[target] = true
          end
        end
      end
    until #queue == 0
    error "Queue is empty?!"
  end
  local function find_shortest_path(tiles)
    local shortest
    for _,tile in ipairs(tiles) do
      local other = find_nearest_from_other_group(tile)
      local dist = math.abs(other.j - tile.j) + math.abs(other.i - tile.i)
      if not shortest then
        shortest = { this = tile, that = other, dist = dist }
      else
        shortest = (shortest.dist <= dist) and shortest or { this = tile, that = other, dist = dist }
      end
    end
    return shortest
  end

  while #groups > 0 do
    local group = table.remove(groups)
    local shortest = find_shortest_path(group.border)
    for j = math.min(shortest.this.j, shortest.that.j)-1, math.max(shortest.this.j, shortest.that.j) +1 do
      for i = math.min(shortest.this.i, shortest.that.i)-1, math.max(shortest.this.i, shortest.that.i) +1 do
        local tile = advdata[j][i]
        if tile and not tile.group and tile.type == 'I' then
          tile.type = ' '
          tile.group = group
          group.size = group.size + 1
        end
      end
    end
    -- Move all elements from this group to the group we just connected to
    pertile(advdata, function(tile, j, i)
      if tile.group == group then
        tile.group = shortest.that.group
        shortest.that.group.size = shortest.that.group.size + 1
      end
    end)
  end

  -- Check if all tiles either has a group or is a wall. And update the main grid with changes
  pertile(advdata, function(tile, j, i)
    assert(tile.group or tile.type ~= ' ')
    fullmap[j][i] = tile.type
  end)

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