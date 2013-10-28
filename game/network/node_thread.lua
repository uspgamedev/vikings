require 'etherclan.database'
require 'etherclan.server'

local db = etherclan.database.create()
if arg[1] then
  db:add_node{ uuid = "??", ip = arg[1], port = 9001 }
end

local serv = etherclan.server.create(db, 1, 9001)
serv:start()
while true do
  serv:step()
end
serv:close()
