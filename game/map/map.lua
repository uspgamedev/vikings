
require 'lux.object'

require 'map.tile'
require 'dump'

map = lux.object.new {
  width   = 0,
  height  = 0,

  tileset = nil,
  locations = nil,
  things = nil,
}

function map.get_tilesize ()
  return 32
end

function map:__init ()
  self.locations = self.locations or {}
  self.things = self.thing or {}
  local input_tiles = self.tiles
  self.tiles = {}
  for j=1,self.height do
    self.tiles[j] = {}
    for i=1,self.width do
      self.tiles[j][i] = tile:new {
        i = i,
        j = j,
      }
      local input = input_tiles[j][i]
      if type(input) == 'table' then
        for k,v in pairs(input) do
          self.tiles[j][i][k] = v
        end
      else
        self.tiles[j][i].type = input
      end
      self.tiles[j][i].type = self.tileset:type(self.tiles[j][i].type).name
    end
  end
  --print(dump(self))
end

function map:get_tile (i, j)
  return self.tiles[i] and self.tiles[i][j]
end

function map:get_tile_floor (i, j)
  local tile = self:get_tile(i, j)
  return tile and tile:floor(self)
end

function map:get_tile_img (i, j)
  local tile = self:get_tile(i, j)
  return tile and tile:img(self)
end

function map:set_tile (i, j, typeid)
  local tile = self:get_tile(i,j)
  if tile then
    tile.type = self.tileset[typeid] and typeid or ' '
  end
end

function map:draw (graphics, pos, w, h)
  local tilesize = graphics.get_tilesize()
  graphics.rectangle('line', 0, 0, self.width*tilesize, self.height*tilesize)
  local start_y, start_x = 1, 1
  local end_y, end_x = #self.tiles, #self.tiles[1]
  if pos then
    local num_width = (w / tilesize) * 0.5 + 1
    local num_height = (h / tilesize) * 0.5 + 1
    start_y = math.max(start_y, math.floor(pos.y - num_width))
    start_x = math.max(start_x, math.floor(pos.x - num_width))
    end_y = math.min(end_y, math.floor(pos.y + num_width))
    end_x = math.min(end_x, math.floor(pos.x + num_width))
  end
  for y = start_y, end_y do
    for x = start_x, end_x do
      local img = self:get_tile_img(y,x)
      if img then
        graphics.draw(img, tilesize*(x-1), tilesize*(y-1))
      end
    end
  end
end

function map:save_to_file(path)
  local file = love.filesystem.newFile(path)
  if not file:open("w") then return end
  local mapdump = lux.object.clone(self)
  mapdump.things = lux.object.clone(self.things)
  for _,row in ipairs(mapdump.tiles) do
    for _,tile in ipairs(row) do
      tile.i = nil
      tile.j = nil
      tile.map = nil
    end
  end
  file:write('return ' .. dump(mapdump))
  file:close()
end