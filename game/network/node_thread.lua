
local socket = require("socket")

local known_peers = {
  -- Bootstrap nodes! Currently we have none =(
  "localhost:12345"
}

local quit = false

local commands = {}
function commands.inform_client(sender, arguments)
  return 'OK!'
end
function commands.request_clients(sender, arguments)
  return 'DENIED'
end

function handle_client(message, sender, port)
  local first_split = message:find(":", 1, true)
  local command = message:sub(1, (first_split or 0) - 1):lower()
  local arguments = first_split and message:sub(first_split + 1)

  if not commands[command] then
    return ("Network warning: Received invalid command '" .. command .. "' from " .. sender.ip .. ":" .. sender.port)
  else
    return commands[command](sender, arguments)
  end
end

function main()
  local server = socket.udp()
  server:setsockname("*", 0)

  local ip, port = server:getsockname()
  print("Listening on ip '" .. ip .. "' port '" .. port .. "'")

  repeat
    -- wait for a message from any client
    local data, cli_ip, cli_port = server:receivefrom()

    print("Received message: '" .. data .. "' from '" .. cli_ip .. ":" .. cli_port)
    server:sendto(handle_client(data, { ip = cli_ip, port = cli_port }), cli_ip, cli_port)
  
  until (quit == true)

  server:close()

  print "Quit networking!"
end


return main()