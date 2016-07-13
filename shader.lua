local concat, insert
do
  local _obj_0 = table
  concat, insert = _obj_0.concat, _obj_0.insert
end
local exp, floor, max
do
  local _obj_0 = math
  exp, floor, max = _obj_0.exp, _obj_0.floor, _obj_0.max
end
local graphics
graphics = love.graphics
local Shader
do
  local _class_0
  local _base_0 = {
    renderToCanvas = function(self, canvas, func, ...)
      local old_canvas = graphics.getCanvas()
      graphics.setCanvas(canvas)
      graphics.clear()
      func(...)
      return graphics.setCanvas(old_canvas)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Shader"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Shader = _class_0
end
local Blur
do
  local _class_0
  local _parent_0 = Shader
  local _base_0 = {
    build = function(self, sigma)
      local support = max(1, floor(3 * sigma + .5))
      local one_by_sigma_sq = sigma > 0 and 1 / (sigma) or 1
      local norm = 0
      local code = {
        "\n      extern vec2 direction;\n      vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)\n      { vec4 c = vec4(0.0f);\n    "
      }
      for i = -support, support do
        local coeff = exp(i * i * one_by_sigma_sq)
        norm = norm + coeff
        insert(code, "c += vec4(" .. tostring(coeff) .. ") * Texel(texture, tc + vec2(" .. tostring(i) .. ") * direction);")
      end
      insert(code, "return c * vec4(" .. tostring(norm > 0 and 1 / norm or 1) .. ") * color;}")
      return graphics.newShader(concat(code))
    end,
    draw = function(self, func, ...)
      local c = graphics.getCanvas()
      local s = graphics.getShader()
      local co = {
        graphics.getColor()
      }
      self:renderToCanvas(self.canvas_h, func, ...)
      graphics.setColor(co)
      graphics.setShader(self.shader)
      local b = graphics.getBlendMode()
      graphics.setBlendMode('alpha', 'premultiplied')
      self.shader:send('direction', {
        1 / graphics.getWidth(),
        0
      })
      self:renderToCanvas(self.canvas_v, graphics.draw, self.canvas_h, 0, 0)
      self.shader:send('direction', {
        0,
        1 / graphics.getHeight()
      })
      graphics.draw(self.canvas_v, 0, 0)
      graphics.setBlendMode(b)
      graphics.setShader(s)
      return graphics.setCanvas(c)
    end,
    set = function(key, value)
      if key == 'sigma' then
        self.shader = self:build(tonumber(sigma))
      else
        error("Unknown property: " .. tostring(tostring(value)))
      end
      return self
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      self.canvas_h, self.canvas_v = graphics.newCanvas(), graphics.newCanvas()
      self.shader = self:build(1)
      return self.shader:send("direction", {
        1.0,
        0.0
      })
    end,
    __base = _base_0,
    __name = "Blur",
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
  Blur = _class_0
end
return {
  Blur = Blur
}
