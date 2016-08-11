import cos, floor, min, pi, random, sin, sqrt from math
import BulletOne from require 'bullet'

class Weapon
  new: (assets, world, size) =>
    @assets = assets
    @world = world
    @safe_range = size

    @initParams!

    @_magazine = @magazine
    @_uptime = 0
    @_ready = true
    @_trigger = false

  hasAmmo: =>
    @_ammo == nil or @_ammo > 0

  magazineSize: =>
    @magazine

  currentMagazine: =>
    @_magazine

  isReloading: =>
    not @_ready and @_magazine <= 0

  trigger: (rx, ry, mx, my) =>
    @_trigger = true
    @_rx = rx
    @_ry = ry
    @_mx = mx
    @_my = my

  update: (dt) =>
    bullet = nil
    if not @_ready
      @_uptime += dt
      -- Chamber new bullet
      if @_magazine > 0
        if @_uptime > @trigger_time
          @_uptime -= @trigger_time
          @_ready = true
          @_trigger = false
      -- Reload magazine
      else
        if @hasAmmo!
          if @_uptime > @reload_time
            @_uptime -= @reload_time
            @_magazine = @magazine
            if @_ammo != nil then @_ammo -= @magazine
            @_ready = true
            @_trigger = false
    else
      if @_trigger
        if @_magazine > 0
          bullet = @fire!
          @_magazine -= 1
        @_ready = false
        @_trigger = false
    bullet


class PlasmaOne extends Weapon
  initParams: =>
    @name = "Plasma One"
    @magazine = 5
    @trigger_time = 0.06
    @reload_time = 0.5

  fire: =>
    dx, dy = @_mx - @_rx, @_my - @_ry
    len = sqrt dx*dx + dy*dy
    dx /= len
    dy /= len
    BulletOne @assets, @world, 
      @_rx + dx * @safe_range, @_ry + dy * @safe_range, dx, dy


{ :PlasmaOne }