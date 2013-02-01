
module ('builder', package.seeall)

require 'vec2'
require 'avatar'
require 'sprite'

local function draw_buble (self, graphics)
  if self.text then
    graphics.setColor(255, 255, 255, math.min(self.counter, 1) * 255)
    graphics.print(self.text, 
      map.get_tilesize() * (self.pos.x - 1),
      map.get_tilesize() * (self.pos.y - 2.5)
    )
    graphics.setColor(255, 255, 255, 255)
  end
end

local function update_buble (self, dt)
  self.counter = self.counter - dt
  if self.counter <= 0 then
    self.text = nil
  end
end

local butler
function build_sprite ()
  butler = butler or sprite:new {
    img       = love.graphics.newImage "sprite/viking_male_spritesheet.png",
    maxframe  = { i=13, j=9 },
    quadsize  = 64,
    hotspot   = vec2:new{ 32, 40 },
    collpts   = {
      vec2:new{20,60},
      vec2:new{20,15+45/2},
      vec2:new{20,15},
      vec2:new{44,60},
      vec2:new{44,15+45/2},
      vec2:new{44,15}
    }
  }
  return butler
end

function build_npc ()
  local npc = avatar:new {
    pos    = vec2:new{ 12.5, 9 },
    spd    = vec2:new{ 0, 0 },
    sprite = build_sprite(),
    counter = 0
  }
  npc.drawtasks.buble = draw_buble
  npc.tasks.buble = update_buble
  function npc:interact (player)
    self.text = "Stay a while and listen."
    self.counter = 2
  end
  return npc
end

function build_vendor ()
  local npc = avatar:new {
    pos    = vec2:new{ 14.5, 8 },
    spd    = vec2:new{ 0, 0 },
    sprite = build_sprite(),
    counter = 0
  }
  npc.drawtasks.buble = draw_buble
  npc.tasks.buble = update_buble
  function npc:interact (player)
    if player.equipment[1] then
      self.text = "Nice color."
    else
      self.text = "You don't have equipment?"
    end
    self.counter = 2
  end
  return npc
end

function build_enemy ()
  local enemy = avatar:new {
    pos       = vec2:new{ 18.5, 8 },
    spd       = vec2:new{ 0, 0 },
    sprite    = build_sprite(),
    direction = 'left'
  }
  enemy.hitbox.class = 'damageable'
  return enemy
end
