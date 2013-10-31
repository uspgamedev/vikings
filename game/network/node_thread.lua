require 'etherclan.server'

local db, hostname = ...
if hostname then
  db:add_node{ uuid = "??", ip = hostname, port = 9001 }
end

local serv = etherclan.server.create(db, 0.001, 9001)
serv:start()
while true do
  local search = coroutine.yield()
  if search then
    serv:create_new_out_connections()
  end
  serv:step()
end
serv:close()
