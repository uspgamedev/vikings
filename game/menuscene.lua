require 'scene'

menuscene = scene:new {
}

function menuscene:__init()
end

function menuscene:update(dt)
end

function menuscene:input_pressed(...)
end

function menuscene:input_released(...)
end

function menuscene:draw(graphics)
  graphics.rectangle('fill', 50,  50, 400, 30)
  graphics.rectangle('fill', 50, 100, 400, 30)
end
