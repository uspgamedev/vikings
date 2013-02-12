
require 'lux.object'
require 'vec2'

module ('spriteeffect', package.seeall)

local particle_img = nil

splash = lux.object.new {
  counter = 1
}

function splash:__init ()
  particle_img = particle_img or love.graphics.newImage 'tile/ice.png'
  self.particles = love.graphics.newParticleSystem(particle_img, 6)
  self.particles:setParticleLife(1, 1)
  self.particles:setEmissionRate(40)
  self.particles:setSizes(0.2)
  self.particles:setColors(255,255,255,255, 255,255,255,0)
  self.particles:setSpread(2*math.pi)
  self.particles:setSpeed(32,64)
  self.particles:setGravity(100,200)
  self.particles:setSpin(-10*math.pi, -10*math.pi, 0)
  self.particles:start()
end

function splash:update (sprite, dt)
  self.particles:update(dt)
end

function splash:draw (graphics, sprite)
  graphics.draw(self.particles)
end
