
module ('player', package.seeall)

require 'vec2'
require 'map'

local pos   = nil
local spd   = nil
local img   = nil
local frame = { i=1, j=1 }
local quads = {}

function load (graphics)
  pos = vec2:new{ 1, 9 }
  spd = vec2:new{ 0, 5 }
  img = graphics.newImage "sprite/male_spritesheet.png"
  frame.i = 4
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

local function colliding ()
  local i,j = math.floor(pos.y), math.floor(pos.x)
  local tile = map.get_tile(i, j)
  return tile and tile.floor or false
end

function move (dt)
  pos:add(spd*dt)
  if colliding() then
    pos.y = pos.y - spd.y*dt
  end
  if spd.x > 0 then
    frame.i = 4
  elseif spd.x < 0 then
    frame.i = 2
  end
end

function accelerate (dv)
  spd:add(dv)
end

function draw (graphics)
  graphics.drawq(
    img,
    quads[frame.i][frame.j],
    32*(pos.x-1), 32*(pos.y-1),
    0, 1, 1,
    32, 62
  )
end
