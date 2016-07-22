import graphics from love

class Assets
  @images: {}
  new: =>
    @tex = setmetatable {}, {
      __index: (tex, name) ->
        if not Assets.images[name]
          Assets.images[name] = graphics.newImage "images/#{name}.png"
        Assets.images[name]
    }
    @font = {
      basic: graphics.newFont 'fonts/Anonymous Pro Minus.ttf', 28
      splash: graphics.newFont 'fonts/Anonymous Pro Minus.ttf', 66
    }

{ :Assets }