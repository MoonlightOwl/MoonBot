import graphics, physics from love

class Bullet
  @LIFE_TIME: 5,
  @PH_GROUP: -1,

  new: (world, x, y, sx, sy, damage, texture, sparkle) =>
    -- Init fields
    @texture = texture
    @sparkle = sparkle
    @size, _ = @texture\getDimensions!
    @time = @@LIFE_TIME
    @damage = damage
    -- Generate physical body
    @body = physics.newBody world, x, y, "dynamic"
    @body\setLinearDamping 0.0
    @body\setLinearVelocity sx, sy
    @body\setBullet true
    @shape = physics.newCircleShape @size / 2
    @fixture = physics.newFixture @body, @shape, 2
    @fixture\setGroupIndex @@PH_GROUP
    -- Create particle system
    @psystem = graphics.newParticleSystem @sparkle, 32
    @psystem\setParticleLifetime 0.1, 1
    @psystem\setEmissionRate 30
    @psystem\setSizeVariation 1
    @psystem\setSizes 1.0, 1.1, 1.0, 0.5, 0.2
    @psystem\setColors 255, 255, 255, 255,  255, 255, 255, 0 -- fade to transparency.
    @psystem\setSpeed 20

  update: (dt) =>
    @time -= dt

    sx, sy = @body\getLinearVelocity!
    sx, sy = -sx * 2, -sy * 2
    @psystem\setLinearAcceleration sx-10, sy-10, sx+10, sy+10
    @psystem\update dt

  makeDead: => @time = 0.0
  isDead: => @time <= 0.0

  draw: =>
    graphics.draw @psystem, @body\getX!, @body\getY!
    graphics.draw @texture, @body\getX!, @body\getY!, 0, 1, 1, @size / 2, @size / 2

class BulletOne extends Bullet
  @texture: nil
  @sparkle: nil
  @damage: 0

  new: (world, x, y, sx, sy) =>
    super world, x, y, sx, sy, @@damage, @@texture, @@sparkle

{ :Bullet, :BulletOne }