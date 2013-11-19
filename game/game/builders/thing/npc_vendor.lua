
require 'game.builder'
require 'things.avatar'
require 'spriteeffect.speech'

return function(pos)
  local npc = avatar:new {
    name   = "Vendor",
    pos    = pos,
    sprite    = builder.sprite 'viking',
    slashspr  = builder.sprite 'slash',
  }
  function npc:interact (player)
    local text = "You need a weapon..."
    if player.equipment[1] then
      text = "Nice axe."
    end
    self.sprite.effects.speech = spriteeffect.speech:new {
      pos     = self.pos:clone(),
      text    = text,
      counter = 2
    }
  end
  return npc
end
