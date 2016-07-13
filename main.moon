-- 
-- [ MoonBot ]
-- MoonJam contest project
-- 2016 (c) Totoro (aka MoonlightOwl)
-- computercraft.ru
--

import insert from table
import event, graphics, physics, window from love
import Blur from require('shader')

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
    @fixture = physics.newFixture @body, @shape, 1

  draw: =>
    graphics.draw @texture, @body\getX!, @body\getY!, 
      @body\getAngle!, 1, 1, @width / 2, @height / 2


-- Game processing -------------------------------------------------------------

setStage = (state, stage) ->
  state.stage = stage
  switch stage
    when START
      state.time = "00:00"
      state.contam = 0
    when GAME
      state.time_start = os.time!
  state


-- Love cycle ------------------------------------------------------------------

love.load = ->
  -- Variables & game contants
  export state = {}   -- game state table

  export WIDTH, HEIGTH = window.getMode!
  export RADIUS = 100 -- size of the moon

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
 
  objects.garbage = {}

  -- Let's go!
  insert objects.garbage, Garbage world, 200, 200, tex.box, 10
  insert objects.garbage, Garbage world, 120, 120, tex.box, 45

  setStage state, START



love.update = (dt) ->
  if state.stage == GAME
    world\update dt



love.keypressed = (key, scancode, isrepeat) ->
  switch state.stage
    when START
      switch key
        when "return"
          setStage state, GAME
        when "escape"
          event.quit!
    when GAME
      if key == "escape"
        setStage state, START



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

  if state.stage == START
    shader.blur\draw renderWorld
  else renderWorld!

  -- UI
  graphics.setColor 255, 255, 255
  graphics.setFont font.basic
  graphics.print state.time, 20, 20
  graphics.print "#{state.contam} %", WIDTH - font.basic\getWidth("#{state.contam} %") - 20, 20

  switch state.stage
    when START
      splash.go\draw!
