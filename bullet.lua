local graphics, physics
do
  local _obj_0 = love
  graphics, physics = _obj_0.graphics, _obj_0.physics
end
local Bullet
do
  local _class_0
  local _base_0 = {
    LIFE_TIME = 5,
    update = function(self, dt)
      self.time = self.time - dt
    end,
    isDead = function(self)
      return self.time <= 0.0
    end,
    draw = function(self)
      return graphics.draw(self.texture, self.body:getX(), self.body:getY(), 0, 1, 1, self.size / 2, self.size / 2)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, world, x, y, sx, sy, texture)
      self.texture = texture
      local _
      self.size, _ = texture:getDimensions()
      self.body = physics.newBody(world, x, y, "dynamic")
      self.body:setLinearDamping(0.0)
      self.shape = physics.newCircleShape(self.size / 2)
      self.fixture = physics.newFixture(self.body, self.shape, 2)
      self.time = self.LIFE_TIME
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
  Bullet = _class_0
end
return {
  Bullet = Bullet
}
