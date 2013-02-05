
require 'lux.object'

map = lux.object.new {
  width   = 25,
  height  = 18,

  tiles   = nil,
  tileset = nil
}

function map.get_tilesize ()
  return 32
end

function map:__init ()
  local img = love.graphics.newImage 'tile/ice.png'

  self.tileset = {
    empty = { img = nil, floor = false },
    ice   = { img = img, floor = true }
  }

  self.tiles = {}

  for i=1,self.height do
    self.tiles[i] = {}
    for j=1,self.width do
      self.tiles[i][j] = { i=i, j=j }
    end
  end
  for j=1,self.width do
    self:set_tile(10, j, 'ice')
  end
  self:set_tile(9, 14, 'ice')
end

function map:get_tile (i, j)
  return self.tiles[i] and self.tiles[i][j]
end

function map:set_tile (i, j, typeid)
  local tile = self:get_tile(i,j)
  local type = self.tileset[typeid] or self.tileset.empty
  if tile then
    tile.img    = type.img
    tile.floor  = type.floor
  end
end

function map:draw (graphics)
  local tilesize = map.get_tilesize()
  graphics.rectangle('line', 0, 0, self.width*tilesize, self.height*tilesize)
  for y,row in ipairs(self.tiles) do
    for x,tile in ipairs(row) do
      if tile.img then
        graphics.draw(tile.img, tilesize*(x-1), tilesize*(y-1))
      end
    end
  end
end
