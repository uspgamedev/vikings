
module ('sound', package.seeall)

local music
local sounds = {}

function sound.load (audio)
  sounds.hit    = audio.newSource('data/sound/hit10.mp3.ogg', 'static')
  sounds.bounce = audio.newSource('data/sound/clang2.wav', 'static')
  sounds.slash  = audio.newSource('data/sound/swosh-01.ogg', 'static')
  sounds.pick   = audio.newSource('data/sound/itempick2.wav', 'static')
  sounds.jump   = audio.newSource('data/sound/jump.wav', 'static')
  sounds.land   = audio.newSource('data/sound/land.wav', 'static')
end

function sound.effect (id, pos)
  local effect = sounds[id]
  if not effect then return end
  local playerpos = message.send [[game]] {'position', 'player'}
  if not playerpos then return end
  pos = pos or playerpos
  if (playerpos - pos):norm1() > 20 then return end
  effect:stop()
  effect:play()
end

function sound.set_bgm(path)
  if music then music:stop() end
  music = love.audio.newSource(path, 'stream')
  music:setLooping(true)
  if music then music:play() end
end