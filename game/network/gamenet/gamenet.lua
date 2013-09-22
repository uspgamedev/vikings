
module ('gamenet', package.seeall) do

  local socket = require("socket")

  local known_peers = {
    -- Bootstrap nodes! Currently we have none =(
  }

  local quit = false

  function is_peer_known(ip, port)
    return known_peers[ip] and known_peers[ip][tostring(port)]
  end

  function add_peer(ip, port)
    print("== new client!", ip, port)
    known_peers[ip] = known_peers[ip] or {}
    known_peers[ip][tostring(port)] = true
  end

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

  local commands = {}
  function commands.announce_self(client, arguments)
    local cli_ip = client:getpeername()
    local cli_port = arguments
    if is_peer_known(cli_ip, cli_port) then
      yieldsend(client, 'KNOWN')
    else
      yieldsend(client, 'WELCOME')
      add_peer(cli_ip, cli_port)
    end
    return false
  end
  function commands.request_clients(client, arguments)
    for ip, ports in pairs(known_peers) do
      for port, data in pairs(ports) do
        if data then
          yieldsend(client, ip .. ' ' .. port)
        end
      end
    end
    yieldsend(client, '')
    return true
  end

  function split_message(message)
    local first_split = message:find(":", 1, true)
    local command = message:sub(1, (first_split or 0) - 1):lower()
    local arguments = first_split and message:sub(first_split + 1)
    return command, arguments
  end

  function run_command(client, command, arguments)
    if not commands[command] then
      return false, "invalid command '" .. command .. "'"
    else
      return commands[command](client, arguments)
    end
  end


  function handle_client(client)
    local cli_ip, cli_port = client:getpeername()
    local cli_name = "[" .. cli_ip .. "]:" .. cli_port
    local print = function(...) print("{CLI - " .. cli_name .. "}", ...) end

    print("New connection")
    client:settimeout(0)

    local quit = false
    repeat
      local data, err = yieldreceive(client)
      if err == 'closed' then
        print("Aborting connection:", data, err)
        break
      end

      print("Received message: '" .. data .. "'")
      quit, err = run_command(client, split_message(data))
      if err ~= nil then
        print("Error: " .. err)
        client:send("ERROR: " .. err)
      end
    until quit

    print("Closing connection")
    client:close()
  end

  function handle_remote(remote_data)
    local remote_ip, remote_port = unpack(remote_data)
    local remote_name = "[" .. remote_ip .. "]:" .. remote_port
    local print = function(...) print("{REM - " .. remote_name .. "}", ...) end

    local remote = socket.tcp()
    remote:settimeout(0)

    remote:connect(remote_ip, remote_port)
    print("New connection")
    yieldsend(remote, "announce_self:"..(select(2, thisserver:getsockname())))
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

  function run()
    thisserver = socket.tcp()
    thisserver:bind("*", 0)

    local ip, port = thisserver:getsockname()
    print("Listening on ip '" .. ip .. "' port '" .. port .. "'")

    thisserver:listen()
    thisserver:settimeout(0)

    local connected_clients = {}

    for ip, ports in pairs(known_peers) do
      for port, _ in pairs(ports) do
        connected_clients[{ip, port}] = coroutine.create(handle_remote)
      end
    end

    repeat
      -- Receive all clients
      repeat
        local client = thisserver:accept()
        if client then
          connected_clients[client] = coroutine.create(handle_client)
        end
      until client == nil

      for client, routine in pairs(connected_clients) do
        coroutine.resume(routine, client)
        if coroutine.status(routine) == 'dead' then
          connected_clients[client] = nil
        end
      end

      quit = false
    until (quit == true)

    thisserver:close()

    print "Quit networking!"
  end
end