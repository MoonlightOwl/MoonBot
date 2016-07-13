--
-- The MIT License (MIT)
-- Copyright (c) 2015 Matthias Richter
-- (modified & translated to MoonScript by Dmitry Zhidenkov)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

import concat, insert from table
import exp, floor, max from math
import graphics from love

class Shader
  renderToCanvas: (canvas, func, ...) =>
    old_canvas = graphics.getCanvas!
    graphics.setCanvas canvas
    graphics.clear!
    func ...
    graphics.setCanvas old_canvas

class Blur extends Shader
  build: (sigma) =>
    support = max 1, floor 3 * sigma + .5
    one_by_sigma_sq = sigma > 0 and 1 / (sigma) or 1
    norm = 0

    code = {"
      extern vec2 direction;
      vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
      { vec4 c = vec4(0.0f);
    "}

    for i = -support, support
      coeff = exp i*i * one_by_sigma_sq
      norm = norm + coeff
      insert code, "c += vec4(#{coeff}) * Texel(texture, tc + vec2(#{i}) * direction);"

    insert code, "return c * vec4(#{norm > 0 and 1/norm or 1}) * color;}"

    graphics.newShader concat code

  new: =>
    @canvas_h, @canvas_v = graphics.newCanvas!, graphics.newCanvas!
    @shader = @build 1
    @shader\send "direction", {1.0, 0.0}

  draw: (func, ...) =>
    c = graphics.getCanvas!
    s = graphics.getShader!
    co = { graphics.getColor! }

    -- draw scene
    @renderToCanvas @canvas_h, func, ...
    graphics.setColor co
    graphics.setShader @shader

    b = graphics.getBlendMode!
    graphics.setBlendMode 'alpha', 'premultiplied'

    -- first pass (horizontal)
    @shader\send 'direction', {1 / graphics.getWidth!, 0}
    @renderToCanvas @canvas_v, graphics.draw, @canvas_h, 0, 0

    -- second pass (vertical)
    @shader\send 'direction', {0, 1 / graphics.getHeight!}
    graphics.draw @canvas_v, 0, 0

    -- restore blendmode, shader and canvas
    graphics.setBlendMode b
    graphics.setShader s
    graphics.setCanvas c

  set: (key, value) ->
    if key == 'sigma'
      @shader = @build tonumber sigma
    else
      error "Unknown property: #{tostring(value)}"
    @

{ :Blur }