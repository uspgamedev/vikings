
require 'vec2'
require 'map'
require 'avatar'
require 'sprite'

local w,h
local camera_pos
local tasks = {}
local avatars = {}

function love.load ()
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  camera_pos = vec2:new{ w/2, h/2 }
  map.load(love.graphics)

  local butler = sprite:new {
    img       = love.graphics.newImage "sprite/viking_male_spritesheet.png",
    maxframe  = { i=13, j=9 },
    quadsize  = 64,
    hotspot   = vec2:new{ 32, 60 },
    collpts   = {
      vec2:new{20,60},
      vec2:new{20,15+45/2},
      vec2:new{20,15},
      vec2:new{44,60},
      vec2:new{44,15+45/2},
      vec2:new{44,15}
    }
  }

  local player = avatar:new {
    pos    = vec2:new{ 2, 9 },
    spd    = vec2:new{ 0, 0 },
    sprite = butler,
    frame  = { i=4, j=1 },
  }
  function player:try_interact()
    for _,av in pairs(avatars) do
      if av.interact and av ~= self
         and (avatars.player.pos - av.pos):length() < 1.5 then
        av:interact(self)
      end
    end
  end

  function tasks.checkdamage (dt)
    if not player.hitbox then return end
    local collisions = player.hitbox:get_collisions()
    if not collisions then return end
    for _,another in ipairs(collisions) do
      another:unregister()
    end
  end

  hitbox:new {
    pos = vec2:new{ 16.5, 7 },
    size = vec2:new{ 2, 2 }
  } :register 'damageable'

  local npc = avatar:new {
    pos    = vec2:new{ 12.5, 9 },
    spd    = vec2:new{ 0, 0 },
    sprite = butler,
    frame  = { i=2, j=1 },
    counter = 0
  }
  npc.drawtasks.buble = function (self, graphics)
    if self.text then
      graphics.setColor(255, 255, 255, math.min(self.counter, 1) * 255)
      graphics.print(self.text, 
        map.get_tilesize() * (self.pos.x - 1),
        map.get_tilesize() * (self.pos.y - 3)
      )
      graphics.setColor(255, 255, 255, 255)
    end
  end
  npc.tasks.buble = function (self, dt)
    self.counter = self.counter - dt
    if self.counter <= 0 then
      self.text = nil
    end
  end
  function npc:interact(player)
    self.text = "Stay a while and listen."
    self.counter = 2
  end

  local npcb = avatar:new {
    pos    = vec2:new{ 14.5, 8 },
    spd    = vec2:new{ 0, 0 },
    sprite = butler,
    frame  = { i=2, j=1 },
    counter = 0
  }
  npcb.drawtasks.buble = npc.drawtasks.buble
  npcb.tasks.buble = npc.tasks.buble  
  function npcb:interact(player)
    if player.equipment[1] then
      self.text = "Nice color."
    else
      self.text = "You don't have equipment?"
    end
    self.counter = 2
  end

  avatars.player = player
  table.insert(avatars, npc)
  table.insert(avatars, npcb)

  tasks.updateavatars = function (dt)
    for _,av in pairs(avatars) do
      av:update(dt)
    end
  end
end


function love.update (dt)
  for k,v in pairs(tasks) do
    v(dt)
  end
end

local speedhack = {
  left  = vec2:new{ -5,  0 },
  right = vec2:new{  5,  0 }
}

function love.keypressed (button)
  local dv = speedhack[button]
  if dv then
    avatars.player:accelerate(dv)
  elseif button == "z" then
    avatars.player:jump()
  elseif button == "x" then
    avatars.player:attack()
  elseif button == "a" then
    if avatars.player.equipment[1] then
      avatars.player:equip(1, nil)
    else
      avatars.player:equip(1, {})
    end
  elseif button == "up" then
    if avatars.player.try_interact then
      avatars.player:try_interact()
    end
  elseif button == "escape" then
    love.event.push("quit")
  end
end

function love.keyreleased (button)
  local dv = speedhack[button]
  if dv then
    avatars.player:accelerate(-dv)
  end
end

local function mousetotile ()
  local x,y       = love.mouse.getPosition()
  local tilesize  = map.get_tilesize()
  return math.floor(y/tilesize)+1, math.floor(x/tilesize)+1
end

local function tilesetter (typeid)
  return function ()
    local i, j = mousetotile()
    map.set_tile(i, j, typeid)
  end
end

function love.mousepressed (x, y, button)
  if button == 'l' then
    tasks.addtile = tilesetter 'ice'
  elseif button == 'r' and not tasks.addtile then
    tasks.removetile = tilesetter 'empty'
  end
end

function love.mousereleased (x, y, button)
  if button == 'l' then
    tasks.addtile = nil
  elseif button == 'r' then
    tasks.removetile = nil
  end
end

function love.draw ()
  map.draw(love.graphics)
  for _,av in pairs(avatars) do
    av:draw(love.graphics)
  end
  hitbox.draw_all(love.graphics)
end

