
require 'game.message'
require 'game.builder'
require 'game.hitbox'
require 'things.avatar'
require 'spriteeffect.speech'
require 'data.animationset.drillbeast'

return function(pos)
  local enemy = avatar:new {
    name          = "Drillbeast",
    pos           = pos,
    maxlife       = 20,
    animationset  = animationset.drillbeast,
    sprite        = builder.sprite 'drillbeast',
    slashspr      = builder.sprite 'slash',
    direction     = 'left',
  }
  enemy:equip(1, builder.thing "ironaxe")
  enemy.hitboxes.bump = builder.bumpbox 'avatar'
  enemy.slash.hitboxes.helpful.size:set(0.8, 0.8)
  local counter = math.random()*5
  local change  = 0
  function enemy.tasks.attack (self, dt)
    counter = counter + dt
    local playerpos = message.send [[game]] {'position', 'player'}
    if playerpos then
      local distance = (playerpos - self.pos):length()
      if distance < 3 then
        self.direction = (playerpos.x < self.pos.x) and 'left' or 'right'
        self:attack()
      elseif distance < 6 then
        local dir = vec2:new{((playerpos.x > self.pos.x) and 1 or -1), 0}
        self:accelerate(8*dir)
      elseif change <= 0 then
        local dir = vec2:new{math.random() < .5 and 1 or -1, 0}
        self:accelerate(5*dir)
        change = 1+math.random()*5
      else
        local dir = vec2:new{(self.direction=='right' and 1 or -1), 0}
        self:accelerate(5*dir)
        change = change - dt
      end
      --if self:colliding(self.pos+2*dir) then
      if counter > 5 then
        self:jump()
        counter = 0
      end
    end
  end
  enemy.hitboxes.harmful = hitbox:new {
    size  = vec2:new { 1.4, 1.4 },
    class = 'damageable'
  }
  return enemy
end
