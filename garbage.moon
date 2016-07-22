import graphics, physics from love

class Garbage
  @PH_GROUP: 3
  @MAX_LIFE: 3

  new: (assets, world, x, y, angle) =>
    @life = @@MAX_LIFE
    @texture = assets.tex.box
    @texture_damaged = assets.tex["box-damaged"]
    @width, @height = @texture\getDimensions!
    @body = physics.newBody world, x, y, "dynamic"
    @body\setAngle angle
    @body\setLinearDamping 0.1
    @shape = physics.newRectangleShape 0, 0, @width, @height
    @fixture = physics.newFixture @body, @shape, 2
    @fixture\setFriction 0.4
    @fixture\setGroupIndex @@PH_GROUP

  hit: (damage) =>
    @life -= damage

  isDamaged: =>
    @life < @@MAX_LIFE / 2

  isDestroyed: =>
    @life <= 0

  draw: =>
    graphics.draw (if @isDamaged! then @texture_damaged else @texture), @body\getX!, @body\getY!,
      @body\getAngle!, 1, 1, @width / 2, @height / 2

{ :Garbage }