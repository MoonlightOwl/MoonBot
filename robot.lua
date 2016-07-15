local graphics, physics
do
  local _obj_0 = love
  graphics, physics = _obj_0.graphics, _obj_0.physics
end
local cos, pi, sin
do
  local _obj_0 = math
  cos, pi, sin = _obj_0.cos, _obj_0.pi, _obj_0.sin
end
local Robot
do
  local _class_0
  local _base_0 = {
    getPosition = function(self)
      return self.body:getPosition()
    end,
    getX = function(self)
      return self.body:getX()
    end,
    getY = function(self)
      return self.body:getY()
    end,
    moveLeft = function(self, force)
      local angle = self.angle - pi
      return self.body:applyForce(cos(angle) * force, sin(angle) * force)
    end,
    moveRight = function(self, force)
      return self.body:applyForce(cos(self.angle) * force, sin(self.angle) * force)
    end,
    update = function(self, dt, moon)
      local dx = self:getX() - moon:getX()
      local dy = self:getY() - moon:getY()
      self.angle = math.atan2(dy, dx) + pi / 2
    end,
    draw = function(self)
      return graphics.draw(self.tex, self.body:getX(), self.body:getY(), self.angle, 1, 1, self.width / 2, self.height / 2)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, world, x, y, tex)
      self.body = physics.newBody(world, x, y, "dynamic")
      self.body:setLinearDamping(1.0)
      self.height, self.width = tex:getDimensions()
      self.shape = physics.newCircleShape(self.width / 2 + 2)
      self.fixture = physics.newFixture(self.body, self.shape)
      self.fixture:setFriction(1.0)
      self.angle = 0.0
      self.tex = tex
    end,
    __base = _base_0,
    __name = "Robot"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Robot = _class_0
end
return {
  Robot = Robot
}