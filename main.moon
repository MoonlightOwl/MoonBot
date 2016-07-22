-- 
-- [ MoonBot ]
-- MoonJam contest project
-- 2016 (c) Totoro (aka MoonlightOwl)
-- computercraft.ru
--

import insert from table
import event, graphics, keyboard, physics, window from love
import cos, floor, min, pi, random, sin, sqrt from math
import Assets from require 'assets'
import Blur from require 'shader'
import Splash from require 'ui'
import Moon from require 'moon'
import Garbage from require 'garbage'
import Robot from require 'robot'
import Bullet, BulletOne from require 'bullet'
import Explosion from require 'ps'

VERSION = 0.1
DIFFICULTY = 5
START, NEWGAME, GAME, PAUSE, GAMEOVER = 1, 2, 3, 4, 5

-- Game processing -------------------------------------------------------------

nope = -> 0

randomFloat = (lower, greater) ->
    lower + random! * (greater - lower)

cleanPhysicsUp = ->
  -- Remove garbage
  for object in *objects.garbage do object.body\destroy!
  objects.garbage = {}
  -- Remove bullets
  for object in *objects.bullets do object.body\destroy!
  objects.bullets = {}
  -- Reset robot
  objects.robot\reset!

setStage = (state, stage) ->
  state.stage = stage
  switch stage
    when START
      state.time = 0
      state.contam = 0
      state.target_contam = 0
    when NEWGAME
      state.rate = 100
      state.time = 0
      state.contam = 0
      state.target_contam = 0
      cleanPhysicsUp!
      state.stage = GAME
    when GAME
      nope!
    when PAUSE
      nope!
  state


gravitate = (object, moon, gravity) ->
  gravity = gravity or GRAVITY
  mx, my = moon.body\getPosition!
  x, y = object.body\getPosition!
  dx, dy = mx - x, my - y
  len = math.sqrt dx * dx + dy * dy
  fx, fy = dx / len * GRAVITY, dy / len * GRAVITY
  object.body\applyForce fx, fy


-- Love cycle ------------------------------------------------------------------

love.load = ->
  -- Variables & game contants
  export state = {}   -- game state table

  export WIDTH, HEIGTH = window.getMode!
  export GRAVITY = 50  -- moon gravity

  math.randomseed os.time!
  window.setTitle "MoonBot!  #{VERSION}"

  -- Load graphics
  export assets = Assets!
  export back = graphics.newQuad 0, 0, WIDTH, HEIGTH, WIDTH, HEIGTH
  export splash = {
    go: Splash assets, "ENTER", { 255, 215, 71 }
    gameover: Splash assets, "CONTAMINATED", { 255, 71, 71 }
    pause: Splash assets, "PAUSE", { 255, 215, 71 }
  }
  export shader = {
    blur: Blur!
  }

  -- Init physics
  physics.setMeter 64
  export world = physics.newWorld 0, 0, true
  export objects = {}
  objects.moon = Moon assets, world, WIDTH / 2, HEIGTH / 2
  objects.robot = Robot assets, world, WIDTH / 2, HEIGTH / 2 - objects.moon.radius - 30
  objects.garbage = {}
  objects.bullets = {}

  -- Init particle systems
  export explosions = {}

  -- Let's go!
  setStage state, START



love.update = (dt) ->
  if state.stage == GAME
    -- Update physics
    world\update dt

    -- Gravitate to the Moon
    for object in *objects.garbage
      gravitate object, objects.moon
    gravitate objects.robot, objects.moon, GRAVITY * 10

    -- Spawn new garbage
    if random(1, state.rate) == 1
      angle = randomFloat 0, pi * 2
      x, y = WIDTH / 2 + cos(angle) * (WIDTH + 100), HEIGTH / 2 + sin(angle) * (WIDTH + 100)
      garbage = Garbage assets, world, x, y, random(0, pi * 2)
      garbage.body\setLinearVelocity random(-GRAVITY * 2, GRAVITY * 2), random(-GRAVITY * 2, GRAVITY * 2)
      insert objects.garbage, garbage

    -- Update bullets
    alive_bullets = {}
    for bullet in *objects.bullets
      bullet\update dt
      gravitate bullet, objects.moon, GRAVITY * 0.2
      for coll in *bullet.body\getContactList!
        if coll\isTouching!
          a, b = coll\getFixtures!
          if a\getGroupIndex! ~= Robot.PH_GROUP and b\getGroupIndex! ~= Robot.PH_GROUP
            explosion = Explosion assets, bullet\getX!, bullet\getY!, 1.0
            insert explosions, explosion
            bullet\makeDead!
            break
      if bullet\isDead!
        bullet\destroy!
      else
        insert alive_bullets, bullet
    objects.bullets = alive_bullets

    -- Update particle systems
    alive_explosions = {}
    for explosion in *explosions
      explosion\update dt
      if explosion\isDead!
        explosion\destroy!
      else
        insert alive_explosions, explosion
    explosions = alive_explosions

    -- Update player
    objects.robot\update dt, objects.moon
    if keyboard.isScancodeDown 'a', 'left'
      objects.robot\moveLeft 80
    if keyboard.isScancodeDown 'd', 'right'
      objects.robot\moveRight 80
    if keyboard.isScancodeDown 'w', 'up'
      objects.robot\jump 80

    -- Calculate contamination level
    state.target_contam = #objects.moon.body\getContactList! * DIFFICULTY
    state.contam += (state.target_contam - state.contam) * dt

    -- Update time
    state.time += dt

    -- Check state
    if state.contam >= 100
      setStage state, GAMEOVER



love.keypressed = (key, scancode, isrepeat) ->
  if state.stage == GAME
    switch key
      when "escape"
        setStage state, START
      when "p"
        setStage state, PAUSE
  else if state.stage == PAUSE
    if key == "p" or key == "return"
      setStage state, GAME
  else
    switch key
      when "return"
        setStage state, NEWGAME
      when "escape"
        event.quit!



love.mousepressed = (x, y, button, istouch) ->
  -- Fire!
  if button == 1
    rx, ry = objects.robot\getX!, objects.robot\getY!
    dx, dy = x - rx, y - ry
    len = sqrt dx*dx + dy*dy
    bullet = BulletOne assets, world, 
      rx + dx / len * objects.robot.width, ry + dy / len * objects.robot.height, dx * 2, dy * 2
    insert objects.bullets, bullet



renderWorld = ->
  -- Robot & moon
  objects.moon\draw!
  objects.robot\draw!

  -- Garbage
  for garbage in *objects.garbage
    garbage\draw!

  -- Bullets
  for bullet in *objects.bullets
    bullet\draw!

  -- Explosions
  graphics.setBlendMode "add"
  for explosion in *explosions
    explosion\draw!
  graphics.setBlendMode "alpha"

love.draw = ->
  -- Background
  graphics.setColor 255, 255, 255
  graphics.draw assets.tex.back, back, 0, 0

  if state.stage != GAME
    shader.blur\draw renderWorld
  else renderWorld!

  -- UI
  graphics.setColor 255, 255, 255
  graphics.setFont assets.font.basic
  graphics.print os.date("%M:%S", state.time), 20, 20
  
  percent = min state.contam, 100
  graphics.setColor 227 + percent * 0.28, 255 - percent * 1.34, 121
  graphics.print "#{floor state.contam} %", 
    WIDTH - assets.font.basic\getWidth("#{floor state.contam} %") - 20, 20

  switch state.stage
    when START
      splash.go\draw!
    when GAMEOVER
      splash.gameover\draw!
    when PAUSE
      splash.pause\draw!
