
module ('network', package.seeall) do

  require 'database'

  local http = require("socket.http")
  local servers = { "http://uspgamedev.org/downloads/projects/vikings/api/" }

  function fetch_all()
    for _, serverapi in pairs(servers) do
      local result = http.request(serverapi .. "maplist")

      local chunk, err = loadstring('return ' .. result)
      if chunk then
        setfenv(chunk, {})
        for _, map in pairs(chunk()) do
          database.add_map(map)
        end
      else
        print(result)
        error(err)
      end
    end
  end

end
