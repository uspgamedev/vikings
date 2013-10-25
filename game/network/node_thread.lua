

require 'game.network.gamenet.gamenet'
require 'game.network.gamenet.database'

gamenet.add_node("????","127.0.0.1", 9001)

return gamenet.run()