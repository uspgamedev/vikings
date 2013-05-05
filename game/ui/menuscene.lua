
module ('ui', package.seeall) do

  require 'scene'
  require 'ui.button'
  require 'gamescene'
  require 'map.maploader'
  require 'message'
  require 'builder'

  menuscene = scene:new{
    xcenter = 400,
    ystart = 100,
    border = 20,

    buttons = nil,
    mousepos = nil,
  }

  function menuscene:__init()
    self.buttons = self.buttons or {}
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

end