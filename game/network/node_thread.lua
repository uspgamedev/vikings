
local socket = require("socket")

local known_peers = {
  -- Bootstrap nodes! Currently we have none =(
  { ip = "localhost", port = 12345 }
}

local quit = false

local commands = {}
function commands.inform_client(client, arguments)
  client:send('OK!')
  return false
end
function commands.request_clients(client, arguments)
  client:send('DENIED')
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
  local print = function(...) print("{" .. cli_name .. "}", ...) end

  print("New connection")
  client:settimeout(0)

  local quit = false
  repeat
    while not socket.select({client}, nil, 0.01)[client] do
      coroutine.yield()
    end
    local data, err = client:receive()
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

function main()
  local server = socket.tcp()
  server:bind("*", 0)

  local ip, port = server:getsockname()
  print("Listening on ip '" .. ip .. "' port '" .. port .. "'")

  server:listen()
  server:settimeout(0)

  local connected_clients = {}

  repeat
    -- Receive all clients
    repeat
      local client = server:accept()
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

  server:close()

  print "Quit networking!"
end


return main()