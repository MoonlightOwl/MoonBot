import graphics from love
import insert from table

-- Load particle system from file
getPS = (name, image) ->
  ps_data = require name
  particle_settings = {}
  particle_settings["colors"] = {}
  particle_settings["sizes"] = {}
  for k, v in pairs ps_data
    if k == "colors"
      j = 1
      for i = 1, #v , 4
        color = {v[i], v[i+1], v[i+2], v[i+3]}
        particle_settings["colors"][j] = color
        j = j + 1
    elseif k == "sizes"
      for i = 1, #v do particle_settings["sizes"][i] = v[i]
    else particle_settings[k] = v
  
  ps = graphics.newParticleSystem image, particle_settings["buffer_size"]
  ps\setAreaSpread string.lower(particle_settings["area_spread_distribution"]),
    particle_settings["area_spread_dx"] or 0 , particle_settings["area_spread_dy"] or 0
  ps\setBufferSize particle_settings["buffer_size"] or 1
  colors = {}
  for i = 1, 8
    if particle_settings["colors"][i][1] ~= 0 or 
        particle_settings["colors"][i][2] ~= 0 or 
        particle_settings["colors"][i][3] ~= 0 or 
        particle_settings["colors"][i][4] ~= 0
      insert colors, particle_settings["colors"][i][1] or 0
      insert colors, particle_settings["colors"][i][2] or 0
      insert colors, particle_settings["colors"][i][3] or 0
      insert colors, particle_settings["colors"][i][4] or 0
  
  ps\setColors unpack colors 
  ps\setColors unpack colors
  ps\setDirection math.rad particle_settings["direction"] or 0
  ps\setEmissionRate particle_settings["emission_rate"] or 0
  ps\setEmitterLifetime particle_settings["emitter_lifetime"] or 0
  ps\setInsertMode string.lower particle_settings["insert_mode"]
  ps\setLinearAcceleration particle_settings["linear_acceleration_xmin"] or 0, 
    particle_settings["linear_acceleration_ymin"] or 0, 
    particle_settings["linear_acceleration_xmax"] or 0,
    particle_settings["linear_acceleration_ymax"] or 0
  if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0
    ps\setOffset particle_settings["offsetx"], particle_settings["offsety"]
  
  ps\setParticleLifetime particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0
  ps\setRadialAcceleration particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0
  ps\setRotation math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0)
  ps\setSizeVariation particle_settings["size_variation"] or 0
  sizes = {}
  sizes_i = 1 
  for i = 1, 8
    if particle_settings["sizes"][i] == 0
      if i < 8 and particle_settings["sizes"][i+1] == 0
        sizes_i = i
        break
  
  if sizes_i > 1
      for i = 1, sizes_i do insert sizes, particle_settings["sizes"][i] or 0
      ps\setSizes unpack sizes
  
  ps\setSpeed particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0
  ps\setSpin math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0)
  ps\setSpinVariation particle_settings["spin_variation"] or 0
  ps\setSpread math.rad particle_settings["spread"] or 0
  ps\setTangentialAcceleration particle_settings["tangential_acceleration_min"] or 0,
    particle_settings["tangential_acceleration_max"] or 0
  return ps


class Explosion
  new: (assets, x, y, time) =>
    @ps = getPS 'fx/explosion', assets.tex.cloud
    @x = x
    @y = y
    @time = time
    @lifetime = 0.0

  update: (dt) =>
    @lifetime += dt
    @ps\update dt

  isDead: =>
    @lifetime >= @time

  draw: =>
    graphics.draw @ps, @x, @y

  destroy: =>
    @ps\stop!

{ :Explosion }