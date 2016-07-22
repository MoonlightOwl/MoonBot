import graphics, physics from love

class Garbage
  @PH_GROUP: 3

  new: (assets, world, x, y, angle) =>
    @texture = assets.tex.box
    @width, @height = @texture\getDimensions!
    @body = physics.newBody world, x, y, "dynamic"
    @body\setAngle angle
    @body\setLinearDamping 0.1
    @shape = physics.newRectangleShape 0, 0, @width, @height
    @fixture = physics.newFixture @body, @shape, 2
    @fixture\setFriction 0.4
    @fixture\setGroupIndex @@PH_GROUP

  draw: =>
    graphics.draw @texture, @body\getX!, @body\getY!,
      @body\getAngle!, 1, 1, @width / 2, @height / 2

{ :Garbage }