
module ('gamenet', package.seeall) do

  local socket = require("socket")

  require 'client'

  server = {
    -- class methods
    create = nil,

    -- methods
    step = nil,
    start = nil,
    add_client = nil,
    remove_client = nil,

    -- attributes
    sock = nil,
    clients_socks = nil,
    connected_clients = nil,
    timeout = nil,
    port = 0,
  }
  server.__index = server

  function server.create(timeout, port)
    local newserver = { 
      timeout = timeout and timeout * 0.5 or nil,
      port = port or 0,

      clients_socks = {},
      connected_clients = {},
    }
    setmetatable(newserver, server)

    return newserver
  end

  function server:start()
    self.sock = socket.tcp()
    if not self.sock:bind("*", self.port) then
      self.sock = socket.tcp()
      assert(self.sock:bind("*", 0))
    end
    self.sock:settimeout(self.timeout, 't')
    self.sock:listen(3)
    self.ip, self.port = self.sock:getsockname()

    self:debug_message("Server Start with timeout " .. self.timeout)
  end

  function server:step()
    self:debug_message "Accept"

    local client_sock = self.sock:accept()
    if client_sock then
      self:add_client(client.create(client_sock))
    end

    self:debug_message("Select")
    local read = socket.select(self.clients_socks, nil, self.timeout)
    for _, sock in ipairs(read) do
      self.connected_clients[sock]:continue()
    end
  end

  function server:close()
    self.sock:close()
  end

  function server:add_client(client)
    self:debug_message "Add Client"

    table.insert(self.clients_socks, client.socket)
    self.connected_clients[client.socket] = client
    client.server = self
  end

  function server:remove_client(client)
    self:debug_message "Remove Client"

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

  function server:debug_message(str)
    print("[Server @ " .. self.ip .. " -- " .. self.port .. "] " .. str)
  end
end