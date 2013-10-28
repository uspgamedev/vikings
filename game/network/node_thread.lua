require 'etherclan.database'
require 'etherclan.server'

local serv = etherclan.server.create(nil, 1, 9001)
serv:start()
while true do
  serv:step()
end
serv:close()
