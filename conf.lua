
function love.conf(t)
  t.identity = 'phyzzle'
  t.version = '0.10.1'
  t.console = true
  t.window.title = 'Phyzzle v2.0.0'
  t.window.icon = nil
  t.window.width = 640
  t.window.height = 480
  t.window.borderless = false
  t.window.resizable = false
  t.window.minwidth = 640
  t.window.minheight = 480
  t.window.fullscreen = false
  t.window.fullscreentype = 'desktop'
  t.window.vsync = true
  t.window.fsaa = 0
  t.window.display = 1
  t.modules.audio = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = false
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = false
  t.modules.sound = true
  t.modules.system = true
  t.modules.timer = true
  t.modules.window = true
end
