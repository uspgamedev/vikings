
require 'lux.object'
require 'vec2'

module ('spriteeffect', package.seeall)

local pixeleffect == [[
  extern number intensity;
  extern vec3   blinkcolor;
  vec4 effect (vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords) {
    return vec4(blinkcolor, intensity*color.a*texture.a);
  }
]]

blink = lux.object.new {
  color     = nil,
  counter   = 2
}

blink.__init = {
  color = { 255, 255, 255, 255}
}

function blink:update (sprite, dt)
  self.counter = self.counter - dt
  if self.counter <= 0 then
    return true
  end
end

function blink:draw (graphics, sprite)
  sprite:draw_data(graphics)
end
