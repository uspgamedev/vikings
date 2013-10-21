
module ('gamenet', package.seeall) do

  local socket = require("socket")

  require 'client'

  server = {
    -- class methods
    create = nil,

    -- methods
    step = nil,
    add_client = nil,
    remove_client = nil,

    -- attributes
    socket = nil,
    clients_socks = nil,
    connected_clients = nil,
  }

  function server.create(timeout)
    local newserver = {}
    setmetatable(newserver, server)

    newserver.sock = socket.tcp()
    newserver.sock:bind("*", 0)
    newserver.sock:settimeout(timeout)
    return newserver
  end

  function server:step()
    local client_sock = self.sock:accept()
    if client_sock then
      self:add_client(client.create(client_sock))
    end

    local read = socket.select(self.clients_socks, nil, timeout)
    for _, sock in ipairs(read) do
      self.connected_clients[sock]:continue()
    end
  end

  function server:add_client(client)
    table.insert(self.clients_socks, client.socket)
    self.connected_clients[client.socket] = client
    client.server = self
  end

  function server:remove_client(client)
    assert(client.server == self)
    client.server = nil
    for i, sock in ipairs(self.clients_socks) do
      if sock == client.socket then
        table.remove(self.clients_socks, i)
        break
      end
    end
    self.connected_clients[client.socket] = nil
  end
end