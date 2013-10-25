
module ('gamenet', package.seeall) do

  local uuid4 = require("uuid4")

  require 'database'
  require 'server'

  function handle_remote(remote_data)
    local remote_ip, remote_port = unpack(remote_data)
    local remote_name = "[" .. remote_ip .. "]:" .. remote_port
    local print = function(...) print("{REM - " .. remote_name .. "}", ...) end

    local remote = socket.tcp()
    remote:settimeout(0)

    remote:connect(remote_ip, remote_port)
    print("New connection")
    yieldsend(remote, "ANNOUNCE_SELF "..(select(2, thisserver:getsockname())))
    print("announced!")

    local data, err = yieldreceive(remote)
    print("Server sent " .. data)

    print("Requesting clients.")
    yieldsend(remote, "request_clients")
    while true do
      local newpeer = yieldreceive(remote)
      if newpeer == '' then
        print("Server sent linebreak, we are done.")
        break
      end
      local ip, port = newpeer:match("^(%S+) (%d+)$")
      if not ip then
        print("Server sent invalid client string: '" .. newpeer .. "'")
      else
        add_peer(ip, port)
      end
    end

    print("Closing connection")
    remote:close()
  end

  function remote_processing_func()
    local remote_socks = {}
    for uuid, node in pairs(known_nodes) do
      if node.ip and node.port then
        local s = socket.tcp()
        s:connect(node.ip, node.port)
        table.insert(remote_socks, s)
      end
    end
    while true do
      local can_read, can_write = socket.select(remote_socks, remote_socks, 0.1)
      for _, remote in ipairs(can_write) do

      end
      coroutine.yield()
    end
  end

  function run()
    local serv = server.create(1, 9001)
    remote_processing = coroutine.create(remote_processing_func)
    serv:start()
    while true do
      serv:step()
      coroutine.resume(remote_processing)
    end
    serv:close()
  end
end