import graphics, physics from love

class Bullet
  LIFE_TIME: 5,

  new: (world, x, y, sx, sy, texture) =>
    @texture = texture
    @size, _ = texture\getDimensions!
    @body = physics.newBody world, x, y, "dynamic"
    @body\setLinearDamping 0.0
    @shape = physics.newCircleShape @size / 2
    @fixture = physics.newFixture @body, @shape, 2
    @time = @LIFE_TIME

  update: (dt) =>
    @time -= dt

  isDead: => @time <= 0.0

  draw: =>
    graphics.draw @texture, @body\getX!, @body\getY!, 0, 1, 1, @size / 2, @size / 2

{ :Bullet }