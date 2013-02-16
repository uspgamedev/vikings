
require 'animation'

module ('animationset', package.seeall)

viking = {}

viking.standing = animation:new {
  fps     = 1,
  type    = 'once',
  frames  = {
    {i=2, j=1}
  }
}

viking.moving = animation:new {
  fps     = 25,
  type    = 'loop',
  frames  = {
    {i=2, j=2},
    {i=2, j=3},
    {i=2, j=4},
    {i=2, j=5},
    {i=2, j=6},
    {i=2, j=7},
    {i=2, j=8},
    {i=2, j=9}
  }
}

viking.dashing = animation:new {
  fps     = 25,
  type    = 'once',
  frames  = {
    {i=2, j=2},
    {i=2, j=3},
    {i=2, j=4},
    {i=2, j=5},
    {i=2, j=6}
  }
}

viking.attacking = animation:new {
  fps     = 25,
  type    = 'once',
  frames  = {
    {i=6, j=1},
    {i=6, j=2},
    {i=6, j=3},
    {i=6, j=4},
    {i=6, j=5},
    {i=6, j=6}
  }
}

viking.attacking.frames[5].event = function (observer)
  observer.slash:activate()
end

function viking.attacking.finishevent (observer)
  observer:stopattack()
end
