
module ('gamenet', package.seeall) do

  local socket = require("socket")

  function yieldreceive(client)
    while not socket.select({client}, nil, 0.01)[client] do
      coroutine.yield()
    end
    return client:receive()
  end

  function yieldsend(client, data)
    while not select(2, socket.select(nil, {client}, 0.01))[client] do
      coroutine.yield()
    end
    return client:send(data .. '\n')
  end

end