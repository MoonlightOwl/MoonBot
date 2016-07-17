import graphics, physics from love
import cos, pi, sin from math

class Robot
  @PH_GROUP: 2

  new: (world, x, y, tex) =>
    @initialX = x
    @initialY = y
    @body = physics.newBody world, x, y, "dynamic"
    @body\setLinearDamping 1.0
    @height, @width = tex\getDimensions!
    @shape = physics.newCircleShape @width / 2 + 2
    @fixture = physics.newFixture @body, @shape
    @fixture\setFriction 1.0
    @fixture\setGroupIndex @@PH_GROUP
    @angle = 0.0
    @tex = tex

  getPosition: => @body\getPosition!
  getX: => @body\getX!
  getY: => @body\getY!

  moveLeft: (force) => @thrust force, @angle - pi
  moveRight: (force) => @thrust force, @angle
  jump: (force) => @thrust force, @angle - pi/2

  thrust: (force, angle) =>
    @body\applyForce cos(angle) * force, sin(angle) * force

  reset: =>
    @body\setPosition @initialX, @initialY
    @body\setLinearVelocity 0, 0
    @body\setInertia 0


  update: (dt, moon) =>
    dx = @getX! - moon\getX!
    dy = @getY! - moon\getY!
    @angle = math.atan2(dy, dx) + pi / 2

  draw: =>
    graphics.draw @tex, @body\getX!, @body\getY!, @angle, 1, 1, @width/2, @height/2

{ :Robot }