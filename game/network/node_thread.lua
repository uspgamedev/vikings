require 'etherclan.server'

local db, hostname = ...
if hostname then
  db:add_node("??", hostname, 9001)
end

local serv = etherclan.server.create(db, 0.001, 9001)

function serv.node.services.vikings(self, msg)
  -- HAS_JOINABLE_GAME
  ---- NO
  ---- DADOS SOBRE O JOGO

  -- JOIN GAME

  local first, second = msg:match("^([^ ]+) (.*)$")
  first = first or msg

  if first == "HAS_JOINABLE_GAME" then
    self:send("NO")

  elseif first == "JOIN_GAME" then

  else
    print("oi?", msg)
  end
end

serv:start()
coroutine.yield(serv)
while true do
  local search = coroutine.yield()
  if search then
    serv:create_new_out_connections()
  end
  serv:step()
end
serv:close()
