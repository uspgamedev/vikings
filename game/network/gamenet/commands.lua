module ('gamenet', package.seeall) do

  local socket = require("socket")
  local uuid4 = require("uuid4")

  function split_first(s)
    local head, tail = s:match("^([^ ]+) (.*)$")
    if not head then
      return s
    end
    return head, tail
  end

  function split(s)
    if not s then return nil end
    local head, tail = split_first(s)
    if not tail then
      return head
    else
      return head, split(tail)
    end
  end

  commands = {}
  function commands.announce_self(client, cli_uuid, cli_port)
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

  function run_command(client, message)
    local command_name, arguments = split_first(message)
    -- body
  end
end