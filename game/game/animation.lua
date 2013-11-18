
require 'lux.object'

animation = lux.object.new {
  fps       = 10,
  type      = 'loop',
  frames    = nil
}

animation.__init = {
  frames = { {i=1, j=1} }
}

function animation:step_loop (last)
  return (last % #self.frames) + 1
end

function animation:step_once (last)
  return math.min(last + 1, #self.frames)
end

function animation:step (last, observer)
  local next = self['step_'..self.type] (self, last)
  if observer and self.frames[next].event then
    self.frames[next].event(observer)
  end
  if last == #self.frames and observer and self.finishevent then
    self.finishevent(observer)
  end
  return next
end

