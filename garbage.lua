local graphics, physics
do
  local _obj_0 = love
  graphics, physics = _obj_0.graphics, _obj_0.physics
end
local Garbage
do
  local _class_0
  local _base_0 = {
    hit = function(self, damage)
      self.life = self.life - damage
    end,
    isDamaged = function(self)
      return self.life < self.__class.MAX_LIFE / 2
    end,
    isDestroyed = function(self)
      return self.life <= 0
    end,
    draw = function(self)
      return graphics.draw(((function()
        if self:isDamaged() then
          return self.texture_damaged
        else
          return self.texture
        end
      end)()), self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, self.width / 2, self.height / 2)
    end,
    destroy = function(self)
      return self.body:destroy()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, assets, world, x, y, angle)
      self.life = self.__class.MAX_LIFE
      self.texture = assets.tex.box
      self.texture_damaged = assets.tex["box-damaged"]
      self.width, self.height = self.texture:getDimensions()
      self.body = physics.newBody(world, x, y, "dynamic")
      self.body:setAngle(angle)
      self.body:setLinearDamping(0.1)
      self.shape = physics.newRectangleShape(0, 0, self.width, self.height)
      self.fixture = physics.newFixture(self.body, self.shape, 2)
      self.fixture:setFriction(0.4)
      self.fixture:setGroupIndex(self.__class.PH_GROUP)
      return self.fixture:setUserData(self)
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
  self.MAX_LIFE = 3
  Garbage = _class_0
end
return {
  Garbage = Garbage
}
