-- 
-- [ MoonBot ]
-- MoonJam contest project
-- 2016 (c) Totoro (aka MoonlightOwl)
-- computercraft.ru
--

import insert from table
import event, graphics, keyboard, physics, window from love
import floor, min, random, sqrt from math
import Blur from require 'shader'
import Splash from require 'ui'
import Moon from require 'moon'
import Garbage from require 'garbage'
import Robot from require 'robot'
import Bullet, BulletOne from require 'bullet'

VERSION = 0.1
DIFFICULTY = 5
START, NEWGAME, GAME, PAUSE, GAMEOVER = 1, 2, 3, 4, 5

-- Game processing -------------------------------------------------------------

nope = -> 0

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
  export tex = {
    back: graphics.newImage 'images/back.png'
    moon: graphics.newImage 'images/moon.png'
    box: graphics.newImage 'images/box.png'
    robot: graphics.newImage 'images/robot.png'
    splash: graphics.newImage 'images/splash.png'
    bullet: {
      graphics.newImage 'images/bullet0.png',
      graphics.newImage 'images/bullet1.png'
    }
  }
  export back = graphics.newQuad 0, 0, WIDTH, HEIGTH, WIDTH, HEIGTH

  BulletOne.damage = 1
  BulletOne.texture = tex.bullet[2]
  BulletOne.sparkle = tex.bullet[1]

  export font = {
    basic: graphics.newFont 'fonts/Anonymous Pro Minus.ttf', 28
    splash: graphics.newFont 'fonts/Anonymous Pro Minus.ttf', 66
  }

  export splash = {
    go: Splash "ENTER", { 255, 215, 71 }, tex.splash, font.splash
    gameover: Splash "CONTAMINATED", { 255, 71, 71 }, tex.splash, font.splash
    pause: Splash "PAUSE", { 255, 215, 71 }, tex.splash, font.splash
  }

  export shader = {
    blur: Blur!
  }

  -- Init physics
  physics.setMeter 64

  export world = physics.newWorld 0, 0, true

  export objects = {}
  objects.moon = Moon world, WIDTH / 2, HEIGTH / 2, tex.moon
  objects.robot = Robot world, WIDTH / 2, HEIGTH / 2 - objects.moon.radius - 30, tex.robot
  objects.garbage = {}
  objects.bullets = {}

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

    -- Update bullets
    alive_bullets = {}
    for bullet in *objects.bullets
      bullet\update dt
      gravitate bullet, objects.moon, GRAVITY * 0.5
      for coll in *bullet.body\getContactList!
        if coll\isTouching!
          a, b = coll\getFixtures!
          if a\getGroupIndex! ~= Robot.PH_GROUP and b\getGroupIndex! ~= Robot.PH_GROUP
            bullet\makeDead!
            break
      if bullet\isDead!
        bullet.body\destroy!
      else
        insert alive_bullets, bullet
    objects.bullets = alive_bullets


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
  -- Create a garbage for the test
  if button == 2
    garbage = Garbage world, x, y, tex.box, random(0, math.pi * 2)
    garbage.body\setLinearVelocity random(-GRAVITY * 10, GRAVITY * 10), random(-GRAVITY * 10, GRAVITY * 10)
    insert objects.garbage, garbage
  -- Shoot!
  else if button == 1
    rx, ry = objects.robot\getX!, objects.robot\getY!
    dx, dy = x - rx, y - ry
    len = sqrt dx*dx + dy*dy
    bullet = BulletOne world, 
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

love.draw = ->
  -- Background
  graphics.setColor 255, 255, 255
  graphics.draw tex.back, back, 0, 0

  if state.stage != GAME
    shader.blur\draw renderWorld
  else renderWorld!

  -- UI
  graphics.setColor 255, 255, 255
  graphics.setFont font.basic
  graphics.print os.date("%M:%S", state.time), 20, 20
  
  percent = min state.contam, 100
  graphics.setColor 227 + percent * 0.28, 255 - percent * 1.34, 121
  graphics.print "#{floor state.contam} %", WIDTH - font.basic\getWidth("#{floor state.contam} %") - 20, 20

  switch state.stage
    when START
      splash.go\draw!
    when GAMEOVER
      splash.gameover\draw!
    when PAUSE
      splash.pause\draw!
