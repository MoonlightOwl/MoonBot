import graphics, physics from love
import pi from math

class Bullet
  @LIFE_TIME: 5,
  @PH_GROUP: -1,

  new: (world, x, y, sx, sy, damage, texture, trail, sparkle) =>
    -- Init fields
    @texture = texture
    @trail = trail
    @sparkle = sparkle
    @size, _ = @texture\getDimensions!
    @time = @@LIFE_TIME
    @damage = damage
    -- Generate physical body
    @body = physics.newBody world, x, y, "dynamic"
    @body\setLinearDamping 0.0
    @body\setLinearVelocity sx, sy
    @body\setBullet true
    @shape = physics.newCircleShape @size / 4
    @fixture = physics.newFixture @body, @shape, 6
    @fixture\setGroupIndex @@PH_GROUP
    -- Create bullet fx
    @ps_bullet = graphics.newParticleSystem @trail, 32
    @ps_bullet\setParticleLifetime 0.1, 1
    @ps_bullet\setEmissionRate 30
    @ps_bullet\setSizeVariation 1
    @ps_bullet\setSizes 1.0, 1.1, 1.0, 0.5, 0.2
    @ps_bullet\setColors 255, 255, 255, 255,  255, 255, 255, 0 -- fade to transparency

  explosion: =>
    ps = graphics.newParticleSystem @sparkle, 32
    ps\setParticleLifetime 0.1, 0.5
    ps\setEmissionRate 60
    ps\setSizeVariation 1
    ps\setSizes 1.0, 2.0, 0.5, 0.2
    ps\setColors 255, 255, 100, 255,  255, 255, 255, 255,  255, 255, 255, 0
    ps\setLinearAcceleration -60, -60, 60, 60
    ps\setSpin -pi, pi
    ps\setSpinVariation 0.5
    ps

  update: (dt) =>
    @time -= dt

    sx, sy = @body\getLinearVelocity!
    sx, sy = -sx * 2, -sy * 2
    @ps_bullet\setLinearAcceleration sx-10, sy-10, sx+10, sy+10
    @ps_bullet\update dt

  makeDead: => @time = 0.0
  isDead: => @time <= 0.0

  getX: => @body\getX!
  getY: => @body\getY!
  getPosition: => @body\getPosition!

  draw: =>
    graphics.draw @ps_bullet, @body\getX!, @body\getY!
    graphics.draw @texture, @body\getX!, @body\getY!, 0, 1, 1, @size / 2, @size / 2

  destroy: =>
    @body\destroy!
    @ps_bullet\stop!


class BulletOne extends Bullet
  @texture: nil
  @trail: nil
  @sparkle: nil
  @damage: 0

  new: (world, x, y, sx, sy) =>
    super world, x, y, sx, sy, @@damage, @@texture, @@trail, @@sparkle

{ :Bullet, :BulletOne }