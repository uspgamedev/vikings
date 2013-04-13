
require 'lux.object'

require 'tile'

map = lux.object.new {
  width   = 0,
  height  = 0,

  tileset = nil,
  locations = nil,
}

function map.get_tilesize ()
  return 32
end

local dumpdata = {}

local function dump (value, ident)
  ident = ident or ''
  local t = type(value)
  if dumpdata['type'..t] then
    return dumpdata['type'..t](value, ident)
  end
  return tostring(value)
end

function dumpdata.typestring (value)
  return "[["..value.."]]"
end
function dumpdata.typetable (value, ident)
  if value['__dumpfunction'] then
    return value['__dumpfunction'](value, ident)
  end
  local str = (value.__type or "").."{".."\n"
  for k,v in pairs(value) do
    if type(k) == 'string' then
      if k[1] ~= '_' then
        str = str..ident..'  '..'["'..k..'"] = '..dump(v, ident .. '  ')..",\n"
      end
    else
      str = str..ident..'  '.."["..k.."] = "..dump(v, ident .. '  ')..",\n"
    end
  end
  return str..ident.."}"
end
function dumpdata.typefunction (value)
  return '"*FUNCTION*"'
end

function map:__init ()
  self.locations = self.locations or {}
  self.tiles = {}
  for j=1,self.height do
    self.tiles[j] = {}
    for i=1,self.width do
      self.tiles[j][i] = tile:new {
        i = i,
        j = j,
      }
      for k,v in pairs(self.tilegenerator(j, i)) do
        self.tiles[j][i][k] = v
      end
      local type = self.tiles[j][i].type
      self.tiles[j][i].type = self.tileset[type] and type or ' '
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
  local tilesize = map.get_tilesize()
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
  for _,row in ipairs(mapdump.tiles) do
    for _,tile in ipairs(row) do
      tile.i = nil
      tile.j = nil
      tile.map = nil
    end
  end
  file:write(dump(mapdump))
  file:close()
end