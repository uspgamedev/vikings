
module ('player', package.seeall)

require 'vec2'

local pos   = nil
local spd   = nil
local img   = nil
local frame = { i=1, j=1 }
local quads = {}

function load (graphics)
  pos = vec2:new{ 1, 9 }
  spd = vec2:new{ 0, 5 }
  img = graphics.newImage "sprite/male_spritesheet.png"
  faceright()
  for i=1,13 do
    quads[i] = {}
    for j=1,9 do
      quads[i][j] = graphics.newQuad(
        64*(j-1),
        64*(i-1),
        64, 64, img:getWidth(), img:getHeight()
      )
    end
  end
end

local function colliding (map)
  local i,j = math.floor(pos.y), math.floor(pos.x)
  return map[i] and (map[i][j] and map[i][j].floor) or false
end

function move (map, dt)
  pos:add(spd*dt)
  if colliding(map) then
    pos.y = pos.y - spd.y*dt
  end
end

function addspeed (dv)
  spd:add(dv)
end

function subspeed (dv)
  spd:sub(dv)
end

function faceright ()
  frame.i = 4
end

function faceleft ()
  frame.i = 2
end

function draw (graphics)
  graphics.drawq(
    img,
    quads[frame.i][frame.j],
    32*(pos.x-1), 32*(pos.y-1),
    0, 1, 1,
    32, 62)
end
