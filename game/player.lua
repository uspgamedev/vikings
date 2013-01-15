
module ('player', package.seeall)

require 'vec2'
require 'map'

local jumpsleft = nil
local pos       = nil
local spd       = nil
local img       = nil
local frame     = { i=1, j=1 }
local maxframe  = { i=13, j=9 }
local frametime = 0
local animfps   = 25
local quads     = {}
local quadsize  = 64
local hotspot   = vec2:new{ 32, 60 }
local jumpspd   = -12
local gravity   = vec2:new{  0,  30 }
local maxspd    = vec2:new{ 30,  30 }
local collpts   = {
  vec2:new{20,60},
  vec2:new{20,15+45/2},
  vec2:new{20,15},
  vec2:new{44,60},
  vec2:new{44,15+45/2},
  vec2:new{44,15}
}

function load (graphics)
  pos = vec2:new{ 2, 9 }
  spd = vec2:new{ 0, 0 }
  jumpsleft = 2
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

local function pos_to_tile (point)
  return map.get_tile(math.floor(point.y), math.floor(point.x))
end

local function colliding (position, points)
  for _,p in ipairs(points) do
    local tile = pos_to_tile(position-(hotspot-p)/32)
    if not tile or tile.floor then
      return true
    end
  end
  return false
end

local function update_physics (dt)
  -- no, negative speed doesn't increase forever
  spd.x = math.min(math.max(-maxspd.x, spd.x), maxspd.x)
  spd.y = math.min(math.max(-maxspd.y, spd.y), maxspd.y)
  if colliding(pos, collpts) then
    error "Ooops, youre inside a wall"
  end
  pos:add(spd*dt)
  if colliding(pos, collpts) then
    local horizontal  = -vec2:new{spd.x*dt,0}
    local vertical    = -vec2:new{0,spd.y*dt}
    local hor_check   = colliding(pos+horizontal, collpts)
    local ver_check   = colliding(pos+vertical, collpts)
    if not (hor_check and not ver_check) then
      pos.x = pos.x - spd.x*dt
    end
    if (hor_check and not ver_check) or
       (hor_check and ver_check) then
      pos.y = pos.y - spd.y*dt
      if spd.y > 0 then
        jumpsleft = 2
      end
      spd.y = 0
    end
  end
  spd:add(gravity * dt)
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
  if jumpsleft > 0 then
    jumpsleft = jumpsleft - 1
    spd.y = jumpspd
  end
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
    hotspot:get()
  )
end
