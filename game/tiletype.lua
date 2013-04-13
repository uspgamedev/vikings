
require 'lux.object'

tiletype = lux.object.new {
  floor = false,
  imgpath = nil, -- string

  _img = nil
}

function tiletype:__init ()
  self._img = self.imgpath and love.graphics.newImage(self.imgpath)
end

function tiletype:img()
  return self._img
end

function tiletype:__dumpfunction(ident)
  local strpath = self.imgpath and "[["..self.imgpath.."]]" or "nil"
  return 'tiletype:new { floor = ' .. tostring(self.floor) .. ', imgpath = ' .. strpath .. ' }'
end