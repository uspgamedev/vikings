
local socket = require("socket")

local known_peers = {
  -- Bootstrap nodes! Currently we have none =(
  { "localhost", 12345 }
}

function main()
  local server = assert(socket.bind("*", 0))
  local ip, port = server:getsockname()
  print("Please telnet to localhost on port " .. port)
  for i = 1,5 do
    -- wait for a connection from any client
    local client = server:accept()

    print "WE GOT SOMEONE"

    -- make sure we don't block waiting for this client's line
    client:settimeout(10)
    -- receive the line
    local line, err = client:receive()
    -- if there was no error, send it back to the client
    if not err then 
      client:send(line .. "\n")
      print(line)
    end
    -- done with client, close the object
    client:close()
  end
end


return main()