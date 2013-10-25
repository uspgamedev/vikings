module ('gamenet', package.seeall) do

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
    local cli_ip = client.ip
    if (cli_ip and cli_uuid and cli_port) then
      add_node{ uuid = cli_uuid, ip = cli_ip, port = cli_port}
    else
      self:debug_message("invalid input! '" .. arguments .. "': " .. cli_uuid .. " --- " .. cli_port)
    end
  end

  function commands.request_node_list(client)
    for uuid, node in pairs(known_peers) do
      if node.ip and node.port then
        client:send("NODE_INFO " .. uuid .. " " .. node.ip .. " " .. node.port)
      end
    end
  end

  function commands.request_known_services(client)
    client:send('KNOWN_SERVICES ')
  end

  function invalid_command(client, command)
    client:debug_message("Invalid command: '" .. command .. "'")
  end

  function make_invalid_command_callback(command)
    return function(client, ...) return invalid_command(client, command, ...) end
  end

  function run_command(client, message)
    local command_name, arguments = split_first(message)
    command_name = command_name:lower()
    local callback = commands[command_name] or make_invalid_command_callback(command_name)
    callback(client, split(arguments))
  end
end