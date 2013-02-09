
module ('sound', package.seeall)

local music
local sounds = {}

function sound.load (audio)
  sounds.hit    = audio.newSource('sound/hit10.mp3.ogg', 'static')
  sounds.slash  = audio.newSource('sound/swosh-01.ogg', 'static')
  sounds.pick   = audio.newSource('sound/itempick2.wav', 'static')
  sounds.jump   = audio.newSource('sound/jump.wav', 'static')
  sounds.land   = audio.newSource('sound/land.wav', 'static')
end

function sound.effect (id)
  local effect = sounds[id]
  effect:stop()
  effect:play()
end

function sound.set_bgm(path)
  if music then music:stop() end
  music = love.audio.newSource(path, 'stream')
  music:setLooping(true)
  if music then music:play() end
end