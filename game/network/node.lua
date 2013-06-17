
module ('network.node', package.seeall) do

  local thread
  function init_background()
    thread = love.thread.newThread("network.node", "network/node_thread.lua")
    thread:start()
  end

  function init_foreground()
    local chunk = love.filesystem.load "network/node_thread.lua"
    return chunk()
  end

  -- Throws an error if there's any error.
  function check_error()
    local err = thread:get 'error'
    if err then
      error(err)
    end
  end

end
