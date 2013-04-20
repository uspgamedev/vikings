
require 'lux.object'

require 'hitbox'
require 'map.maploader'

gamescene = lux.object.new {
  map = nil,
  background = nil,

  tasks = nil,
  message_handlers = {},
  players = nil,

  things = nil, -- This field is overwritten by change_map, which is called even with the first map.
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

  self:change_map(self.map)
end

function gamescene.message_handlers.add(self, ...)
  for _,thing in ipairs{...} do
    table.insert(self.things, thing)
  end
end

function gamescene.message_handlers.kill(self, thing)
  for i,check in ipairs(self.things) do
    if thing == check then
      thing:die()
      table.remove(self.things, i)
    end
  end
end

function gamescene.message_handlers.put(self, thing)
  table.insert(self.things, thing)
end

function gamescene.message_handlers.position(self, thing_type, thing_id)
  thing_type = thing_type or 'player'
  thing_id   = thing_id   or 1

  local check_table
  if thing_type == 'thing' then
    check_table = self.things
  elseif thing_type == 'player' then
    check_table = self.players
  else
    error "Unknown thing type."
  end
  return check_table[thing_id] and check_table[thing_id].pos
end

function gamescene.message_handlers.changemap(self, map_file)
  self:change_map(map_file)
end

function gamescene:handle_message(cmd, ...)
  if not self.message_handlers[cmd] then
    error("Unknown command: " .. cmd)
  end
  return self.message_handlers[cmd](self, ...)
end

function gamescene:add_thing(thing)
  table.insert(self.things, thing)
end

function gamescene:add_player(player, id)
  id = id or (#self.players + 1)
  self:add_thing(player)
  self.players[id] = player
  if self.map then
    player.pos:set(unpack(self.map.locations.playerstart))
  end
end

function gamescene:change_map(map)
  self.map = map
  self.things = maploader.create_things(map)
  for id, player in ipairs(self.players) do
    self:add_player(player, id)
  end
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

function gamescene:draw(graphics)

  -- Drawing the map
  graphics.push()
    local camera_pos = vec2:new{graphics.getWidth(), graphics.getHeight()} * 0.5
    if self.players[1] then
      camera_pos = camera_pos - self.players[1].pos * graphics:get_tilesize()
    end
    graphics.translate(math.floor(camera_pos.x), math.floor(camera_pos.y))
    self.map:draw(graphics, self.players[1] and self.players[1].pos)
    for _,thing in pairs(self.things) do
      thing:draw(graphics)
    end
  graphics.pop()
end
