
module ('ui', package.seeall) do

  require 'ui.menuscene'
  require 'ui.characterlist'
  require 'network.maplist'
  require 'game.message'
  require 'game.gamescene'
  require 'database'

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

      database.fetch_content(map)

      local player = builder.thing "player"
      if args.joystick and love.joystick.getNumJoysticks() > 0 then
        builder.add_joystick_input(player, 1)
      else
        builder.add_keyboard_input(player)
      end

      local newscene = gamescene:new {
        map = maploader.load(map.file_path, args.debug),
        music = "data/music/JordanTrudgett-Snodom-ccby3.ogg",
        background = love.graphics.newImage "data/background/Ardentryst-Background_SnowCave_Backing.png",
        players = { player },
      }
      
      message.send [[main]] {'change_scene', newscene}
    end

    network.fetch_all()
    local maps = database.get_all_maps()
    local menu = menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
    }

    -- Add a button for each map
    for _, map in pairs(maps) do
      table.insert(menu.buttons, button:new {
        text = map.name,
        themes = themes,
        width = 500,
        height = 30,
        onclick = function() load_map(map) end
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
    function makecharselectmenu()
      message.send [[main]] {'change_scene', charselectmenu(themes), true}
    end
    function makeinternetmenu()
      message.send [[main]] {'change_scene', internetmenu(), true}
    end

    local extra_button
    local args = message.send [[main]] {'get_cliargs'}
    if args.map_file then
      extra_button = button:new{ text = "CLI Map Instaplay", themes = themes, 
        onclick = function()
          local player = builder.thing "player"
          builder.add_keyboard_input(player)

          message.send [[main]] {'change_scene', 
            gamescene:new {
              map = maploader.load(args.map_file, args.debug),
              players = { player },
            }
          }
        end
      }
    end

    return menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
      buttons = {
        button:new{ text = "Play", onclick = makecharselectmenu, themes = themes },
        button:new{ text = "Internet", onclick = makeinternetmenu, themes = themes },
        button:new{ text = "Quit", onclick = closemenu, themes = themes },
        extra_button
      }
    }
  end
end
