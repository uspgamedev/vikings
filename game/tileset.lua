
require 'lux.object'

tileset = lux.object.new {
  name  = "unnamed",

  types = nil
}

function tileset:__init ()
  self.types = self.types or {}
  self.types[' '] = self.types[' '] or { img = nil, floor = false }

  for k,v in pairs(self.types) do
    self.types[k].name = k
  end
end

function tileset:type(t)
  return self.types[t] or self.types[' ']
end