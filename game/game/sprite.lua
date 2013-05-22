
require 'lux.object'
require 'game.vec2'
require 'game.animation'

sprite = lux.object.new {
  data          = nil,
  animation     = nil,
  speed         = 1,
  mirror        = { false, false },
  effects   = nil,

  framestep     = 1,
  frametime     = 0
}

sprite.__init = {
  animation   = animation:new{},
  effects = {}
}

function sprite:set_mirror (horizontal, vertical)
  self.mirror = { horizontal, vertical }
end

function sprite:play_animation (animation)
  if self.animation == animation then return end
  self.animation = animation
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
  for k,effect in pairs(self.effects) do
    if effect:update(self, dt) then
      table.insert(to_remove, k)
    end
  end
  for _,k in ipairs(to_remove) do
    self.effects[k] = nil
  end
end

function sprite:draw_data (graphics)
  local frame = self.animation.frames[self.framestep]
  self.data:draw(graphics, frame, self.mirror)
end

function sprite:draw (graphics, pos)
  graphics.push()
  graphics.translate((graphics.get_tilesize()*(pos-vec2:new{1,1})):get())
  self:draw_data(graphics)
  for _,effect in pairs(self.effects) do
    effect:draw(graphics, self)
  end
  graphics.pop()
end
