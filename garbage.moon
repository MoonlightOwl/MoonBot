import graphics, physics from love

class Garbage
  new: (world, x, y, texture, angle) =>
    @width, @height = texture\getDimensions!
    @texture = texture
    @body = physics.newBody world, x, y, "dynamic"
    @body\setAngle angle
    @body\setLinearDamping 0.1
    @shape = physics.newRectangleShape 0, 0, @width, @height
    @fixture = physics.newFixture @body, @shape, 2
    @fixture\setFriction 0.4

  draw: =>
    graphics.draw @texture, @body\getX!, @body\getY!,
      @body\getAngle!, 1, 1, @width / 2, @height / 2

{ :Garbage }