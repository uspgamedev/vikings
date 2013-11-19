
require 'game.builder'
require 'things.collectable'
require 'game.vec2'

return function(pos, dmg, wgt)
  dmg = dmg or {3,20}
  wgt = wgt or {3,7}
  local item = collectable:new {
    pos       = pos,
    damage    = math.random(unpack(dmg)),
    weight    = math.random(unpack(wgt)),
    sprite    = builder.sprite 'axe',
    name      = "Iron Axe",
  }
  --item.hitboxes.helpful.class = 'weapon'
  item.hitboxes.bump = builder.bumpbox 'item'
  return item
end