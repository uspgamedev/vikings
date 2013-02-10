
require 'thing'

slash = thing:new {
  source = nil,
  damage = 5
}

function slash:__init ()
  assert(self.source, "Slash without slasher.")
  self.bounced = true
  self.hitbox.class = 'slash'
  self.hitbox.owner = self
  self.hitbox.targetclass = 'damageable'
  self.hitbox.on_collision = function (self, collisions)
    for _,another in ipairs(collisions) do
      if another.owner then
        local attacker = self.owner.source
        local amount = 5
        if another.owner:take_damage(amount) then
          local dir = (attacker.pos-another.owner.pos):normalized()
          another.owner:shove(2*amount*(vec2:new{0,-1}-dir):normalized())
          attacker:shove(2*amount*(vec2:new{0,-1}+dir):normalized())
        end
      else
        another:unregister()
      end
    end
  end
end

function slash:activate ()
  if self.activated then return end
  self.activated = true
  self.bounced = false
  self.hitbox:register 'playeratk'
end

function slash:deactivate ()
  self.activated = false
  self.bounced = true
  self.hitbox:unregister()
end

function slash:update (dt, map)
  self.pos        = self.source:get_atkpos()
  self.hitbox.pos = self.source:get_atkhitboxpos()
  self.frame      = {i=self.source.frame.j-3, j=1}
  self.mirror     = self.source.direction=='right' and 'h' or nil
  if self.activated and not self.bounced and self:colliding(map, self.pos) then
    local dir = (self.pos-self.source.pos):normalized()
    self.source:shove(2*self.damage*(vec2:new{0,-1}-dir):normalized())
    self.bounced = true
  end
end

function slash:draw (graphics)
  self.sprite:draw(graphics, self.frame, self.pos, self.mirror)
end
