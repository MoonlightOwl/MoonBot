local graphics, physics
do
  local _obj_0 = love
  graphics, physics = _obj_0.graphics, _obj_0.physics
end
local Garbage
do
  local _class_0
  local _base_0 = {
    draw = function(self)
      return graphics.draw(self.texture, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, self.width / 2, self.height / 2)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, world, x, y, texture, angle)
      self.width, self.height = texture:getDimensions()
      self.texture = texture
      self.body = physics.newBody(world, x, y, "dynamic")
      self.body:setAngle(angle)
      self.body:setLinearDamping(0.1)
      self.shape = physics.newRectangleShape(0, 0, self.width, self.height)
      self.fixture = physics.newFixture(self.body, self.shape, 2)
      self.fixture:setFriction(0.4)
      return self.fixture:setGroupIndex(self.__class.PH_GROUP)
    end,
    __base = _base_0,
    __name = "Garbage"
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
  self.PH_GROUP = 3
  Garbage = _class_0
end
return {
  Garbage = Garbage
}
