
local socket = require("socket")

local known_peers = {
  -- Bootstrap nodes! Currently we have none =(
  { ip = "localhost", port = 12345 }
}

local quit = false

local commands = {}
function commands.inform_client(client, arguments)
  return 'OK!'
end
function commands.request_clients(client, arguments)
  return 'DENIED'
end

function split_message(message)
  local first_split = message:find(":", 1, true)
  local command = message:sub(1, (first_split or 0) - 1):lower()
  local arguments = first_split and message:sub(first_split + 1)
  return command, arguments
end

function run_command(client, command, arguments)
  if not commands[command] then
    return nil, "invalid command '" .. command .. "'"
  else
    return commands[command](client, arguments)
  end
end

function handle_client(client)
  local cli_ip, cli_port = client:getpeername()
  local cli_name = "[" .. cli_ip .. "]:" .. cli_port
  print("New connection from " .. cli_name)

  repeat
    local data = client:receive()
    if data == nil or data == '' then
      break
    end

    print("{" .. cli_name .. "} Received message: '" .. data .. "'")
    local response, err = run_command(client, split_message(data))
    if response == nil then
      print("{" .. cli_name .. "} Error: " .. err)
      response = "ERROR: " .. err
    end
    client:send(response)
  until false
  client:close()
end

function main()
  local server = socket.tcp()
  server:bind("*", 0)

  local ip, port = server:getsockname()
  print("Listening on ip '" .. ip .. "' port '" .. port .. "'")

  server:listen()

  repeat
    -- Receive a client
    local client = server:accept()

    -- Handle this new client (in this threat or in another)
    handle_client(client)  
  until (quit == true)

  server:close()

  print "Quit networking!"
end


return main()