
module ('builder', package.seeall)

require 'game.vec2'
require 'things.avatar'
require 'things.collectable'
require 'game.sprite'
require 'game.spritedata'
require 'game.message'
require 'game.sound'
require 'data.animationset.monster'
require 'spriteeffect.speech'

local butler
function build_sprite ()
  butler = butler or spritedata:new {
    img       = love.graphics.newImage "data/sprite/viking_male_spritesheet.png",
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
  return sprite:new{ data = butler }
end

local monster
function build_monster ()
  monster = monster or spritedata:new {
    img       = love.graphics.newImage "data/sprite/hornbeast.png",
    maxframe  = { i=2, j=7 },
    quadsize  = 64,
    hotspot   = vec2:new{ 32, 32 },
    collpts   = {
      vec2:new{15,      15},
      vec2:new{15,      15+44/2},
      vec2:new{15,      60},
      vec2:new{15+34/2, 15},
      vec2:new{15+34/2, 60},
      vec2:new{64-15,   15},
      vec2:new{64-15,   15+44/2},
      vec2:new{64-15,   60}
    }
  }
  return sprite:new{ data = monster }
end

local slash
function build_slash ()
  slash = slash or spritedata:new {
    img       = love.graphics.newImage "data/sprite/slash.png",
    maxframe  = { i=3, j=1 },
    quadsize  = 64,
    hotspot   = vec2:new{ 32, 32 },
    collpts   = {
      vec2:new{16,16},
      vec2:new{16,48},
      vec2:new{48,48},
      vec2:new{48,16}
    }
  }
  return sprite:new { data = slash }
end

local axe
function build_axesprite ()
  axe = axe or spritedata:new {
    img       = love.graphics.newImage "data/sprite/battle-axe-v02.png",
    maxframe  = { i=1, j=1 },
    quadsize  = 32,
    hotspot   = vec2:new{ 16, 16 },
    collpts   = {
      vec2:new{4,4},
      vec2:new{4,32-4},
      vec2:new{32-4,4},
      vec2:new{32-4,32-4}
    }
  }
  axe.img:setFilter("linear", "linear")
  return sprite:new { data = axe }
end

local armor
function build_armorsprite ()
  armor = armor or spritedata:new {
    img       = love.graphics.newImage "data/sprite/mail-shirt.png",
    maxframe  = { i=1, j=1 },
    quadsize  = 32,
    hotspot   = vec2:new{ 16, 16 },
    collpts   = {
      vec2:new{4,4},
      vec2:new{4,32-4},
      vec2:new{32-4,4},
      vec2:new{32-4,32-4}
    }
  }
  armor.img:setFilter("linear", "linear")
  return sprite:new { data = armor }
end

local doorsprite
function build_doorsprite ()
  doorsprite = doorsprite or spritedata:new {
    img       = love.graphics.newImage 'data/sprite/door.png',
    quadsize  = 64,
    maxframe  = { i=1, j=1 },
    hotspot   = vec2:new {32, 32},
    collpts   = { vec2:new{32,64} }
  }
  return sprite:new { data = doorsprite }
end

local speedhack = {
  left  = vec2:new{ -10,  0 },
  right = vec2:new{  10,  0 }
}

function build_bumpbox (type)
  return hitbox:new {
    class         = 'bump_'..type,
    targetclass   = 'bump_'..type,
    on_collision  = function (self, collisions)
      for _,another in ipairs(collisions) do
        if not self.owner then return end
        if self ~= another and another.owner then
          local dir = another.owner.pos - self.owner.pos
          another.owner:shove(2*dir:normalized()/(dir:length()^2))
        end
      end
    end
  }
end

local function build_player (pos, joystick)
  local player = avatar:new {
    pos       = pos,
    sprite    = build_sprite(),
    slashspr  = build_slash(),
    frame     = { i=4, j=1 },
    name      = "Player",
  }
  player.hitboxes.harmful = hitbox:new {
    size  = vec2:new { 0.8, 0.8 },
    class = 'damageable'
  }
  player.hitboxes.bump = build_bumpbox 'avatar'
  player.slash.hitboxes.helpful.size:set(1.2, 1.2)
  function player:try_interact()
    local collisions = self.hitboxes.helpful:get_collisions 'avatar'
    for _,target in pairs(collisions) do
      if target.owner and target.owner ~= self
         and (self.pos - target.owner.pos):length() < 1.5 then
        target.owner:interact(self)
      end
    end
    collisions = self.hitboxes.helpful:get_collisions 'collectable'
    if #collisions > 0 then
      for _,itemhit in pairs(collisions) do
        local item = itemhit.owner
        if item.pick_delay == 0 and self:equip(item.slot, item) then
          sound.effect 'pick'
          message.send [[game]] {'kill', item}
        end
      end
    else
      collisions = self.hitboxes.helpful:get_collisions 'door'
      if #collisions <= 0 then return end
      message.send [[game]] {'changemap'}
    end
  end

  local axe = build_thing("ironaxe", vec2:new{}, {3,3}, {3,3})
  player:equip(axe.slot, axe)
  if joystick then
    add_joystick_input(player, joystick)
  else
    add_keyboard_input(player)
  end

  return player
end

function add_keyboard_input(player)
  function player.tasks.check_input(self, dt)
    if love.keyboard.isDown "left" then
      self:accelerate(speedhack.left)
    end
    if love.keyboard.isDown "right" then
      self:accelerate(speedhack.right)
    end
  end
  function player:input_pressed(button, joystick, mouse)
    if joystick or mouse then return end
    if button == "z" then
      self:jump()
    elseif button == "x" then
      self:attack()
    elseif button == 'c' then
      self:dash()
    elseif button == "up" then
      self:try_interact()
    elseif button == "q" then
      message.send [[game]] {'add', build_item(self.pos:clone()) }
    end
  end
  function player:input_released(button, joystick, mouse)
    if joystick or mouse then return end
  end
end

function add_joystick_input(player, joystick)
  assert(joystick, "Must have a joystick")
  local joystick_database = {
    ["Twin USB Joystick"] = {
      jump = 3,
      attack = 4,
      dash = 8,
      direction = function(dir)
        return joystick:getHat(1):find(dir, 1, true) ~= nil
      end
    },
    {
      jump = 1,
      attack = 2,
      dash = 3,
      direction = function(dir)
        if dir == "l" then
          return joystick:getAxis(1) < -0.2
        elseif dir == "r" then
          return joystick:getAxis(1) > 0.2
        elseif dir == "u" then
          return joystick:getAxis(2) < -0.2
        elseif dir == "d" then
          return joystick:getAxis(2) > 0.2
        end
      end
    }
  }
  local joy = joystick_database[joystick:getName()] or joystick_database[1]
  local up_pressed = false
  function player.tasks.check_input(self, dt)
    if joy.direction("l") then
      self:accelerate(speedhack.left)
    end
    if joy.direction("r") then
      self:accelerate(speedhack.right)
    end
    if joy.direction("u") then
      if not up_pressed then
        self:try_interact()
        up_pressed = true
      end
    else
      up_pressed = false
    end
  end
  function player:input_pressed(button, joystick, mouse)
    if not joystick then return end
    if button == joy.jump then
      self:jump()
    elseif button == joy.attack then
      self:charge()
    elseif button == joy.dash then
      self:dash()
    end
  end
  function player:input_released(button, joystick, mouse)
    if not joystick then return end
    if button == joy.attack then
      self:attack()
    end
  end
end

local function build_npc_cain (pos)
  local npc = avatar:new {
    pos    = pos,
    sprite = build_sprite(),
    slashspr  = build_slash(),
    name   = "Deckard Cain",
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

local function build_vendor (pos)
  local npc = avatar:new {
    pos    = pos,
    sprite = build_sprite(),
    slashspr  = build_slash(),
    name   = "Vendor",
  }
  function npc:interact (player)
    local text
    if player.equipment[1] then
      text = "Nice axe."
    else
      text = "Here, have an axe."
      if player:equip(1, build_item()) then
        sound.effect 'pick'
      end
    end
    self.sprite.effects.speech = spriteeffect.speech:new {
      pos     = self.pos:clone(),
      text    = text,
      counter = 2
    }
  end
  return npc
end

local function build_drillbeast (pos)
  local enemy = avatar:new {
    maxlife       = 20,
    pos           = pos,
    sprite        = build_monster(),
    animationset  = animationset.monster,
    slashspr      = build_slash(),
    direction     = 'left',
    name          = "Drillbeast"
  }
  enemy:equip(1, build_thing "ironaxe")
  enemy.hitboxes.bump = build_bumpbox 'avatar'
  enemy.slash.hitboxes.helpful.size:set(0.8, 0.8)
  local counter = love.math.random()*5
  local change  = 0
  function enemy.tasks.attack (self, dt)
    counter = counter + dt
    local playerpos = message.send [[game]] {'position', 'player'}
    if playerpos then
      local distance = (playerpos - self.pos):length()
      if distance < 3 then
        self.direction = (playerpos.x < self.pos.x) and 'left' or 'right'
        self:attack()
      elseif distance < 6 then
        local dir = vec2:new{((playerpos.x > self.pos.x) and 1 or -1), 0}
        self:accelerate(8*dir)
      elseif change <= 0 then
        local dir = vec2:new{love.math.random() < .5 and 1 or -1, 0}
        self:accelerate(5*dir)
        change = 1+love.math.random()*5
      else
        local dir = vec2:new{(self.direction=='right' and 1 or -1), 0}
        self:accelerate(5*dir)
        change = change - dt
      end
      --if self:colliding(self.pos+2*dir) then
      if counter > 5 then
        self:jump()
        counter = 0
      end
    end
  end
  enemy.hitboxes.harmful = hitbox:new {
    size  = vec2:new { 1.4, 1.4 },
    class = 'damageable'
  }
  return enemy
end

local function build_ironaxe (pos, dmg, wgt)
  dmg = dmg or {3,20}
  wgt = wgt or {3,7}
  local item = collectable:new {
    pos       = pos,
    damage    = love.math.random(unpack(dmg)),
    weight    = love.math.random(unpack(wgt)),
    sprite    = build_axesprite(),
    name      = "Iron Axe",
  }
  --item.hitboxes.helpful.class = 'weapon'
  item.hitboxes.bump = build_bumpbox 'item'
  return item
end

local function build_leatherarmor (pos)
  local item = collectable:new {
    pos       = pos,
    armor     = love.math.random(3, 7),
    weight    = love.math.random(4, 8),
    sprite    = build_armorsprite(),
    slot      = 2,
    name      = "Leather Armor",
  }
  --item.hitboxes.helpful.class = 'armor'
  item.hitboxes.bump = build_bumpbox 'item'
  return item
end

local function build_door (pos)
  local door = thing:new {
    pos       = pos,
    sprite    = build_doorsprite(),
    direction = 'left',
    name      = "Door",
  ''}
  door.hitboxes.helpful.class = 'door'
  door.hitboxes.helpful.size = vec2:new{1,2}
  return door
end

function build_thing(thing, ...)
  local funcs = {
    player = build_player,
    npc_cain = build_npc_cain,
    vendor = build_vendor,
    drillbeast = build_drillbeast,
    ironaxe = build_ironaxe,
    leatherarmor = build_leatherarmor,
    door = build_door
  }
  if funcs[thing] then
    return funcs[thing](...)
  else
    error("Unknown thing: " .. thing )
  end
end