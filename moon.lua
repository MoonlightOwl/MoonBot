local graphics, physics
do
  local _obj_0 = love
  graphics, physics = _obj_0.graphics, _obj_0.physics
end
local Moon
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
    draw = function(self)
      return graphics.draw(self.tex, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, self.radius, self.radius)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, world, x, y, tex)
      self.tex = tex
      self.body = physics.newBody(world, x, y)
      local _
      self.radius, _ = tex:getDimensions()
      self.radius = self.radius / 2
      self.shape = physics.newCircleShape(self.radius)
      self.fixture = physics.newFixture(self.body, self.shape)
      return self.fixture:setFriction(0.7)
    end,
    __base = _base_0,
    __name = "Moon"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Moon = _class_0
end
return {
  Moon = Moon
}
