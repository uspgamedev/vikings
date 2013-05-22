
require 'game.animation'

module ('animationset', package.seeall)

monster = {}

monster.standing = animation:new {
  fps     = 1,
  type    = 'once',
  frames  = {
    {i=1, j=1}
  }
}

monster.moving = animation:new {
  fps     = 25,
  type    = 'loop',
  frames  = {
    {i=1, j=2},
    {i=1, j=3},
    {i=1, j=4},
    {i=1, j=5},
    {i=1, j=6},
    {i=1, j=7}
  }
}

monster.attacking = animation:new {
  fps     = 30,
  type    = 'once',
  frames  = {
    {i=2, j=1},
    {i=2, j=2},
    {i=2, j=3},
    {i=2, j=4},
    {i=2, j=5},
    {i=2, j=6},
    {i=2, j=7}
  }
}

monster.attacking.frames[3].event = function (observer)
  observer.slash:activate()
end

function monster.attacking.finishevent (observer)
  observer:stopattack()
end
