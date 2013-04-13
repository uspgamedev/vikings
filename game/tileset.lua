
require 'lux.object'
require 'tiletype'
require 'dump'

tileset = lux.object.new {
  name  = "unnamed",

  types = nil
}

function tileset:__init ()
  self.types = self.types or {}
  self.types[' '] = self.types[' '] or tiletype:new{ imgpath = nil }

  for k,v in pairs(self.types) do
    self.types[k].name = k
  end
end

function tileset:type(t)
  return self.types[t] or self.types[' ']
end

function tileset:__dumpfunction(ident)
  return "tileset:new {\n" 
          .. ident .. '  name = [[' .. self.name .. "]],\n" 
          .. ident .. '  types = ' .. dump(self.types, ident .. '  ') .. "\n"
          .. ident .. "}"
end