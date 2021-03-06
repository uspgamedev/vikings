
module ('database', package.seeall) do

  local http = require("socket.http")
  require 'dump'

  local maps

  function add_map(map)
    if maps[map.hash] then
      -- TODO: do I have to do something?
    else
      maps[map.hash] = map
    end
  end

  function get_map(map_or_hash)
    return maps[map_or_hash.hash or map_or_hash]
  end

  function fetch_content(map)
    if map.file_path ~= nil then return end

    local contents, status = http.request(map.url)

    love.filesystem.createDirectory "downloads"
    map.file_path = "downloads/" .. map.hash
    local file = love.filesystem.newFile(map.file_path)
    file:open("w")
    file:write(contents)
    file:close()
  end

  function get_all_maps()
    return maps
  end

  function save()
    love.filesystem.createDirectory "saves"
    local file = love.filesystem.newFile "saves/database.lua"
    file:open("w")
    file:write('return ' .. dump{
      maps = maps
    })
    file:close()
  end

  function init()
    maps = {}

    local load_ok, chunk = pcall(love.filesystem.load, "saves/database.lua")
    if load_ok and chunk then
      setfenv(chunk, {})
      local run_ok, result = pcall(chunk)
      if run_ok then
        maps = result.maps or {}
      end
    end
  end

end
