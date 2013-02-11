
require 'lux.object'
require 'vec2'
require 'animation'

sprite = lux.object.new {
  data          = nil,
  animation     = nil,
  speed         = 1,
  mirror        = { false, false },
  draweffects   = nil,

  framestep     = 1,
  frametime     = 0
}

sprite.__init = {
  animation   = animation:new{},
  draweffects = {}
}

function sprite:set_mirror (horizontal, vertical)
  self.mirror = { horizontal, vertical }
end

function sprite:play_animation (animation)
  if self.animation == animation then return end
  self.animation  = animation
  self:restart_animation()
end

function sprite:restart_animation ()
  self.framestep  = 1
  self.frametime  = 0
end

function sprite:update (observer, dt)
  self.frametime = self.frametime + dt*self.speed
  while self.frametime >= 1/self.animation.fps do
    self.framestep = self.animation:step(self.framestep, observer)
    self.frametime = self.frametime - 1/self.animation.fps
  end
  local to_remove = {}
  for k,effect in pairs(self.draweffects) do
    if effect:update(dt) then
      table.insert(to_remove, k)
    end
  end
  for _,k in ipairs(to_remove) do
    self.draweffects[k] = nil
  end
end

function sprite:draw (graphics, pos)
  local frame = self.animation.frames[self.framestep]
  self.data:draw(graphics, frame, pos, self.mirror)
  for _,effect in pairs(self.draweffects) do
    effect:draw(graphics)
  end
end
