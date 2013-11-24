
module ('network.node', package.seeall) do

  require 'etherclan.database'

  db = nil
  server = nil
  local routine
  local last_search
  local search_cooldown = 15.0


  local env = { }
  function env.error (msg, ...)
    return error(debug.traceback('\n'..msg, 2))
  end

  function init()
    db = etherclan.database.create()

    local func = assert(love.filesystem.load "network/node_thread.lua")
    setfenv(func, setmetatable(env, { __index = getfenv(0) }))
    routine = coroutine.create(func)
    
    server = select(2, assert(coroutine.resume(routine, db, "localhost")))
    last_search = love.timer.getTime()
  end

  function step()
    local search = (love.timer.getTime() - last_search)
    if search > search_cooldown then last_search = love.timer.getTime() end
    assert(coroutine.resume(routine, search > search_cooldown))
  end
end
