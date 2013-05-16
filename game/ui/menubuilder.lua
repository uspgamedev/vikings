
module ('ui', package.seeall) do

  require 'ui.menuscene'
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

  function multiplayermenu()
    function closemenu( ... )
      message.send [[main]] {'change_scene', nil}
    end
    return menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
      buttons = {
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
    function makemuiltiplayer_menu()
      message.send [[main]] {'change_scene', multiplayermenu(), true}
    end
    function quitgame()
      love.event.push("quit")
    end

    return menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
      buttons = {
        button:new{ text = "Play", onclick = startgame, themes = themes },
        button:new{ text = "Multiplayer", onclick = makemuiltiplayer_menu, themes = themes },
        button:new{ text = "Quit", onclick = quitgame, themes = themes },
      }
    }
  end
end
