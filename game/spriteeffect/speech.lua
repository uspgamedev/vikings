
require 'lux.object'
require 'vec2'

module ('spriteeffect', package.seeall)

speech = lux.object.new{
  pos     = nil,
  text    = "",
  counter = 2
}

speech.__init = {
  pos = vec2:new{}
}

function speech:update (dt)
  self.counter = self.counter - dt
  if self.counter <= 0 then
    return true
  end
end

function speech:draw (graphics)
  graphics.setColor(255, 255, 255, math.min(self.counter, 1) * 255)
  graphics.print(
    self.text, 
    map.get_tilesize() * (self.pos.x - 0.5),
    map.get_tilesize() * (self.pos.y - 2)
  )
  graphics.setColor(255, 255, 255, 255)
end
