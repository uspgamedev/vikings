
local socket = require("socket")

local known_peers = {
  -- Bootstrap nodes! Currently we have none =(
  { "localhost", 12345 }
}

local quit = false

function handle_client(message, ip, port)
  return "OK!"
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
    server:sendto(handle_client(data, cli_ip, cli_port), cli_ip, cli_port)
  
  until (quit == true)

  server:close()

  print "Quit networking!"
end


return main()