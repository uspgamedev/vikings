
module ('ui', package.seeall) do

  require 'ui.menuscene'
  require 'gamescene'

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
    function quitgame()
      love.event.push("quit")
    end

    return menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 20,
      buttons = {
        button:new{ text = "Play", onclick = startgame },
        button:new{ text = "Quit", onclick = quitgame },
      }
    }
  end
end
