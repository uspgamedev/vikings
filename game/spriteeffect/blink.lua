
require 'lux.object'
require 'game.vec2'

module ('spriteeffect', package.seeall)

local pixeleffect_code = [[
  extern number intensity;
  extern vec3   blinkcolor;
  vec4 effect (vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords) {
    return vec4(
      blinkcolor.r, blinkcolor.g, blinkcolor.b,
      intensity*color.a*Texel(texture, tex_coords).a
    );
  }
]]

local function normalize_color (color)
  return { color[1]/255, color[2]/255, color[3]/255 }
end

blink = lux.object.new {
  color     = nil,
  counter   = 0.3
}

function blink:__init ()
  self.color = self.color or { 255, 255, 255 }
  self.totalcount = self.counter
  self.pixeleffect = love.graphics.newShader(pixeleffect_code)
  self.pixeleffect:send('intensity', 0)
  self.pixeleffect:send('blinkcolor', normalize_color(self.color))
end

function blink:update (sprite, dt)
  self.counter = self.counter - dt
  if self.counter <= 0 then
    return true
  end
  if self.counter >= self.totalcount/2 then
    self.pixeleffect:send('intensity', 1-(self.counter-self.totalcount/2)/(self.totalcount/2))
  else
    self.pixeleffect:send('intensity', (self.counter)/(self.totalcount/2))
  end
end

function blink:draw (graphics, sprite)
  graphics.setShader(self.pixeleffect)
  sprite:draw_data(graphics)
  graphics.setShader()
end
