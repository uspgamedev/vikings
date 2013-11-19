
require 'game.message'
require 'game.builder'
require 'game.hitbox'
require 'game.vec2'
require 'game.sound'
require 'things.avatar'

return function(pos)
  local player = avatar:new {
    pos       = pos,
    sprite    = builder.sprite 'viking',
    slashspr  = builder.sprite 'slash',
    frame     = { i=4, j=1 },
    name      = "Player",
    color     = { math.random(0, 255), math.random(0, 255), math.random(0, 255) },
  }
  player.hitboxes.harmful = hitbox:new {
    size  = vec2:new { 0.8, 0.8 },
    class = 'damageable'
  }
  player.hitboxes.bump = builder.bumpbox 'avatar'
  player.slash.hitboxes.helpful.size:set(1.2, 1.2)
  function player:try_interact()
    local collisions = self.hitboxes.helpful:get_collisions 'avatar'
    for _,target in pairs(collisions) do
      if target.owner and target.owner ~= self
         and (self.pos - target.owner.pos):length() < 1.5 then
        target.owner:interact(self)
      end
    end
    collisions = self.hitboxes.helpful:get_collisions 'collectable'
    if #collisions > 0 then
      for _,itemhit in pairs(collisions) do
        local item = itemhit.owner
        if item.pick_delay == 0 and self:equip(item.slot, item) then
          sound.effect 'pick'
          message.send [[game]] {'kill', item}
        end
      end
    else
      collisions = self.hitboxes.helpful:get_collisions 'door'
      if #collisions <= 0 then return end
      message.send [[game]] {'changemap'}
    end
  end

  local axe = builder.thing("ironaxe", vec2:new{}, {2,5}, {3,4})
  player:equip(axe.slot, axe)

  local armor = builder.thing("leatherarmor", vec2:new{}, {2,4}, {1,3})
  player:equip(armor.slot, armor)
  return player
end
