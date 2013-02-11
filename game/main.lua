
require 'vec2'
require 'map'
require 'avatar'
require 'builder'
require 'message'
require 'mapgenerator'
require 'sound'

local debug = true
local w,h
local screencenter
local background
local camera_pos
local tasks = {}
local avatars = {}
local current_map
local game_message_commands = {
  kill = function ( ... )
    for _,avatar in ipairs{...} do
      for i,check in ipairs(avatars) do
        if avatar == check then
          avatar:die()
          table.remove(avatars, i)
        end
      end
    end
  end,
  position = function ( ... )
    local args = { ... }
    return avatars[args[1]] and avatars[args[1]].pos
  end
}

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local function find_grounded_open_spots(map)
  local spots = {}
  for j=1,map.height-2 do
    for i=1,map.width-1 do
      if not map.tiles[j  ][i].floor and not map.tiles[j  ][i+1].floor and
         not map.tiles[j+1][i].floor and not map.tiles[j+1][i+1].floor and
             map.tiles[j+2][i].floor and     map.tiles[j+2][i+1].floor then
        table.insert(spots, {j=j,i=i})
      end
    end
  end
  return spots
end
local function get_random_position(spots)
  local i = (debug and 1) or math.random(#spots)
  local result = spots[i]
  table.remove(spots, i)
  return vec2:new{result.i+1, result.j+1}
end

function love.load (args)
  sound.load(love.audio)
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  background = love.graphics.newImage "background/Ardentryst-Background_SnowCave_Backing.png"
  screencenter = vec2:new{w,h} * 0.5
  camera_pos = vec2:new{ w/2, h/2 }

  sound.set_bgm "music/JordanTrudgett-Snodom-ccby3.ogg"
  local map_file
  for _, arg in ipairs(args) do
    map_file = string.ends(arg, ".vikingmap") and arg or map_file
  end
  current_map = map_file and mapgenerator.from_file(map_file) or mapgenerator.random_map()
  local valid_spots = find_grounded_open_spots(current_map)

  avatars.player = builder.build_player(get_random_position(valid_spots))
  builder.add_joystick_input(avatars.player)
  table.insert(avatars, builder.build_npc   (get_random_position(valid_spots)))
  table.insert(avatars, builder.build_vendor(get_random_position(valid_spots)))
  table.insert(avatars, builder.build_enemy (get_random_position(valid_spots)))
  table.insert(avatars, builder.build_item  (get_random_position(valid_spots)))

  tasks.check_collisions = hitbox.check_collisions
  tasks.updateavatars = function (dt)
    for _,av in pairs(avatars) do av:update(dt, current_map) end
  end

  message.add_receiver('game', function (cmd, ...) return game_message_commands[cmd](...) end)
end


function love.update (dt)
  for k,v in pairs(tasks) do
    v(dt)
  end
end

function love.keypressed (button)
  if button == "p" then
    if current_map then current_map:save_to_file(os.date "%Y-%m-%d_%H-%M-%S.vikingmap") end
  elseif button == "escape" then
    love.event.push("quit")
  elseif avatars.player.input_pressed then
    avatars.player:input_pressed(button)
  end
end

function love.keyreleased (button)
  if avatars.player.input_released then
    avatars.player:input_released(button)
  end
end

function love.joystickpressed(joystick, button)
  if avatars.player.input_pressed then
    avatars.player:input_pressed(button, joystick)
  end
end

function love.joystickreleased(joystick, button)
  if avatars.player.input_pressed then
    avatars.player:input_released(button, joystick)
  end
end

local function mousetotile ()
  local x,y       = love.mouse.getPosition()
  local tilesize  = map.get_tilesize()
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

function love.draw ()
  local bg_x = (avatars.player.pos.x / current_map.width)  * (w - background:getWidth() * 2)
  local bg_y = (avatars.player.pos.y / current_map.height) * (h - background:getHeight() * 2)
  love.graphics.draw(background, bg_x, bg_y, 0, 2, 2)

  love.graphics.translate((screencenter - avatars.player.pos * map.get_tilesize()):get())
  current_map:draw(love.graphics)
  for _,av in pairs(avatars) do
    av:draw(love.graphics)
  end
  hitbox.draw_all(love.graphics)

  if love.keyboard.isDown("tab") then
    love.graphics.translate((-(screencenter - avatars.player.pos * map.get_tilesize())):get())
    love.graphics.translate(20, 20)
    love.graphics.scale(0.1, 0.1)
    love.graphics.setColor(0, 0, 0, 127)
    love.graphics.rectangle('fill', 0, 0, current_map.width*map.get_tilesize(), current_map.height*map.get_tilesize())
    love.graphics.setColor(255, 255, 255, 127)
    current_map:draw(love.graphics)
    love.graphics.setColor(255, 0, 0, 127)
    love.graphics.circle('fill', avatars.player.pos.x * map.get_tilesize(), (avatars.player.pos.y - 1) * map.get_tilesize(), map.get_tilesize() / 2)
    love.graphics.setColor(255, 255, 255, 255)
  end
end

