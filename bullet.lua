local graphics, physics
do
  local _obj_0 = love
  graphics, physics = _obj_0.graphics, _obj_0.physics
end
local Bullet
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      self.time = self.time - dt
      local sx, sy = self.body:getLinearVelocity()
      sx, sy = -sx * 2, -sy * 2
      self.psystem:setLinearAcceleration(sx - 10, sy - 10, sx + 10, sy + 10)
      return self.psystem:update(dt)
    end,
    makeDead = function(self)
      self.time = 0.0
    end,
    isDead = function(self)
      return self.time <= 0.0
    end,
    draw = function(self)
      graphics.draw(self.psystem, self.body:getX(), self.body:getY())
      return graphics.draw(self.texture, self.body:getX(), self.body:getY(), 0, 1, 1, self.size / 2, self.size / 2)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, world, x, y, sx, sy, damage, texture, sparkle)
      self.texture = texture
      self.sparkle = sparkle
      local _
      self.size, _ = self.texture:getDimensions()
      self.time = self.__class.LIFE_TIME
      self.damage = damage
      self.body = physics.newBody(world, x, y, "dynamic")
      self.body:setLinearDamping(0.0)
      self.body:setLinearVelocity(sx, sy)
      self.body:setBullet(true)
      self.shape = physics.newCircleShape(self.size / 2)
      self.fixture = physics.newFixture(self.body, self.shape, 2)
      self.fixture:setGroupIndex(self.__class.PH_GROUP)
      self.psystem = graphics.newParticleSystem(self.sparkle, 32)
      self.psystem:setParticleLifetime(0.1, 1)
      self.psystem:setEmissionRate(30)
      self.psystem:setSizeVariation(1)
      self.psystem:setSizes(1.0, 1.1, 1.0, 0.5, 0.2)
      self.psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0)
      return self.psystem:setSpeed(20)
    end,
    __base = _base_0,
    __name = "Bullet"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.LIFE_TIME = 5
  self.PH_GROUP = -1
  Bullet = _class_0
end
local BulletOne
do
  local _class_0
  local _parent_0 = Bullet
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, world, x, y, sx, sy)
      return _class_0.__parent.__init(self, world, x, y, sx, sy, self.__class.damage, self.__class.texture, self.__class.sparkle)
    end,
    __base = _base_0,
    __name = "BulletOne",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.texture = nil
  self.sparkle = nil
  self.damage = 0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BulletOne = _class_0
end
return {
  Bullet = Bullet,
  BulletOne = BulletOne
}
