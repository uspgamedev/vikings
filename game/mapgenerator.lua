
module ('mapgenerator', package.seeall)

require "map"

function default_map()
  local img = love.graphics.newImage 'tile/ice.png'
  return map:new {
    width   = 25,
    height  = 18,
    tileset = {
      empty = { img = nil, floor = false },
      ice   = { img = img, floor = true }
    },
    tilegenerator = function (j, i)
      if (j == 10) or (i == 14 and j == 9) then
        return { type = 'ice' }
      else
        return { type = 'empty' }
      end
    end
  }
end

function random_map()
  return default_map()
end