
module ('ui', package.seeall) do

  require 'lux.object'

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

end
