
require 'game.builder'
require 'things.avatar'
require 'spriteeffect.speech'

return function(pos)
  local npc = avatar:new {
    name   = "Deckard Cain",
    pos    = pos,
    sprite    = builder.sprite 'viking',
    slashspr  = builder.sprite 'slash',
  }
  function npc:interact (player)
    self.sprite.effects.speech = spriteeffect.speech:new {
      pos     = self.pos:clone(),
      text    = "Stay a while and listen. And heal.",
      counter = 2
    }
    player.life = player.maxlife
  end
  return npc
end