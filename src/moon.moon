import graphics, physics from love

class Moon
  @PH_GROUP: 1

  new: (assets, world, x, y) =>
    @tex = assets.tex.moon
    @body = physics.newBody world, x, y
    @radius, _ = @tex\getDimensions!
    @radius /= 2
    @shape = physics.newCircleShape @radius
    @fixture = physics.newFixture @body, @shape
    @fixture\setFriction 0.7
    @fixture\setGroupIndex @@PH_GROUP

  getPosition: => @body\getPosition!
  getX: => @body\getX!
  getY: => @body\getY!

  draw: =>
    graphics.draw @tex, @body\getX!, @body\getY!, @body\getAngle!, 1, 1, @radius, @radius

{ :Moon }