
module ('ui', package.seeall) do

  require 'lux.object'

  theme = lux.object.new{
    border = 4,

    background_color = nil,
    border_color = nil,
    text_color = nil,
  }

  theme.__init = {
    background_color = { 64, 64, 64 },
    border_color = { 192, 192, 192 },
    text_color = { 255, 255, 255 },
  }

  button = lux.object.new{
    height = 50,
    width  = 300,
    position = nil,
    themes = nil,
    default_theme = nil,
    hover_theme = nil,
    clicking_theme = nil,

    text = "Dummy Button",
    onclick = function (self, mousepos) end,
  }

  button.__init = {
    position = vec2:new{},

    themes = {
      default = theme:new{}
    }
  }

  function button:inside(querypos)
    return self.position.x <= querypos.x and querypos.x <= self.position.x + self.width and
           self.position.y <= querypos.y and querypos.y <= self.position.y + self.height
  end

  function button:get_theme(status)
    return self.themes[status] or self.themes.default
  end

  function button:draw(graphics, status)
    local x, y = self.position:get()
    local theme = self:get_theme(status)
    status = status or 'normal'
    graphics.setColor(unpack(theme.border_color))
    graphics.rectangle('fill', x, y, self.width, self.height)
    graphics.setColor(unpack(theme.background_color))
    graphics.rectangle('fill', x + theme.border, 
                               y + theme.border, 
                               self.width - theme.border * 2,
                               self.height - theme.border * 2)
    graphics.setColor(unpack(theme.text_color))
    local fontheight = graphics.getFont() and graphics.getFont():getHeight() or 10
    graphics.printf(self.text, x, y + (self.height - fontheight) * 0.5, self.width, 'center')
  end

end
