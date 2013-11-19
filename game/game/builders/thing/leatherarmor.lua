
require 'game.builder'
require 'things.collectable'
require 'game.vec2'

return function(pos, dmg, armor)
  armor = armor or {3,10}
  wgt = wgt or {3,8}
  local item = collectable:new {
    pos       = pos,
    armor     = math.random(unpack(armor)),
    weight    = math.random(unpack(wgt)),
    sprite    = builder.sprite 'armor',
    slot      = 2,
    name      = "Leather Armor",
  }
  --item.hitboxes.helpful.class = 'armor'
  item.hitboxes.bump = builder.bumpbox 'item'
  return item
end