
require 'vec2'
require 'map.map'
require 'things.avatar'
require 'builder'
require 'message'
require 'map.maploader'
require 'sound'
require 'ui.menubuilder'

local debug = false
local graphics
local current_scene
local scene_stack = {}
local cli_args
local main_message_handler = {}

function main_message_handler.change_scene(newscene, stack)
  if current_scene then
    current_scene:unfocus()
  end
  if stack then
    table.insert(scene_stack, current_scene)
  end
  newscene = newscene or table.remove(scene_stack)
  if newscene == nil then
    error "ASDFASDF"
    return love.event.push("quit")
  end
  current_scene = newscene
  current_scene:focus()
end

function main_message_handler.get_cliargs()
  return cli_args
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function parse_args(args)
  local map_file, no_joystick, debug = false
  for _, arg in ipairs(args) do
    map_file = string.ends(arg, ".lua") and arg or map_file
    no_joystick = no_joystick or (arg == "--no-joystick")
    if arg == '--debug' then
      debug = true
    end
  end
  cli_args = { map_file = map_file, joystick = not no_joystick, debug = debug }
end

function love.load (args)
  parse_args(args)

  -- Setup graphics
  graphics = {}
  setmetatable(graphics, { __index = love.graphics })
  function graphics:get_tilesize() 
    return map.get_tilesize()
  end
  function graphics:get_screensize()
    return vec2:new{self.getWidth(), self.getHeight()}
  end
  graphics.setFont(graphics.newFont(12))

  -- Setup sound
  sound.load(love.audio)

  -- Setup message handler
  message.add_receiver('debug', function (...) return debug end)
  message.add_receiver('main', main_message_handler)

  -- Initial scene
  message.send [[main]] {'change_scene', ui.mainmenu()}
end


function love.update (dt)
  current_scene:update(dt < 0.1 and dt or 0.1)
end

function love.keypressed (button)
  if button == "escape" then
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

function love.mousepressed (x, y, button)
  current_scene:input_pressed(button, nil, vec2:new{ x, y })
end

function love.mousereleased (x, y, button)
  current_scene:input_released(button, nil, vec2:new{ x, y })
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

