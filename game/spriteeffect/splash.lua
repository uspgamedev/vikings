
require 'lux.object'
require 'vec2'

module ('spriteeffect', package.seeall)

splash = lux.object.new {
  color = { 255, 255, 255 }
}

local particle_img = nil
local function get_img ()
  if not particle_img then
    local img_data = love.image.newImageData(1,1)
    img_data:mapPixel(
      function ()
        return 255, 255, 255, 255
      end
    )
    particle_img = love.graphics.newImage(img_data)
  end
  return particle_img
end

function splash:__init ()
  local color = self.color
  self.particles = love.graphics.newParticleSystem(get_img(), 4)
  self.particles:setParticleLife(0.3, 0.3)
  self.particles:setEmissionRate(40)
  self.particles:setSizes(4)
  self.particles:setColors(color[1],color[2],color[3],255, color[1],color[2],color[3],0)
  self.particles:setSpread(2*math.pi)
  self.particles:setSpeed(128,128)
  self.particles:setGravity(400,400)
  self.particles:setSpin(-10*math.pi, -10*math.pi, 0)
  self.particles:start()
  self.totalcount = self.counter
end

function splash:update (sprite, dt)
  self.particles:update(dt)
end

function splash:draw (graphics, sprite)
  graphics.draw(self.particles)
end
