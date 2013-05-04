
require 'lux.object'

scene = lux.object.new {
}

function scene:update(dt)
end

-- When changing to this scene
function scene:focus()
end

-- When changing from this scene
function scene:unfocus()
end

function scene:input_pressed(...)
end

function scene:input_released(...)
end

function scene:draw(graphics)
end
