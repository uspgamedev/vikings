
require 'vec2'
require 'map'
require 'avatar'
require 'builder'
require 'message'
require 'maploader'
require 'sound'
require 'hitbox'

local debug = false
local w,h
local screencenter
local background
local camera_pos
local tasks = {}
local avatars = {}
local current_map

local function change_map (player, map_file)
  hitbox.unregister()
  current_map, avatars = maploader.load(map_file, player, debug)
end

local game_message_commands = {
  add = function ( ... )
    for _,avatar in ipairs{...} do
      table.insert(avatars, avatar)
    end
  end,
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
  put = function (thing)
    table.insert(avatars, thing)
  end,
  position = function (thing_id)
    return avatars[thing_id] and avatars[thing_id].pos
  end,
  changemap = function ()
    change_map(avatars.player)
  end,
  debug = function ()
    return debug
  end
}

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

function love.load (args)
  sound.load(love.audio)
  w,h = love.graphics.getWidth(), love.graphics.getHeight()
  background = love.graphics.newImage "data/background/Ardentryst-Background_SnowCave_Backing.png"
  screencenter = vec2:new{w,h} * 0.5
  camera_pos = vec2:new{ w/2, h/2 }
  love.graphics.setFont(love.graphics.newFont(12))

  sound.set_bgm "data/music/JordanTrudgett-Snodom-ccby3.ogg"
  local map_file, no_joystick = parse_args(args)
  do 
    local player  = builder.build_thing("player", vec2:new{})
    local axe     = builder.build_thing("ironaxe",   vec2:new{}, {3,3}, {3,3})
    player:equip(axe.slot, axe)
    if love.joystick.getNumJoysticks() == 0 or no_joystick then
      builder.add_keyboard_input(player)
    else
      builder.add_joystick_input(player)
    end
    change_map(player, map_file)
  end
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

local function minimap_draw(graphics, map, things)
  local tilesize = map:get_tilesize()
  graphics.setColor(0, 0, 0, 127)
  graphics.rectangle('fill', 0, 0, map.width*tilesize, map.height*tilesize)
  graphics.setColor(255, 255, 255, 127)
  graphics.translate(-tilesize, -tilesize)
  for y,row in ipairs(map.tiles) do
    for x,tile in ipairs(row) do
      if tile:img(map) then
        graphics.rectangle('fill', x * tilesize, y * tilesize, tilesize, tilesize)
      end
    end
  end
  graphics.setColor(255, 0, 0, 127)
  for _,thing in pairs(things) do
    graphics.circle('fill', thing.pos.x * tilesize, thing.pos.y * tilesize, tilesize / 2)
  end
  graphics.translate(tilesize, tilesize)
end

function love.draw ()
  local bg_x = (avatars.player.pos.x / current_map.width)  * (w - background:getWidth() * 2)
  local bg_y = (avatars.player.pos.y / current_map.height) * (h - background:getHeight() * 2)
  love.graphics.draw(background, bg_x, bg_y, 0, 2, 2)

  love.graphics.push()
    local camera_pos = screencenter - avatars.player.pos * map.get_tilesize()
    love.graphics.translate(math.floor(camera_pos.x), math.floor(camera_pos.y))
    current_map:draw(love.graphics, avatars.player.pos, w, h)
    for _,av in pairs(avatars) do
      av:draw(love.graphics)
    end
    if debug then
      hitbox.draw_all(love.graphics)
    end
  love.graphics.pop()

  if love.keyboard.isDown("tab") or love.joystick.isDown(1, 5) then
    love.graphics.push()
      love.graphics.translate(20, 20)
      love.graphics.scale(0.1, 0.1)
      minimap_draw(love.graphics, current_map, debug and avatars or { avatars.player })
    love.graphics.pop()
    love.graphics.push()
      love.graphics.translate(20, 300)
      love.graphics.scale(2,2)
      love.graphics.setColor(150, 50, 50, 255)
      love.graphics.print("Equipment:", 0, 0)
      for slot,equip in pairs(avatars.player.equipment) do
        love.graphics.print("[slot "..slot.."] " .. equip:get_description(), 0, slot*20)
      end
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)
  end
end

