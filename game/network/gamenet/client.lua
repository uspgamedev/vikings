
module ('gamenet', package.seeall) do

  local socket = require("socket")

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

  function client.create(client_sock)
    local newclient = {
      socket = client_sock,
      routine = coroutine.create(client.routine_logic)
    }
    setmetatable(newclient, client)

    return newclient
  end

  function client:continue()
    coroutine.resume(self.routine, self)
    if coroutine.status(self.routine) == 'dead' then
      self:finish()
    end
  end

  function client:finish()
    if self.server then
      self.server:remove_client(self)
    end
  end

  function client:routine_logic()
    -- TODO: body
  end
end