local insert
insert = table.insert
local event, graphics, keyboard, physics, window
do
  local _obj_0 = love
  event, graphics, keyboard, physics, window = _obj_0.event, _obj_0.graphics, _obj_0.keyboard, _obj_0.physics, _obj_0.window
end
local cos, floor, min, pi, random, sin, sqrt
do
  local _obj_0 = math
  cos, floor, min, pi, random, sin, sqrt = _obj_0.cos, _obj_0.floor, _obj_0.min, _obj_0.pi, _obj_0.random, _obj_0.sin, _obj_0.sqrt
end
local Assets
Assets = require('assets').Assets
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
local Bullet, BulletOne
do
  local _obj_0 = require('bullet')
  Bullet, BulletOne = _obj_0.Bullet, _obj_0.BulletOne
end
local Explosion
Explosion = require('ps').Explosion
local VERSION = 0.1
local DIFFICULTY = 5
local START, NEWGAME, GAME, PAUSE, GAMEOVER = 1, 2, 3, 4, 5
local nope
nope = function()
  return 0
end
local randomFloat
randomFloat = function(lower, greater)
  return lower + random() * (greater - lower)
end
local cleanPhysicsUp
cleanPhysicsUp = function()
  local _list_0 = objects.garbage
  for _index_0 = 1, #_list_0 do
    local object = _list_0[_index_0]
    object.body:destroy()
  end
  objects.garbage = { }
  local _list_1 = objects.bullets
  for _index_0 = 1, #_list_1 do
    local object = _list_1[_index_0]
    object.body:destroy()
  end
  objects.bullets = { }
  return objects.robot:reset()
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
    state.rate = 100
    state.time = 0
    state.contam = 0
    state.target_contam = 0
    cleanPhysicsUp()
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
  assets = Assets()
  back = graphics.newQuad(0, 0, WIDTH, HEIGTH, WIDTH, HEIGTH)
  splash = {
    go = Splash(assets, "ENTER", {
      255,
      215,
      71
    }),
    gameover = Splash(assets, "CONTAMINATED", {
      255,
      71,
      71
    }),
    pause = Splash(assets, "PAUSE", {
      255,
      215,
      71
    })
  }
  shader = {
    blur = Blur()
  }
  physics.setMeter(64)
  world = physics.newWorld(0, 0, true)
  objects = { }
  objects.moon = Moon(assets, world, WIDTH / 2, HEIGTH / 2)
  objects.robot = Robot(assets, world, WIDTH / 2, HEIGTH / 2 - objects.moon.radius - 30)
  objects.garbage = { }
  objects.bullets = { }
  explosions = { }
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
    if random(1, state.rate) == 1 then
      local angle = randomFloat(0, pi * 2)
      local x, y = WIDTH / 2 + cos(angle) * (WIDTH + 100), HEIGTH / 2 + sin(angle) * (WIDTH + 100)
      local garbage = Garbage(assets, world, x, y, random(0, pi * 2))
      garbage.body:setLinearVelocity(random(-GRAVITY * 2, GRAVITY * 2), random(-GRAVITY * 2, GRAVITY * 2))
      insert(objects.garbage, garbage)
    end
    local alive_bullets = { }
    local _list_1 = objects.bullets
    for _index_0 = 1, #_list_1 do
      local bullet = _list_1[_index_0]
      bullet:update(dt)
      gravitate(bullet, objects.moon, GRAVITY * 0.2)
      local _list_2 = bullet.body:getContactList()
      for _index_1 = 1, #_list_2 do
        local coll = _list_2[_index_1]
        if coll:isTouching() then
          local a, b = coll:getFixtures()
          if a:getGroupIndex() ~= Robot.PH_GROUP and b:getGroupIndex() ~= Robot.PH_GROUP then
            local explosion = Explosion(assets, bullet:getX(), bullet:getY(), 1.0)
            insert(explosions, explosion)
            bullet:makeDead()
            break
          end
        end
      end
      if bullet:isDead() then
        bullet:destroy()
      else
        insert(alive_bullets, bullet)
      end
    end
    objects.bullets = alive_bullets
    local alive_explosions = { }
    local _list_2 = explosions
    for _index_0 = 1, #_list_2 do
      local explosion = _list_2[_index_0]
      explosion:update(dt)
      if explosion:isDead() then
        explosion:destroy()
      else
        insert(alive_explosions, explosion)
      end
    end
    local explosions = alive_explosions
    objects.robot:update(dt, objects.moon)
    if keyboard.isScancodeDown('a', 'left') then
      objects.robot:moveLeft(80)
    end
    if keyboard.isScancodeDown('d', 'right') then
      objects.robot:moveRight(80)
    end
    if keyboard.isScancodeDown('w', 'up') then
      objects.robot:jump(80)
    end
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
    local rx, ry = objects.robot:getX(), objects.robot:getY()
    local dx, dy = x - rx, y - ry
    local len = sqrt(dx * dx + dy * dy)
    local bullet = BulletOne(assets, world, rx + dx / len * objects.robot.width, ry + dy / len * objects.robot.height, dx * 2, dy * 2)
    return insert(objects.bullets, bullet)
  end
end
local renderWorld
renderWorld = function()
  objects.moon:draw()
  objects.robot:draw()
  local _list_0 = objects.garbage
  for _index_0 = 1, #_list_0 do
    local garbage = _list_0[_index_0]
    garbage:draw()
  end
  local _list_1 = objects.bullets
  for _index_0 = 1, #_list_1 do
    local bullet = _list_1[_index_0]
    bullet:draw()
  end
  graphics.setBlendMode("add")
  local _list_2 = explosions
  for _index_0 = 1, #_list_2 do
    local explosion = _list_2[_index_0]
    explosion:draw()
  end
  return graphics.setBlendMode("alpha")
end
love.draw = function()
  graphics.setColor(255, 255, 255)
  graphics.draw(assets.tex.back, back, 0, 0)
  if state.stage ~= GAME then
    shader.blur:draw(renderWorld)
  else
    renderWorld()
  end
  graphics.setColor(255, 255, 255)
  graphics.setFont(assets.font.basic)
  graphics.print(os.date("%M:%S", state.time), 20, 20)
  local percent = min(state.contam, 100)
  graphics.setColor(227 + percent * 0.28, 255 - percent * 1.34, 121)
  graphics.print(tostring(floor(state.contam)) .. " %", WIDTH - assets.font.basic:getWidth(tostring(floor(state.contam)) .. " %") - 20, 20)
  local _exp_0 = state.stage
  if START == _exp_0 then
    return splash.go:draw()
  elseif GAMEOVER == _exp_0 then
    return splash.gameover:draw()
  elseif PAUSE == _exp_0 then
    return splash.pause:draw()
  end
end
