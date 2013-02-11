
require 'lux.object'
require 'vec2'
require 'map'
require 'animation'

sprite = lux.object.new {
  img           = nil,
  maxframe      = nil,
  quadsize      = nil, -- must be a number
  hotspot       = nil,
  collpts       = nil,
  animation     = nil,
  mirror        = { false, false }

  framestep     = 1,
  frametime     = 0
}

function sprite:__init()
  self.animation = self.animation or animation:new{}
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

function sprite:set_mirror (horizontal, vertical)
  self.mirror = { horizontal, vertical }
end

function sprite:play_animation (animation)
  self.animation  = animation
  self.framestep  = 1
  self.frametime  = 0
end

function sprite:update (dt)
  self.frametime = self.frametime + dt
  while self.frametime >= 1/self.animation.fps do
    self.framtestep = self.animation:step(self.framtestep)
    self.frametime = self.frametime - 1/self.sprite.animfps
  end
end

function sprite:draw (graphics, pos)
  local frame     = self.animation.frames[self.framestep]
  local tilesize  = map.get_tilesize()
  self.quads[frame.i][frame.j]:flip(unpack(self.mirror))
  graphics.drawq(
    self.img,
    self.quads[frame.i][frame.j],
    tilesize*(pos.x-1), tilesize*(pos.y-1),
    0, 1, 1,
    self.hotspot:get()
  )
  self.quads[frame.i][frame.j]:flip(unpack(self.mirror))
end
