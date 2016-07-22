local graphics
graphics = love.graphics
local Assets
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.tex = setmetatable({ }, {
        __index = function(tex, name)
          if not Assets.images[name] then
            Assets.images[name] = graphics.newImage("images/" .. tostring(name) .. ".png")
          end
          return Assets.images[name]
        end
      })
      self.font = {
        basic = graphics.newFont('fonts/Anonymous Pro Minus.ttf', 28),
        splash = graphics.newFont('fonts/Anonymous Pro Minus.ttf', 66)
      }
    end,
    __base = _base_0,
    __name = "Assets"
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
  self.images = { }
  Assets = _class_0
end
return {
  Assets = Assets
}
