
module ('player', package.seeall)

require 'vec2'
require 'map'

local pos       = nil
local spd       = nil
local img       = nil
local frame     = { i=1, j=1 }
local maxframe  = { i=13, j=9 }
local frametime = 0
local animfps   = 25
local quads     = {}
local quadsize  = 64
local jumpspd   = vec2:new{  0, -12 }
local gravity   = vec2:new{  0,  30 }
local maxspd    = vec2:new{ 30,  30 }

function load (graphics)
  pos = vec2:new{ 1, 9 }
  spd = vec2:new{ 0, 0 }
  img = graphics.newImage "sprite/male_spritesheet.png"
  frame.i = 4
  for i=1,maxframe.i do
    quads[i] = {}
    for j=1,maxframe.j do
      quads[i][j] = graphics.newQuad(
        quadsize*(j-1),
        quadsize*(i-1),
        quadsize, quadsize, img:getWidth(), img:getHeight()
      )
    end
  end
end

local function colliding ()
  local i,j = math.floor(pos.y), math.floor(pos.x)
  local tile = map.get_tile(i, j)
  return tile and tile.floor or false
end

local function update_physics (dt)
  -- no, negative speed doesn't increase forever
  spd.x = math.min(math.max(-maxspd.x, spd.x), maxspd.x)
  spd.y = math.min(math.max(-maxspd.y, spd.y), maxspd.y)
  pos:add(spd*dt)
  if not colliding() then
    spd:add(gravity * dt)
  else
    pos.y = pos.y - spd.y*dt
    spd.y = 0
  end
end

local function update_animation (dt)
  local moving = true
  if spd.x > 0 then
    frame.i = 4
  elseif spd.x < 0 then
    frame.i = 2
  else
    frame.j = 1
    moving = false
  end
  if not moving then return end
  frametime = frametime + dt
  while frametime >= 1/animfps do
    frame.j = frame.j%(#quads[frame.i]) + 1
    frametime = frametime - 1/animfps
  end
end

function update (dt)
  update_physics(dt)
  update_animation(dt)
end

function jump ()
  spd:add(jumpspd)
end

function accelerate (dv)
  spd:add(dv)
end

function draw (graphics)
  local tilesize = map.get_tilesize()
  graphics.drawq(
    img,
    quads[frame.i][frame.j],
    tilesize*(pos.x-1), tilesize*(pos.y-1),
    0, 1, 1,
    quadsize/2, quadsize-4
  )
end
