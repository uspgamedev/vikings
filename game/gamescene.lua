
require 'lux.object'

require 'hitbox'
require 'map.maploader'

gamescene = lux.object.new {
  map = nil,
  background = nil,

  tasks = nil,
  players = nil,
  camera_pos = nil,

  things = nil, -- This field is overwritten by change_map, which is called even with the first map.
  
  message_handlers = {}, -- Shared by all gamescenes
}

function gamescene:__init()
  self.players = self.players or {}

  self.tasks   = self.tasks   or {}
  self.tasks.check_collisions = hitbox.check_collisions
  self.tasks.updatethings = function (dt)
    for _,av in pairs(self.things) do 
      av:update(dt, self.map)
    end
  end
  self.camera_pos = vec2:new{0, 0}

  self:change_map(self.map)
end

function gamescene.message_handlers.add(self, ...)
  for _,thing in ipairs{...} do
    self:add_thing(thing)
  end
end
gamescene.message_handlers.put = gamescene.message_handlers.add

function gamescene.message_handlers.kill(self, thing)
  thing:die()
  self:remove_thing(thing)
end

function gamescene.message_handlers.position(self, thing_type, thing_id)
  thing_type = thing_type or 'player'
  thing_id   = thing_id   or 1

  local thing = self:get_thing(thing_type, thing_id)
  return thing and thing.pos
end

function gamescene.message_handlers.changemap(self, map_file)
  self:change_map(maploader.load(map_file))
end

function gamescene:handle_message(cmd, ...)
  if not self.message_handlers[cmd] then
    error("Unknown command: " .. cmd)
  end
  return self.message_handlers[cmd](self, ...)
end

function gamescene:get_thing(thing_type, thing_id)
  local check_table
  if thing_type == 'thing' then
    check_table = self.things
  elseif thing_type == 'player' then
    check_table = self.players
  else
    error "Unknown thing type."
  end
  return check_table[thing_id]
end

function gamescene:remove_thing(thing)
  for i, check in ipairs(self.things) do
    if thing == check then
      table.remove(self.things, i)
      break
    end
  end
  for i, check in ipairs(self.players) do
    if thing == check then
      table.remove(self.players, i)
      break
    end
  end
end

function gamescene:add_thing(thing)
  table.insert(self.things, thing)
end

function gamescene:add_player(player, id)
  id = id or (#self.players + 1)
  self:add_thing(player)
  self.players[id] = player
  if self.map then
    player.pos:set(self.map.locations.playerstart)
  end
end

function gamescene:change_map(map)
  hitbox.unregister()
  self.map = map
  self.things = maploader.create_things(map)
  for id, player in ipairs(self.players) do
    self:add_player(player, id)
  end
  self.camera_pos:set(self.map.locations.playerstart)
end

function gamescene:update(dt)
  for _,task in pairs(self.tasks) do
    task(dt)
  end
end

function gamescene:input_pressed(...)
  for _, player in ipairs(self.players) do
    player:input_pressed(...)
  end
end

function gamescene:input_released(...)
  for _, player in ipairs(self.players) do
    player:input_released(...)
  end
end

local function minimap_draw(graphics, map, things)
  local tilesize = graphics:get_tilesize()
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

function gamescene:draw(graphics)
  if self.players[1] then
    self.camera_pos = self.players[1].pos:clone()
  end

  -- Drawing the background
  if self.map and self.background then
    local bg_x = (self.camera_pos.x / self.map.width)  * (graphics.getWidth()  - self.background:getWidth() * 2)
    local bg_y = (self.camera_pos.y / self.map.height) * (graphics.getHeight() - self.background:getHeight() * 2)
    graphics.draw(self.background, bg_x, bg_y, 0, 2, 2)
  end

  -- Drawing the map
  graphics.push()
    local screen_position = graphics:get_screensize() * 0.5 - self.camera_pos * graphics:get_tilesize()
    graphics.translate(math.floor(screen_position.x), math.floor(screen_position.y))
    self.map:draw(graphics, self.players[1] and self.players[1].pos)
    for _,thing in pairs(self.things) do
      thing:draw(graphics)
    end
  graphics.pop()

  -- Drawing the hud
  if love.keyboard.isDown("tab") or love.joystick.isDown(1, 5) then
    -- Drawing the minimap
    graphics.push()
      graphics.translate(20, 20)
      graphics.scale(0.1, 0.1)
      minimap_draw(graphics, self.map, self.things)
    graphics.pop()
    -- Drawing the inventory
    if self.players[1] then
      graphics.push()
      graphics.translate(20, 300)
      graphics.scale(2,2)
      graphics.setColor(150, 50, 50, 255)
      graphics.print("Equipment:", 0, 0)
      for slot,equip in pairs(self.players[1].equipment) do
        graphics.print("[slot "..slot.."] " .. equip:get_description(), 0, slot*20)
      end
      graphics.pop()
    end
    graphics.setColor(255, 255, 255, 255)
  end
end
