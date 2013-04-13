
require 'lux.object'

tile = lux.object.new {
  type   = nil,
}

function tile:floor(map)
  return map.tileset[self.type].floor
end

function tile:img(map)
  return map.tileset[self.type].img
end