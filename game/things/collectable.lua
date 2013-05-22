
require 'things.thing'
require 'game.vec2'
require 'game.hitbox'
require 'game.message'

collectable = thing:new {
  pick_delay = 0,
  slot = 1
}

function collectable:__init ()
  self.hitboxes.helpful.class = 'collectable'
end

function collectable:update(dt, map)
  collectable:__super().update(self, dt, map)
  self.pick_delay = math.max(self.pick_delay - dt, 0)
end

function collectable:get_description()
  local description = self.name.." ("
  local first = true
  for _,stat in ipairs{"damage","armor","weight"} do
    if self[stat] then
      if not first then description = description .. '/' end
      description = description .. stat .. "="..self[stat]
      first = false
    end
  end
  return description..")"
end
