
require 'lux.object'

map = lux.object.new {
  width   = 0,
  height  = 0,

  tileset = nil 
}

function map.get_tilesize ()
  return 32
end

function map:__init ()
  self.tiles = {}
  for j=1,self.height do
    self.tiles[j] = {}
    for i=1,self.width do
      local tile = self.tilegenerator(j, i)
      local type = self.tileset[tile.type] or self.tileset[' ']
      tile.i = i
      tile.j = j
      tile.img    = tile.img   or type.img
      tile.floor  = tile.floor or type.floor
      self.tiles[j][i] = tile
    end
  end
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
