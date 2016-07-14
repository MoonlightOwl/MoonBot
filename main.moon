-- 
-- [ MoonBot ]
-- MoonJam contest project
-- 2016 (c) Totoro (aka MoonlightOwl)
-- computercraft.ru
--

import insert from table
import event, graphics, physics, window from love
import min from math
import Blur from require('shader')

VERSION = 0.1
DIFFICULTY = 5
START, GAME, PAUSE, GAMEOVER = 1, 2, 3, 4


-- Interface -------------------------------------------------------------------

class View
  new: =>
    @visible = true

  setVisibility: (visible) =>
    @visible = visible
    @

  show: =>
    @visible = true
    @

  hide: =>
    @visible = false
    @

class Splash extends View
  new: (text, color, back, font) =>
    super!
    @text = text
    @back = back
    @font = font
    @color = color
    @off = {}
    x, y = back\getDimensions!
    @off.x = x / 2
    @off.y = y / 2

  draw: =>
    if @visible
      graphics.setColor 255, 255, 255
      graphics.draw @back, WIDTH / 2, HEIGTH / 2, 0, 1, 1, @off.x, @off.y
      graphics.setColor @color
      graphics.setFont @font
      graphics.print @text, 
        WIDTH / 2 - @font\getWidth(@text) / 2, HEIGTH / 2 - @font\getHeight! / 2


-- Game objects ----------------------------------------------------------------

class Garbage
  new: (world, x, y, texture, angle) =>
    @width, @height = texture\getDimensions!
    @texture = texture
    @body = physics.newBody world, x, y, "dynamic"
    @body\setAngle angle
    @shape = physics.newRectangleShape 0, 0, @width, @height
    @fixture = physics.newFixture @body, @shape, 2
    @fixture\setFriction 0.4

  draw: =>
    graphics.draw @texture, @body\getX!, @body\getY!, 
      @body\getAngle!, 1, 1, @width / 2, @height / 2


-- Game processing -------------------------------------------------------------

removeGarbage = ->
  for object in *objects.garbage
    object.body\destroy!
  objects.garbage = {}

setStage = (state, stage) ->
  state.stage = stage
  switch stage
    when START
      state.time = "00:00"
      state.contam = 0
    when GAME
      state.time_start = os.time!
      removeGarbage!
  state


-- Love cycle ------------------------------------------------------------------

love.load = ->
  -- Variables & game contants
  export state = {}   -- game state table

  export WIDTH, HEIGTH = window.getMode!
  export RADIUS = 100 -- size of the moon
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
  }

  export font = {
    basic: graphics.newFont 'fonts/Anonymous Pro Minus.ttf', 26
    splash: graphics.newFont 'fonts/Anonymous Pro Minus B.ttf', 68
  }

  export back = graphics.newQuad 0, 0, WIDTH, HEIGTH, WIDTH, HEIGTH

  export splash = {
    go: Splash "ENTER", { 255, 215, 71 }, tex.splash, font.splash
    gameover: Splash "CONTAMINATED", { 255, 71, 71 }, tex.splash, font.splash
  }

  export shader = {
    blur: Blur!
  }

  -- Init physics
  physics.setMeter 64

  export world = physics.newWorld 0, 0, true
  export objects = {}

  objects.moon = {}
  objects.moon.body = physics.newBody world, WIDTH/2, HEIGTH/2
  objects.moon.shape = physics.newCircleShape RADIUS
  objects.moon.fixture = physics.newFixture objects.moon.body, objects.moon.shape
  objects.moon.fixture\setFriction 0.7
 
  objects.garbage = {}

  -- Let's go!
  setStage state, START



love.update = (dt) ->
  if state.stage == GAME
    -- Update physics
    world\update dt

    -- Gravitate to the Moon
    mx, my = objects.moon.body\getPosition!
    for object in *objects.garbage
      x, y = object.body\getPosition!
      dx, dy = mx - x, my - y
      len = math.sqrt dx * dx + dy * dy
      fx, fy = dx / len * GRAVITY, dy / len * GRAVITY
      object.body\applyForce fx, fy

    -- Calculate contamination level
    state.contam = #objects.moon.body\getContactList! * DIFFICULTY

    -- Check state
    if state.contam > 100
      setStage state, GAMEOVER



love.keypressed = (key, scancode, isrepeat) ->
  if state.stage == GAME
    if key == "escape"
      setStage state, START
  else
    switch key
      when "return"
        setStage state, GAME
      when "escape"
        event.quit!



love.mousepressed = (x, y, button, istouch) ->
  if button == 1
    insert objects.garbage, Garbage world, x, y, tex.box, math.random(0, math.pi * 2)



renderWorld = ->
  -- Moon
  graphics.draw tex.moon, objects.moon.body\getX!, objects.moon.body\getY!, 
    objects.moon.body\getAngle!, 1, 1, RADIUS, RADIUS
 
  -- Garbage
  for k, v in pairs objects.garbage
    v\draw!

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
  graphics.print state.time, 20, 20
  
  percent = min state.contam, 100
  graphics.setColor 227 + percent * 0.28, 255 - percent * 1.34, 121
  graphics.print "#{state.contam} %", WIDTH - font.basic\getWidth("#{state.contam} %") - 20, 20

  switch state.stage
    when START
      splash.go\draw!
    when GAMEOVER
      splash.gameover\draw!
