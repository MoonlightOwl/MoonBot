local graphics
graphics = love.graphics
local insert
insert = table.insert
local getPS
getPS = function(name, image)
  local ps_data = require(name)
  local particle_settings = { }
  particle_settings["colors"] = { }
  particle_settings["sizes"] = { }
  for k, v in pairs(ps_data) do
    if k == "colors" then
      local j = 1
      for i = 1, #v, 4 do
        local color = {
          v[i],
          v[i + 1],
          v[i + 2],
          v[i + 3]
        }
        particle_settings["colors"][j] = color
        j = j + 1
      end
    elseif k == "sizes" then
      for i = 1, #v do
        particle_settings["sizes"][i] = v[i]
      end
    else
      particle_settings[k] = v
    end
  end
  local ps = graphics.newParticleSystem(image, particle_settings["buffer_size"])
  ps:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0, particle_settings["area_spread_dy"] or 0)
  ps:setBufferSize(particle_settings["buffer_size"] or 1)
  local colors = { }
  for i = 1, 8 do
    if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
      insert(colors, particle_settings["colors"][i][1] or 0)
      insert(colors, particle_settings["colors"][i][2] or 0)
      insert(colors, particle_settings["colors"][i][3] or 0)
      insert(colors, particle_settings["colors"][i][4] or 0)
    end
  end
  ps:setColors(unpack(colors))
  ps:setColors(unpack(colors))
  ps:setDirection(math.rad(particle_settings["direction"] or 0))
  ps:setEmissionRate(particle_settings["emission_rate"] or 0)
  ps:setEmitterLifetime(particle_settings["emitter_lifetime"] or 0)
  ps:setInsertMode(string.lower(particle_settings["insert_mode"]))
  ps:setLinearAcceleration(particle_settings["linear_acceleration_xmin"] or 0, particle_settings["linear_acceleration_ymin"] or 0, particle_settings["linear_acceleration_xmax"] or 0, particle_settings["linear_acceleration_ymax"] or 0)
  if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0 then
    ps:setOffset(particle_settings["offsetx"], particle_settings["offsety"])
  end
  ps:setParticleLifetime(particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0)
  ps:setRadialAcceleration(particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0)
  ps:setRotation(math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0))
  ps:setSizeVariation(particle_settings["size_variation"] or 0)
  local sizes = { }
  local sizes_i = 1
  for i = 1, 8 do
    if particle_settings["sizes"][i] == 0 then
      if i < 8 and particle_settings["sizes"][i + 1] == 0 then
        sizes_i = i
        break
      end
    end
  end
  if sizes_i > 1 then
    for i = 1, sizes_i do
      insert(sizes, particle_settings["sizes"][i] or 0)
    end
    ps:setSizes(unpack(sizes))
  end
  ps:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
  ps:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
  ps:setSpinVariation(particle_settings["spin_variation"] or 0)
  ps:setSpread(math.rad(particle_settings["spread"] or 0))
  ps:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, particle_settings["tangential_acceleration_max"] or 0)
  return ps
end
local Explosion
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      self.lifetime = self.lifetime + dt
      return self.ps:update(dt)
    end,
    isDead = function(self)
      return self.lifetime >= self.time
    end,
    draw = function(self)
      return graphics.draw(self.ps, self.x, self.y)
    end,
    destroy = function(self)
      return self.ps:stop()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, assets, x, y, time)
      self.ps = getPS('fx/explosion', assets.tex.cloud)
      self.x = x
      self.y = y
      self.time = time
      self.lifetime = 0.0
    end,
    __base = _base_0,
    __name = "Explosion"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Explosion = _class_0
end
return {
  Explosion = Explosion
}
