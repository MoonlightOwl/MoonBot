local graphics
graphics = love.graphics
local View
do
  local _class_0
  local _base_0 = {
    setVisibility = function(self, visible)
      self.visible = visible
      return self
    end,
    show = function(self)
      self.visible = true
      return self
    end,
    hide = function(self)
      self.visible = false
      return self
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.visible = true
    end,
    __base = _base_0,
    __name = "View"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  View = _class_0
end
local Splash
do
  local _class_0
  local _parent_0 = View
  local _base_0 = {
    draw = function(self)
      if self.visible then
        graphics.setColor(255, 255, 255)
        graphics.draw(self.back, WIDTH / 2, HEIGHT / 2, 0, 1, 1, self.off.x, self.off.y)
        graphics.setColor(self.color)
        graphics.setFont(self.font)
        return graphics.print(self.text, WIDTH / 2 - self.font:getWidth(self.text) / 2, HEIGHT / 2 - self.font:getHeight() / 2)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, assets, text, color)
      _class_0.__parent.__init(self)
      self.text = text
      self.back = assets.tex.splash
      self.font = assets.font.splash
      self.color = color
      self.off = { }
      local x, y = self.back:getDimensions()
      self.off.x = x / 2
      self.off.y = y / 2
    end,
    __base = _base_0,
    __name = "Splash",
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
  Splash = _class_0
end
return {
  View = View,
  Splash = Splash
}
