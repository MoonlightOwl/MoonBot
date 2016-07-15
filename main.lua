local insert
insert = table.insert
local event, graphics, physics, window
do
  local _obj_0 = love
  event, graphics, physics, window = _obj_0.event, _obj_0.graphics, _obj_0.physics, _obj_0.window
end
local floor, min, random
do
  local _obj_0 = math
  floor, min, random = _obj_0.floor, _obj_0.min, _obj_0.random
end
local Blur
Blur = require('shader').Blur
local VERSION = 0.1
local DIFFICULTY = 5
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
      self.fixture = physics.newFixture(self.body, self.shape, 2)
      return self.fixture:setFriction(0.4)
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
local removeGarbage
removeGarbage = function()
  local _list_0 = objects.garbage
  for _index_0 = 1, #_list_0 do
    local object = _list_0[_index_0]
    object.body:destroy()
  end
  objects.garbage = { }
end
local setStage
setStage = function(state, stage)
  state.stage = stage
  local _exp_0 = stage
  if START == _exp_0 then
    state.time = "00:00"
    state.contam = 0
    state.target_contam = 0
  elseif GAME == _exp_0 then
    state.time_start = os.time()
    removeGarbage()
  end
  return state
end
love.load = function()
  state = { }
  WIDTH, HEIGTH = window.getMode()
  RADIUS = 100
  GRAVITY = 50
  math.randomseed(os.time())
  window.setTitle("MoonBot!  " .. tostring(VERSION))
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
    go = Splash("ENTER", {
      255,
      215,
      71
    }, tex.splash, font.splash),
    gameover = Splash("CONTAMINATED", {
      255,
      71,
      71
    }, tex.splash, font.splash)
  }
  shader = {
    blur = Blur()
  }
  physics.setMeter(64)
  world = physics.newWorld(0, 0, true)
  objects = { }
  objects.moon = { }
  objects.moon.body = physics.newBody(world, WIDTH / 2, HEIGTH / 2)
  objects.moon.shape = physics.newCircleShape(RADIUS)
  objects.moon.fixture = physics.newFixture(objects.moon.body, objects.moon.shape)
  objects.moon.fixture:setFriction(0.7)
  objects.garbage = { }
  return setStage(state, START)
end
love.update = function(dt)
  if state.stage == GAME then
    world:update(dt)
    local mx, my = objects.moon.body:getPosition()
    local _list_0 = objects.garbage
    for _index_0 = 1, #_list_0 do
      local object = _list_0[_index_0]
      local x, y = object.body:getPosition()
      local dx, dy = mx - x, my - y
      local len = math.sqrt(dx * dx + dy * dy)
      local fx, fy = dx / len * GRAVITY, dy / len * GRAVITY
      object.body:applyForce(fx, fy)
    end
    state.target_contam = #objects.moon.body:getContactList() * DIFFICULTY
    state.contam = state.contam + ((state.target_contam - state.contam) * dt)
    if state.contam >= 100 then
      return setStage(state, GAMEOVER)
    end
  end
end
love.keypressed = function(key, scancode, isrepeat)
  if state.stage == GAME then
    if key == "escape" then
      return setStage(state, START)
    end
  else
    local _exp_0 = key
    if "return" == _exp_0 then
      return setStage(state, GAME)
    elseif "escape" == _exp_0 then
      return event.quit()
    end
  end
end
love.mousepressed = function(x, y, button, istouch)
  if button == 1 then
    local garbage = Garbage(world, x, y, tex.box, random(0, math.pi * 2))
    garbage.body:setLinearDamping(0.01)
    garbage.body:setLinearVelocity(random(-GRAVITY * 10, GRAVITY * 10), random(-GRAVITY * 10, GRAVITY * 10))
    return insert(objects.garbage, garbage)
  end
end
local renderWorld
renderWorld = function()
  graphics.draw(tex.moon, objects.moon.body:getX(), objects.moon.body:getY(), objects.moon.body:getAngle(), 1, 1, RADIUS, RADIUS)
  for k, v in pairs(objects.garbage) do
    v:draw()
  end
end
love.draw = function()
  graphics.setColor(255, 255, 255)
  graphics.draw(tex.back, back, 0, 0)
  if state.stage ~= GAME then
    shader.blur:draw(renderWorld)
  else
    renderWorld()
  end
  graphics.setColor(255, 255, 255)
  graphics.setFont(font.basic)
  graphics.print(state.time, 20, 20)
  local percent = min(state.contam, 100)
  graphics.setColor(227 + percent * 0.28, 255 - percent * 1.34, 121)
  graphics.print(tostring(floor(state.contam)) .. " %", WIDTH - font.basic:getWidth(tostring(floor(state.contam)) .. " %") - 20, 20)
  local _exp_0 = state.stage
  if START == _exp_0 then
    return splash.go:draw()
  elseif GAMEOVER == _exp_0 then
    return splash.gameover:draw()
  end
end
