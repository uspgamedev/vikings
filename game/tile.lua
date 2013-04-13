
require 'lux.object'

tile = lux.object.new {
  type   = nil,
}

function tile:floor(map)
  return map.tileset:type(self.type).floor
end

function tile:img(map)
  return map.tileset:type(self.type).img
end