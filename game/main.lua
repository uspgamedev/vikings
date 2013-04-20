
require 'vec2'
require 'map.map'
require 'things.avatar'
require 'builder'
require 'message'
require 'map.maploader'
require 'sound'
require 'hitbox'
require 'gamescene'

local debug = false
local graphics
local current_scene

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function parse_args(args)
  local map_file, no_joystick
  for _, arg in ipairs(args) do
    map_file = string.ends(arg, ".vikingmap") and arg or map_file
    no_joystick = no_joystick or arg == "--no-joystick"
    if arg == '--debug' then
      debug = true
    end
  end
  return map_file, no_joystick
end

local function create_player( joystick )
  local player  = builder.build_thing("player",  vec2:new{})
  local axe     = builder.build_thing("ironaxe", vec2:new{}, {3,3}, {3,3})
  player:equip(axe.slot, axe)
  if joystick then
    builder.add_joystick_input(player)
  else
    builder.add_keyboard_input(player)
  end
  return player
end

function love.load (args)
  graphics = {}
  setmetatable(graphics, { __index = love.graphics })
  function graphics:get_tilesize() 
    return current_scene.map:get_tilesize()
  end
  function graphics:get_screensize()
    return vec2:new{self.getWidth(), self.getHeight()}
  end
  graphics.setFont(graphics.newFont(12))

  sound.load(love.audio)
  sound.set_bgm "data/music/JordanTrudgett-Snodom-ccby3.ogg"

  local map_file, no_joystick = parse_args(args)

  current_scene = gamescene:new{
    map = maploader.load(map_file),
    background = graphics.newImage "data/background/Ardentryst-Background_SnowCave_Backing.png",
    players = { create_player(not no_joystick and love.joystick.getNumJoysticks() > 0) },
  }
  
  message.add_receiver('game', function (cmd, ...) return current_scene:handle_message(cmd, ...) end)
  message.add_receiver('debug', function (...) return debug end)
end


function love.update (dt)
  current_scene:update(dt)
end

function love.keypressed (button)
  if button == "p" then
    if current_scene and current_scene.map then 
      current_scene.map:save_to_file(os.date "%Y-%m-%d_%H-%M-%S.vikingmap")
    end
  elseif button == "escape" then
    love.event.push("quit")
  else
    current_scene:input_pressed(button)
  end
end

function love.keyreleased (button)
  current_scene:input_released(button)
end

function love.joystickpressed(joystick, button)
  current_scene:input_pressed(button, joystick)
end

function love.joystickreleased(joystick, button)
  current_scene:input_released(button, joystick)
end

--[[
local function mousetotile ()
  local x,y          = love.mouse.getPosition()
  local screencenter = vec2:new{love.graphics.getWidth(), love.graphics.getHeight()} * 0.5
  local tilesize     = map.get_tilesize()
  return math.floor((y - screencenter.y)/tilesize + avatars.player.pos.y) + 1, 
         math.floor((x - screencenter.x)/tilesize + avatars.player.pos.x) + 1
end

local function tilesetter (typeid)
  return function ()
    local i, j = mousetotile()
    current_map:set_tile(i, j, typeid)
  end
end

function love.mousepressed (x, y, button)
  if button == 'l' then
    tasks.addtile = tilesetter 'I'
  elseif button == 'r' and not tasks.addtile then
    tasks.removetile = tilesetter ' '
  end
end

function love.mousereleased (x, y, button)
  if button == 'l' then
    tasks.addtile = nil
  elseif button == 'r' then
    tasks.removetile = nil
  end
end
]]

function love.draw ()
  current_scene:draw(graphics)
end

