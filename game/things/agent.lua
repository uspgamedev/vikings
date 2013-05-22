
require 'things.thing'
require 'game.vec2'
require 'game.sprite'
require 'game.spritedata'

agent = thing:new {}

local empty_data = spritedata:new {
  maxframe  = { i=0, j=0 },
  quadsize  = 1,
  hotspot   = vec2:new{},
  collpts   = {},
  draw      = function () end
}

agent.__init = {
  sprite = sprite:new { data = empty_data }
}

function agent:update (dt, map)
  self:update_sprite(dt)
  self:update_hitbox(dt)
  self:update_tasks(dt)
end
