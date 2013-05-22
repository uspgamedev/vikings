
require 'things.thing'
require 'game.sound'
require 'game.vec2'
require 'animationset.slash'
require 'agent'
require 'spriteeffect.splash'
require 'game.message'

slash = thing:new {
  source = nil,
}

local function splash_ice (reference, tile)
  local agent = agent:new{
    counter = .3
  }
  function agent.tasks:timer (dt)
    self.counter = self.counter - dt
    if self.counter <= 0 then
      message.send [[game]] {'kill', self}
    end
  end
  agent.sprite.effects.splash = spriteeffect.splash:new{ color = { 190,240,240 } }
  agent.pos = (reference + vec2:new{tile.i, tile.j} + vec2:new{.5,.5})/2
  return agent
end

local function splash_blood (pos)
  local agent = agent:new{
    counter = .3
  }
  function agent.tasks:timer (dt)
    self.counter = self.counter - dt
    if self.counter <= 0 then
      message.send [[game]] {'kill', self}
    end
  end
  agent.sprite.effects.splash = spriteeffect.splash:new{ color = { 200,10,10 } }
  agent.pos = pos
  return agent
end

function slash:__init ()
  assert(self.source, "Slash without slasher.")
  self.bounced = true
  --self.hitboxes.helpful.size = vec2:new{0.8, 0.8}
  self.hitboxes.helpful.class = 'slash'
  self.hitboxes.helpful.owner = self
  self.hitboxes.helpful.targetclass = 'damageable'
  self.hitboxes.helpful.on_collision = function (self, collisions)
    for _,another in ipairs(collisions) do
      if another.owner then
        local attacker  = self.owner.source
        local amount    = self.owner:get_damage()
        local wgt_ratio = (2*self.owner:get_weight()+amount)/3/another.owner:get_weight()
        if another.owner:take_damage(amount) then
          local dir = (attacker.pos-another.owner.pos):normalized()
          another.owner:shove(7*wgt_ratio*(vec2:new{0,-1}-dir):normalized())
          attacker:shove(7/wgt_ratio*(vec2:new{0,-1}+dir):normalized())
          message.send [[game]] {'put', splash_blood((self.owner.pos+another.pos)/2)}
        end
      else
        another:unregister()
      end
    end
  end
  self.hitboxes.helpful.update = function (self, owner, dt)
    self.pos =
      owner.pos
      -
      self.size/2
      +
      vec2:new{(owner.direction=='right' and 1 or -1)*self.size.x/2, 0}
  end
end

function slash:get_damage()
  return self.source and self.source:get_damage() or 0
end

function slash:get_weight()
  return self.source and self.source:get_weight() or 1
end

function slash:activate ()
  if self.activated then return end
  self.sprite:play_animation(animationset.slash.active)
  self.activated = true
  self.bounced = false
  self.hitboxes.helpful:register 'playeratk'
end

function slash:deactivate ()
  self.sprite:play_animation(animationset.slash.inactive)
  self.activated = false
  self.bounced = true
  self.hitboxes.helpful:unregister()
end

function slash:update (dt, map)
  self.pos        = self.source:get_atkpos()
  self.direction  = self.source.direction
  self:update_sprite(dt)
  self:update_hitbox()
  if self.activated and not self.bounced then
    local collisions = self:colliding(map, self.pos)
    if not collisions then return end
    local dir = (self.pos-self.source.pos):normalized()
    self.source:shove(60/self:get_weight()*(vec2:new{0,-1}-dir):normalized())
    self.source.airjumpsleft = 1
    self.bounced = true
    sound.effect 'bounce'
    for _,collision in ipairs(collisions) do
      message.send [[game]] {'put', splash_ice(self.pos, collision)}
    end
  end
end
