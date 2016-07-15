import graphics from love

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

{ :View, :Splash }