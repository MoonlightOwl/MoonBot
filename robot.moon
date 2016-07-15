import graphics, physics from love

class Robot
  new: (world, x, y, tex) =>
    @body = physics.newBody world, x, y, "dynamic"
    @body\setLinearDamping 1.0
    @height, @width = tex\getDimensions!
    @shape = physics.newCircleShape @width / 2 + 2
    @fixture = physics.newFixture @body, @shape
    @fixture\setFriction 1.0
    @angle = 0.0
    @tex = tex

  getPosition: => @body\getPosition!
  getX: => @body\getX!
  getY: => @body\getY!

  update: (dt, moon) =>
    dx = @getX! - moon\getX!
    dy = @getY! - moon\getY!
    @angle = math.atan2(dy, dx) + math.pi / 2

  draw: =>
    graphics.draw @tex, @body\getX!, @body\getY!, @angle, 1, 1, @width/2, @height/2

{ :Robot }