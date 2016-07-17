import graphics from love

class Explosion
  new: (ps, x, y, time) =>
    @ps = ps
    @x = x
    @y = y
    @time = time
    @lifetime = 0.0

  update: (dt) =>
    @lifetime += dt
    @ps\update dt

  isDead: =>
    @lifetime >= @time

  draw: =>
    graphics.draw @ps, @x, @y

  destroy: =>
    @ps\stop!

{ :Explosion }