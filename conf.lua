function love.conf (c)
  -- set meta-data
  c.title = "Class Game"
  c.author = "The Class"
  c.version = "0.7.2"

  -- disable unused modules
  c.modules.joystick = false
  c.modules.audio = false
  c.modules.mouse = false
  c.modules.sound = false
  c.modules.physics = false
end

-- vim:set ts=8 sts=2 sw=2 noet:
