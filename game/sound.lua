
module ('sound', package.seeall)

local sounds = {}

function sound.load (audio)
  sounds.hit = audio.newSource('sound/hit10.mp3.ogg', 'static')
end

function sound.effect (id)
  local effect = sounds[id]
  effect:stop()
  effect:play()
end
