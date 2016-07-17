local graphics
graphics = love.graphics
local Explosion
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      self.lifetime = self.lifetime + dt
      return self.ps:update(dt)
    end,
    isDead = function(self)
      return self.lifetime >= self.time
    end,
    draw = function(self)
      return graphics.draw(self.ps, self.x, self.y)
    end,
    destroy = function(self)
      return self.ps:stop()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, ps, x, y, time)
      self.ps = ps
      self.x = x
      self.y = y
      self.time = time
      self.lifetime = 0.0
    end,
    __base = _base_0,
    __name = "Explosion"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Explosion = _class_0
end
return {
  Explosion = Explosion
}
