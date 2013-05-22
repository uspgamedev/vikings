module ('ui', package.seeall) do

  require 'game.scene'
  require 'ui.button'
  require 'game.gamescene'
  require 'map.maploader'
  require 'game.message'
  require 'game.builder'

  menuscene = scene:new{
    xcenter = 400,
    ystart = 100,
    border = 20,

    buttons = nil,
    selected_button = 1,
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

  function menuscene:input_pressed(key, joystick, mouse)
    if mouse then
      for id, button in ipairs(self.buttons) do
        if button.inside and button:inside(mouse) then
          self.selected_button = id
          self.clicking = button
          break
        end
      end
    else
      if #self.buttons > 0 then
        if key == 'down' then
          repeat
            self.selected_button = (self.selected_button % #self.buttons) + 1
          until self.buttons[self.selected_button].onclick ~= nil
        elseif key == 'up' then
          repeat
            self.selected_button = self.selected_button - 1
            if self.selected_button < 1 then self.selected_button = self.selected_button + #self.buttons end
          until self.buttons[self.selected_button].onclick ~= nil
        elseif key == 'return' then
          local button = self.buttons[self.selected_button]
          if button then button:onclick() end
        end
      end
    end
  end

  function menuscene:input_released(button, joystick, mouse)
    if mouse then
      if self.clicking and self.clicking:inside(mouse) then
        self.clicking:onclick(mouse)
      end
      self.clicking = nil
    end
  end

  function menuscene:draw(graphics)
    for id, button in ipairs(self.buttons) do
      if button.draw then
        if button.inside and button:inside(vec2:new{love.mouse.getPosition()}) then
          button:draw(graphics, button == self.clicking and 'clicking' or 'hover')
        else
          button:draw(graphics, id == self.selected_button and 'selected')
        end
      end
    end
  end

end
