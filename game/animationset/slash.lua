
require 'game.animation'

module ('animationset', package.seeall)

slash = {}

slash.inactive = animation:new {}

slash.active = animation:new {
  fps     = 25,
  type    = 'once',
  frames  = {
    {i=1, j=1},
    {i=2, j=1},
    {i=3, j=1}
  }
}
