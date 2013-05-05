require 'scene'
require 'lux.object'
require 'gamescene'
require 'map.maploader'
require 'message'
require 'builder'

button = lux.object.new{
  height = 50,
  width  = 300,
  border = 4,
  background_color = nil,
  border_color = nil,
  position = nil,

  text = "Dummy Button",
  onclick = function (self, mousepos) end,
}

button.__init = {
  position = vec2:new{},
  background_color = { 64, 64, 64 },
  border_color = { 192, 192, 192 },
  text_color = { 255, 255, 255 },
}

function button:inside(querypos)
  return self.position.x <= querypos.x and querypos.x <= self.position.x + self.width and
         self.position.y <= querypos.y and querypos.y <= self.position.y + self.height
end

function button:adaptcolor(color, status)
  if status == 'hover' then
    return (color[1] < 200) and (color[1] + 15) or (color[1] - 15), 
           (color[2] < 200) and (color[2] + 15) or (color[2] - 15), 
           (color[3] < 200) and (color[3] + 15) or (color[3] - 15)
  elseif status == 'clicking' then
    return (color[1] < 200) and (color[1] + 30) or (color[1] - 30), 
           (color[2] < 200) and (color[2] + 30) or (color[2] - 30), 
           (color[3] < 200) and (color[3] + 30) or (color[3] - 30)
  else
    return unpack(color)
  end
end

function button:draw(graphics, status)
  local x, y = self.position:get()
  status = status or 'normal'
  graphics.setColor(self:adaptcolor(self.border_color, status))
  graphics.rectangle('fill', x, y, self.width, self.height)
  graphics.setColor(self:adaptcolor(self.background_color, status))
  graphics.rectangle('fill', x + self.border, 
                             y + self.border, 
                             self.width - self.border * 2,
                             self.height - self.border * 2)
  graphics.setColor(self:adaptcolor(self.text_color, status))
  local fontheight = graphics.getFont() and graphics.getFont():getHeight() or 10
  graphics.printf(self.text, x, y + (self.height - fontheight) * 0.5, self.width, 'center')
end

function startgame()
  local args = message.send [[main]] {'get_cliargs'}

  local newscene = gamescene:new {
    map = maploader.load(args.map_file, args.debug),
    music = "data/music/JordanTrudgett-Snodom-ccby3.ogg",
    background = love.graphics.newImage "data/background/Ardentryst-Background_SnowCave_Backing.png",
    players = { builder.build_thing("player", vec2:new{}, 
                not args.no_joystick and love.joystick.getNumJoysticks() > 0 and 1) },
  }

  message.send [[main]] {'change_scene', newscene}
end

menuscene = scene:new{
  xcenter = 400,
  ystart = 100,
  border = 20,

  buttons = nil,
  mousepos = nil,
}

function menuscene:__init()
  self.buttons = self.buttons or {
    button:new{ text = "Play", onclick = function (self, mousepos) startgame() end },
    button:new{},
    button:new{},
  }
  self:position_buttons()
end

function menuscene:position_buttons()
  local y = self.ystart
  for _, button in ipairs(self.buttons) do
    button.position = vec2:new{self.xcenter - button.width * 0.5, y}
    y = y + button.height + self.border
  end
end

function menuscene:update(dt)
end

function menuscene:input_pressed(button, joystick, mouse)
  for _, button in ipairs(self.buttons) do
    if button:inside(mouse, vec2:new{x,y}) then
      self.clicking = button
      break
    end
  end
end

function menuscene:input_released(button, joystick, mouse)
  if self.clicking and self.clicking:inside(mouse) then
    self.clicking:onclick(mouse)
  end
  self.clicking = nil
end

function menuscene:draw(graphics)
  for _, button in ipairs(self.buttons) do
    local isinside = button:inside(vec2:new{love.mouse.getPosition()})
    button:draw(graphics, (button == self.clicking and 'clicking') or (isinside and 'hover'))
  end
end
