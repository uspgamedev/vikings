
module ('gamenet', package.seeall) do

  local socket = require("socket")
  require('commands')

  client = {
    -- class methods
    create = nil,

    -- methods
    continue = nil,
    finish = nil,
    routine_logic = nil,

    -- attributes
    socket = nil,
    routine = nil,
    server = nil,
  }
  client.__index = client

  function client.create(client_sock)
    local newclient = {
      socket = client_sock,
      routine = coroutine.create(client.routine_logic)
    }
    newclient.ip, newclient.port = client_sock:getpeername()
    setmetatable(newclient, client)

    return newclient
  end

  function client:continue()
    self:debug_message "Continue"
    assert(coroutine.resume(self.routine, self))
    if coroutine.status(self.routine) == 'dead' then
      self:finish()
    end
  end

  function client:finish()
    self:debug_message "Finish"
    self.socket:close()
    if self.server then
      self.server:remove_client(self)
    end
  end

  function client:routine_logic()
    local message = self:receive()
    run_command(self, message)
  end

  function client:send(msg)
    self:debug_message("Sending: '" .. msg .. "'")
    self.socket:send(msg .. '\n')
  end

  function client:receive()
    return self.socket:receive()
  end

  function client:debug_message(str)
    print("[Client @ " .. self.ip .. " -- " .. self.port .. "] " .. str)
  end
end