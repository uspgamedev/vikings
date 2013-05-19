
module ('network', package.seeall) do

  local http = require("socket.http")
  local servers = { "http://uspgamedev.org/downloads/projects/vikings/api/" }

  local function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
      if s ~= 1 or cap ~= "" then
    table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
    end
    return t
  end

  function fetch_all()
    local maps = {}
    for _, serverapi in pairs(servers) do
      local result = http.request(serverapi .. "maplist")

      local chunk, err = loadstring('return ' .. result)
      if chunk then
        setfenv(chunk, {})
        for _, map in pairs(chunk()) do
          table.insert(maps, map)
        end
      else
        print(result)
        error(err)
      end
    end
    return maps
  end

  function download_map(map)
    love.filesystem.mkdir "downloads"

    local result, status = http.request(map.url)
    local local_path = "downloads/" .. map.hash .. "-" .. map.name .. ".lua"

    local file = love.filesystem.newFile(local_path)
    file:open("w")
    file:write(result)
    file:close()

    return local_path
  end

end
