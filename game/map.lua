
module ('map', package.seeall)

local width, height = 25, 18
local tilesize      = 32
local tiles         = {}
local tileset       = {}

function load (graphics)
  local img = love.graphics.newImage 'tile/ice.png'
  tileset.empty = { img = nil, floor = false }
  tileset.ice   = { img = img, floor = true }
  for i=1,height do
    tiles[i] = {}
    for j=1,width do
      tiles[i][j] = {}
    end
  end
  for j=1,width do
    set_tile(10, j, 'ice')
  end
end

function get_tilesize ()
  return tilesize
end

function get_tile (i, j)
  return tiles[i] and tiles[i][j]
end

function set_tile (i, j, typeid)
  local tile = get_tile(i,j)
  local type = tileset[typeid] or tileset.empty
  if tile then
    tile.img    = type.img
    tile.floor  = type.floor
  end
end

function draw (graphics)
  graphics.rectangle('line', 0, 0, width*tilesize, height*tilesize)
  for y,row in ipairs(tiles) do
    for x,tile in ipairs(row) do
      if tile.img then
        graphics.draw(tile.img, tilesize*(x-1), tilesize*(y-1))
      end
    end
  end
end
