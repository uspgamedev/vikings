
module ('network.node', package.seeall) do

  require 'etherclan.database'

  local db = etherclan.database.create()
  local routine
  local last_search
  local search_cooldown = 15.0

  function init()
    routine = coroutine.create(love.filesystem.load "network/node_thread.lua")
    assert(coroutine.resume(routine, db))
    last_search = love.timer.getTime()
  end

  function step()
    local search = (love.timer.getTime() - last_search)
    if search > search_cooldown then last_search = love.timer.getTime() end
    assert(coroutine.resume(routine, search > search_cooldown))
  end
end
