
require 'lux.object'

animation = lux.object.new {
  current     = nil,
  mirror      = { false, false },

  frame_step  = 1,
  frametime   = 0
}

function animation:__init ()
  self.animations = animation or {
    default = {
      type    = 'loop'
      fps     = 10,
      frames  = {{i=1, j=1}}
    }
  }
  self:play 'default'
end

function animation:register (id, data)
  if not data then
    return function (data)
      self:add(id, data)
    end
  end
  self.animations[id] = data
end

function animation:set_mirror (horizontal, vertical)
  self.mirror = { horizontal, vertical }
end

function animation:play (id)
  self.current    = self.animations[id]
  self.frametime  = 0
end

function animation:step_loop ()
  self.frame_step = (self.frame_step % #self.current.frames) + 1
end

function animation:step_once ()
  self.frame_step = math.min(self.frame_step + 1, #self.current.frames)
end

function animation:step (type)
  self['step_'..type] (self)
end

function animation:update (dt)
  self.frametime = self.frametime + dt
  while self.frametime >= 1/self.sprite.animfps do
    self:step(self.current.type)
    self.frametime = self.frametime - 1/self.sprite.animfps
  end
end

function animation:draw (graphics, sprite, pos)
  sprite:draw(graphics, self.current.frames[self.frame_step], pos)
end

