
require 'lux.object'

animation = lux.object.new {
  fps     = 10,
  type    = 'loop'
  frames  = nil
}

animation.__init = {}
  frames = { {i=1, j=1} }
}

function animation:step_loop (last)
  return (last % #self.frames) + 1
end

function animation:step_once (last)
  return math.min(last + 1, #self.frames)
end

function animation:step (last)
  return self['step_'..self.type] (self, last)
end

