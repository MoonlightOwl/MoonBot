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
local Splash
Splash = require('ui').Splash
local Moon
Moon = require('moon').Moon
local Garbage
Garbage = require('garbage').Garbage
local Robot
Robot = require('robot').Robot
local VERSION = 0.1
local DIFFICULTY = 5
local START, NEWGAME, GAME, PAUSE, GAMEOVER = 1, 2, 3, 4, 5
local nope
nope = function()
  return 0
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
    state.time = 0
    state.contam = 0
    state.target_contam = 0
  elseif NEWGAME == _exp_0 then
    state.time = 0
    state.contam = 0
    state.target_contam = 0
    removeGarbage()
    state.stage = GAME
  elseif GAME == _exp_0 then
    nope()
  elseif PAUSE == _exp_0 then
    nope()
  end
  return state
end
local gravitate
gravitate = function(object, moon, gravity)
  gravity = gravity or GRAVITY
  local mx, my = moon.body:getPosition()
  local x, y = object.body:getPosition()
  local dx, dy = mx - x, my - y
  local len = math.sqrt(dx * dx + dy * dy)
  local fx, fy = dx / len * GRAVITY, dy / len * GRAVITY
  return object.body:applyForce(fx, fy)
end
love.load = function()
  state = { }
  WIDTH, HEIGTH = window.getMode()
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
  back = graphics.newQuad(0, 0, WIDTH, HEIGTH, WIDTH, HEIGTH)
  font = {
    basic = graphics.newFont('fonts/Anonymous Pro Minus.ttf', 26),
    splash = graphics.newFont('fonts/Anonymous Pro Minus B.ttf', 68)
  }
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
    }, tex.splash, font.splash),
    pause = Splash("PAUSE", {
      255,
      215,
      71
    }, tex.splash, font.splash)
  }
  shader = {
    blur = Blur()
  }
  physics.setMeter(64)
  world = physics.newWorld(0, 0, true)
  objects = { }
  objects.moon = Moon(world, WIDTH / 2, HEIGTH / 2, tex.moon)
  objects.robot = Robot(world, WIDTH / 2, HEIGTH / 2 - objects.moon.radius - 30, tex.robot)
  objects.garbage = { }
  return setStage(state, START)
end
love.update = function(dt)
  if state.stage == GAME then
    world:update(dt)
    local _list_0 = objects.garbage
    for _index_0 = 1, #_list_0 do
      local object = _list_0[_index_0]
      gravitate(object, objects.moon)
    end
    gravitate(objects.robot, objects.moon, GRAVITY * 10)
    objects.robot:update(dt, objects.moon)
    state.target_contam = #objects.moon.body:getContactList() * DIFFICULTY
    state.contam = state.contam + ((state.target_contam - state.contam) * dt)
    state.time = state.time + dt
    if state.contam >= 100 then
      return setStage(state, GAMEOVER)
    end
  end
end
love.keypressed = function(key, scancode, isrepeat)
  if state.stage == GAME then
    local _exp_0 = key
    if "escape" == _exp_0 then
      return setStage(state, START)
    elseif "p" == _exp_0 then
      return setStage(state, PAUSE)
    end
  else
    if state.stage == PAUSE then
      if key == "p" or key == "return" then
        return setStage(state, GAME)
      end
    else
      local _exp_0 = key
      if "return" == _exp_0 then
        return setStage(state, NEWGAME)
      elseif "escape" == _exp_0 then
        return event.quit()
      end
    end
  end
end
love.mousepressed = function(x, y, button, istouch)
  if button == 1 then
    local garbage = Garbage(world, x, y, tex.box, random(0, math.pi * 2))
    garbage.body:setLinearVelocity(random(-GRAVITY * 10, GRAVITY * 10), random(-GRAVITY * 10, GRAVITY * 10))
    return insert(objects.garbage, garbage)
  end
end
local renderWorld
renderWorld = function()
  objects.moon:draw()
  objects.robot:draw()
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
  graphics.print(os.date("%M:%S", state.time), 20, 20)
  local percent = min(state.contam, 100)
  graphics.setColor(227 + percent * 0.28, 255 - percent * 1.34, 121)
  graphics.print(tostring(floor(state.contam)) .. " %", WIDTH - font.basic:getWidth(tostring(floor(state.contam)) .. " %") - 20, 20)
  local _exp_0 = state.stage
  if START == _exp_0 then
    return splash.go:draw()
  elseif GAMEOVER == _exp_0 then
    return splash.gameover:draw()
  elseif PAUSE == _exp_0 then
    return splash.pause:draw()
  end
end
