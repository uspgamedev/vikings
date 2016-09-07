
require 'lux.object'
require 'map.map'

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

function spritedata:draw (graphics, frame, mirror)
  local tilesize  = graphics.get_tilesize()
  -- self.quads[frame.i][frame.j]:flip(unpack(mirror)) -- TODO

  graphics.draw(
    self.img, -- texture
    self.quads[frame.i][frame.j], -- quad
    0, 0,
    -- mirror[1] and self.quadsize or 0, -- x
    -- mirror[2] and self.quadsize or 0, -- y
    0, -- rot
    mirror[1] and -1 or 1, -- scale x
    mirror[2] and -1 or 1, -- scale y
    self.hotspot:get()
  )
end
