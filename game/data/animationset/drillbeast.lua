
require 'game.animation'

module ('animationset', package.seeall)

drillbeast = {}

drillbeast.standing = animation:new {
  fps     = 1,
  type    = 'once',
  frames  = {
    {i=1, j=1}
  }
}

drillbeast.moving = animation:new {
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

drillbeast.attacking = animation:new {
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

drillbeast.attacking.frames[3].event = function (observer)
  observer.slash:activate()
end

function drillbeast.attacking.finishevent (observer)
  observer:stopattack()
end
