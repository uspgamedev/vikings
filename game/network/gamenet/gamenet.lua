
module ('gamenet', package.seeall) do

  local socket = require("socket")
  local uuid4 = require("uuid4")

  require 'yieldsocket'

  local known_peers = {
    -- Bootstrap nodes! Currently we have none =(
  }

  local quit = false

  function count_peers()
    local resp = 0
    for _, _ in pairs(known_peers) do
      resp = resp + 1
    end
    return resp
  end


  function create_node()
    local sock = socket.tcp()
    sock:bind("*", 0)
    return {
      uuid = uuid4.getUUID(),
      socket = sock
    }
  end

  function add_peer(uuid, ip, port)
    print("== new client!", ip, port)
    known_peers[uuid] = { uuid = uuid, ip = ip, port = port }
  end

  local commands = {}
  function commands.announce_self(client, arguments)
    print "hai"
    local cli_ip = client:getpeername()
    local cli_uuid, cli_port = arguments:match("^([^ ]+) ([^ ]+)$")

    if not (cli_uuid and cli_port) then
      -- TODO: invalid input.
      print("invalid input! '" .. arguments .. "': " .. cli_uuid .. " --- " .. cli_port)
      return false
    end
    print "stuff"
    add_peer(cli_uuid, cli_ip, cli_port)
    return false
  end

  function commands.request_node_list(client)
    local size = count_peers()
    yieldsend(client, 'NODE_LIST ' .. size)

    for uuid, node in pairs(known_peers) do
      if node.ip and node.port then
        yieldsend(client, "NODE_INFO " .. uuid .. " " .. node.ip .. " " .. node.port)
      end
    end
    return false
  end

  function commands.request_known_protocols(client)
    yieldsend(client, 'KNOWN_PROTOCOLS ')
    return false
  end

  function run_command(client, command, arguments)
    print("command: '" .. command .. "'") 
    if not commands[command] then
      return false, "invalid command '" .. command .. "'"
    else
      return commands[command](client, arguments)
    end
  end

  function split_message(message)
    local first_split = message:find(" ", 1, true)
    local command = message:sub(1, (first_split or 0) - 1):lower()
    local arguments = first_split and message:sub(first_split + 1)
    return command, arguments
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