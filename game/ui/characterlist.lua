
module ('ui', package.seeall) do

  require 'ui.menuscene'
  require 'network.maplist'
  require 'game.message'
  require 'game.gamescene'

  characterbutton = button:new{
    text = "",
    height = 70,
    character = nil
  }

  function characterbutton:draw(graphics, status)
    characterbutton:__super().draw(self, graphics, status)

    if status then
      self.character.sprite:play_animation(self.character.animationset.moving)
    else
      self.character.sprite:play_animation(self.character.animationset.standing)
    end
    graphics.setColor(unpack(self.character.color))
    self.character.sprite:draw(graphics, (self.position + vec2:new{70, 70}) * 1/(graphics.get_tilesize()))
  end

  function characterbutton:update(dt)
    self.character.sprite:update(nil, dt)
  end

  local function closemenu()
    message.send [[main]] {'change_scene', nil}
  end

  function charselectmenu(themes)
    function startgame(button)
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

    local characters = {
      builder.build_thing("player"),
      builder.build_thing("player"),
    }

    local buttons = {}
    for _, char in ipairs(characters) do
      char.sprite:set_mirror(true, false)
      table.insert(buttons, characterbutton:new{ character = char, onclick = startgame, themes = themes })
    end
    table.insert(buttons, button:new{ text = "New Random Character", onclick = startgame, themes = themes })
    table.insert(buttons, { width = 100, height = 50 })
    table.insert(buttons, button:new{ text = "Back", onclick = closemenu, themes = themes })

    return menuscene:new {
      xcenter = love.graphics.getWidth() / 2,
      ystart = 100,
      border = 10,
      buttons = buttons,
    }
  end

end
