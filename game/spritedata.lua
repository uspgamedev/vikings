
require 'lux.object'
require 'map'

spritedata = lux.object.new {
  img           = nil,
  maxframe      = nil,
  quadsize      = nil, -- must be a number
  hotspot       = nil,
  collpts       = nil,
}

function spritedata:__init ()
  self.quads = {}
  for i=1, self.maxframe.i do
    self.quads[i] = {}
    for j=1, self.maxframe.j do
      self.quads[i][j] = love.graphics.newQuad(
        self.quadsize*(j-1),
        self.quadsize*(i-1),
        self.quadsize, self.quadsize, self.img:getWidth(), self.img:getHeight()
      )
    end
  end
end

function spritedata:draw (graphics, frame, pos, mirror)
  local tilesize  = map.get_tilesize()
  self.quads[frame.i][frame.j]:flip(unpack(mirror))
  graphics.drawq(
    self.img,
    self.quads[frame.i][frame.j],
    tilesize*(pos.x-1), tilesize*(pos.y-1),
    0, 1, 1,
    self.hotspot:get()
  )
  self.quads[frame.i][frame.j]:flip(unpack(mirror))
end
