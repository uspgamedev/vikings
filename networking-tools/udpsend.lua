local socket = require 'socket'

local target = arg[1] or "localhost"
local port = arg[2] or "1024"
local str = arg[3] or "DUMMY STRING"

local u = socket.udp()
u:settimeout(60)
local success, errorstr = u:setpeername(target, port)

if success == nil then
  print('Error 1:', errorstr)
  return 1
end

local success, errorstr = u:send(str)
if success == nil then
  print('Error 2:', errorstr)
  return 1
end

local resp, errorstr = u:receive()
if resp == nil then
  print('Error 3:', errorstr)
  return 1
end

print("Received:", resp)