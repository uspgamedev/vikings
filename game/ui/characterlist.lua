
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

    local theme = self:get_theme(status)
    local x, y  = self.position:get()
    if status then
      self.character.sprite:play_animation(self.character.animationset.moving)
    else
      self.character.sprite:play_animation(self.character.animationset.standing)
    end
    graphics.setColor(unpack(self.character.color))
    self.character.sprite:draw(graphics, (self.position + vec2:new{70, 70}) * 1/(graphics.get_tilesize()))

    graphics.setColor(unpack(theme.text_color))
    graphics.print(self.character.name, x + 80, y + 12)

    for i, equip in pairs(self.character.equipment) do
      graphics.setColor(255, 255, 255)
      equip.sprite:draw(graphics, (self.position + vec2:new{40 + 72*i, 77}) * 1/(graphics.get_tilesize()))

      graphics.setColor(unpack(theme.text_color))
      if equip.damage then
        graphics.print("D: " .. equip.damage, x + 27 + 72*i, y + 33)
      elseif equip.armor then
        graphics.print("A: " .. equip.armor, x + 27 + 72*i, y + 33)
      end
      graphics.print("W: " .. equip.weight, x + 25 + 72*i, y + 47)
    end
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

      local player = button.character or builder.build_thing("player")
      if not args.no_joystick and love.joystick.getNumJoysticks() > 0 then
        builder.add_joystick_input(player, 1)
      else
        builder.add_keyboard_input(player)
      end

      local newscene = gamescene:new {
        map = maploader.load("data/city.vikingmap", args.debug),
        players = { player },
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
