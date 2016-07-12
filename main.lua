local insert
insert = table.insert
local graphics, physics, window
do
  local _obj_0 = love
  graphics, physics, window = _obj_0.graphics, _obj_0.physics, _obj_0.window
end
local START, GAME, PAUSE, GAMEOVER = 1, 2, 3, 4
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
        graphics.draw(self.back, WIDTH / 2, HEIGTH / 2, 0, 1, 1, self.off.x, self.off.y)
        graphics.setColor(self.color)
        graphics.setFont(self.font)
        return graphics.print(self.text, WIDTH / 2 - self.font:getWidth(self.text) / 2, HEIGTH / 2 - self.font:getHeight() / 2)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, text, color, back, font)
      _class_0.__parent.__init(self)
      self.text = text
      self.back = back
      self.font = font
      self.color = color
      self.off = { }
      local x, y = back:getDimensions()
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
      self.shape = physics.newRectangleShape(0, 0, self.width, self.height)
      self.fixture = physics.newFixture(self.body, self.shape, 1)
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
  Garbage = _class_0
end
local setStage
setStage = function(state, stage)
  state.stage = stage
  local _exp_0 = stage
  if START == _exp_0 then
    state.time = "00:00"
    state.contam = 0
  elseif GAME == _exp_0 then
    state.time_start = os.time()
  end
  return state
end
love.load = function()
  state = { }
  WIDTH, HEIGTH = window.getMode()
  RADIUS = 100
  tex = {
    back = graphics.newImage('images/back.png'),
    moon = graphics.newImage('images/moon.png'),
    box = graphics.newImage('images/box.png'),
    robot = graphics.newImage('images/robot.png'),
    splash = graphics.newImage('images/splash.png')
  }
  font = {
    basic = graphics.newFont('fonts/Anonymous Pro Minus.ttf', 26),
    splash = graphics.newFont('fonts/Anonymous Pro Minus B.ttf', 68)
  }
  back = graphics.newQuad(0, 0, WIDTH, HEIGTH, WIDTH, HEIGTH)
  splash = {
    go = Splash("CONTAMINATED", {
      255,
      71,
      71
    }, tex.splash, font.splash)
  }
  physics.setMeter(64)
  world = physics.newWorld(0, 0, true)
  objects = { }
  objects.moon = { }
  objects.moon.body = physics.newBody(world, WIDTH / 2, HEIGTH / 2)
  objects.moon.shape = physics.newCircleShape(RADIUS)
  objects.moon.fixture = physics.newFixture(objects.moon.body, objects.moon.shape)
  objects.garbage = { }
  insert(objects.garbage, Garbage(world, 200, 200, tex.box, 10))
  insert(objects.garbage, Garbage(world, 120, 120, tex.box, 45))
  return setStage(state, START)
end
love.update = function(dt)
  if state.stage == GAME then
    return world:update(dt)
  end
end
love.keypressed = function(key, scancode, isrepeat)
  local _exp_0 = state.stage
  if START == _exp_0 then
    if key == "return" then
      return setStage(state, GAME)
    end
  elseif GAME == _exp_0 then
    if key == "escape" then
      return setStage(state, START)
    end
  end
end
love.draw = function()
  graphics.setColor(255, 255, 255)
  graphics.draw(tex.back, back, 0, 0)
  graphics.draw(tex.moon, objects.moon.body:getX(), objects.moon.body:getY(), objects.moon.body:getAngle(), 1, 1, RADIUS, RADIUS)
  for k, v in pairs(objects.garbage) do
    v:draw()
  end
  graphics.setColor(255, 255, 255)
  graphics.setFont(font.basic)
  graphics.print(state.time, 20, 20)
  graphics.print(tostring(state.contam) .. " %", WIDTH - font.basic:getWidth(tostring(state.contam) .. " %") - 20, 20)
  local _exp_0 = state.stage
  if START == _exp_0 then
    return splash.go:draw()
  end
end
