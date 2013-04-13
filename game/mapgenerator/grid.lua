
module ('mapgenerator', package.seeall) do

  local empty_block = { '    ', '    ', '    ', '    ', rarity = 0.5 }

  function load_grid_from_file(tileset, path)
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

  function random_grid_from_blocks(num_blocks_x, num_blocks_y, blocks)
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

  function random_grid_with_chance(tileset, width, height, chance)
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

end