local cos, floor, min, pi, random, sin, sqrt
do
  local _obj_0 = math
  cos, floor, min, pi, random, sin, sqrt = _obj_0.cos, _obj_0.floor, _obj_0.min, _obj_0.pi, _obj_0.random, _obj_0.sin, _obj_0.sqrt
end
local BulletOne
BulletOne = require('bullet').BulletOne
local Weapon
do
  local _class_0
  local _base_0 = {
    hasAmmo = function(self)
      return self._ammo == nil or self._ammo > 0
    end,
    trigger = function(self, rx, ry, mx, my)
      self._trigger = true
      self._rx = rx
      self._ry = ry
      self._mx = mx
      self._my = my
    end,
    update = function(self, dt)
      local bullet = nil
      if not self._ready then
        self._uptime = self._uptime + dt
        if self._magazine > 0 then
          if self._uptime > self.trigger_time then
            self._uptime = self._uptime - self.trigger_time
            self._ready = true
            self._trigger = false
          end
        else
          if self:hasAmmo() then
            if self._uptime > self.reload_time then
              self._uptime = self._uptime - self.reload_time
              self._magazine = self.magazine
              if self._ammo ~= nil then
                self._ammo = self._ammo - self.magazine
              end
              self._ready = true
              self._trigger = false
            end
          end
        end
      else
        if self._trigger then
          if self._magazine > 0 then
            bullet = self:fire()
            self._magazine = self._magazine - 1
          end
          self._ready = false
          self._trigger = false
        end
      end
      return bullet
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, assets, world, size)
      self.assets = assets
      self.world = world
      self.safe_range = size
      self:initParams()
      self._magazine = self.magazine
      self._uptime = 0
      self._ready = true
      self._trigger = false
    end,
    __base = _base_0,
    __name = "Weapon"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Weapon = _class_0
end
local PlasmaOne
do
  local _class_0
  local _parent_0 = Weapon
  local _base_0 = {
    initParams = function(self)
      self.trigger_time = 0.06
      self.reload_time = 0.5
      self.magazine = 5
    end,
    fire = function(self)
      local dx, dy = self._mx - self._rx, self._my - self._ry
      local len = sqrt(dx * dx + dy * dy)
      dx = dx / len
      dy = dy / len
      return BulletOne(self.assets, self.world, self._rx + dx * self.safe_range, self._ry + dy * self.safe_range, dx, dy)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "PlasmaOne",
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PlasmaOne = _class_0
end
return {
  PlasmaOne = PlasmaOne
}
