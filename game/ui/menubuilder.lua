
module ('ui', package.seeall) do

  require 'ui.menuscene'
  require 'network.maplist'
  require 'message'
  require 'gamescene'

  local themes = {
    default = theme:new {
      background_color = { 96, 96, 96 },
      border_color = { 160, 160, 160 },
      text_color = { 240, 240, 240 },
    },
    hover = theme:new {
      background_color = { 80, 80, 150 },
      border_color = { 160, 160, 255 },
      text_color = { 255, 255, 255 },
    },
    clicking = theme:new {
      background_color = { 40, 40, 98 },
      border_color = { 120, 120, 192 },
      text_color = { 255, 255, 255 },
    },
    selected = theme:new {
      background_color = { 96, 96, 110 },
      border_color = { 140, 140, 255 },
      text_color = { 240, 240, 240 },
    },
  }
  local function closemenu()
    message.send [[main]] {'change_scene', nil}
  end

  function maplistmenu()
    function load_map(map)
      local args = message.send [[main]] {'get_cliargs'}

      local newscene = gamescene:new {
        map = maploader.load(network.download_map(map), args.debug),
        music = "data/music/JordanTrudgett-Snodom-ccby3.ogg",
        background = love.graphics.newImage "data/background/Ardentryst-Background_SnowCave_Backing.png",
        players = { builder.build_thing("player", vec2:new{}, 
                    not args.no_joystick and love.joystick.getNumJoysticks() > 0 and 1) },
      }
      
      message.send [[main]] {'change_scene', newscene}
    end

    local maps = network.fetch_all()
    local menu = menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
    }

    for _, mappath in pairs(maps) do
      table.insert(menu.buttons, button:new {
        text = mappath,
        themes = themes,
        width = 500,
        height = 30,
        onclick = function() load_map(mappath) end
      })
    end

    table.insert(menu.buttons, { width = 100, height = 50 })
    table.insert(menu.buttons, button:new{ text = "Back", onclick = closemenu, themes = themes })

    menu:position_buttons()

    return menu
  end

  function internetmenu()
    function makemaplistmenu()
      message.send [[main]] {'change_scene', maplistmenu(), true}
    end
    return menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
      buttons = {
        button:new{ text = "Map List", onclick = makemaplistmenu, themes = themes },
        { width = 100, height = 50 },
        button:new{ text = "Back", onclick = closemenu, themes = themes },
      }
    }
  end

  function mainmenu()
    function startgame()
      local args = message.send [[main]] {'get_cliargs'}

      local newscene = gamescene:new {
        map = maploader.load(args.map_file, args.debug),
        music = "data/music/JordanTrudgett-Snodom-ccby3.ogg",
        background = love.graphics.newImage "data/background/Ardentryst-Background_SnowCave_Backing.png",
        players = { builder.build_thing("player", vec2:new{}, 
                    not args.no_joystick and love.joystick.getNumJoysticks() > 0 and 1) },
      }

      message.send [[main]] {'change_scene', newscene}
    end
    function makeinternetmenu()
      message.send [[main]] {'change_scene', internetmenu(), true}
    end

    return menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
      buttons = {
        button:new{ text = "Play", onclick = startgame, themes = themes },
        button:new{ text = "Internet", onclick = makeinternetmenu, themes = themes },
        button:new{ text = "Quit", onclick = closemenu, themes = themes },
      }
    }
  end
end
