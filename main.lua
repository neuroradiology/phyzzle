--[[--
Runs the Phyzzle platformer example app.

The platformer example app will be extended
and more example apps will be added in future releases.

module: main
]]

local Game = require('example.platformer.game')

local game = nil

function love.load(arg)
  game = Game:new()
end

function love.update(dt)
  print(dt)
  game:update(dt)
end

function love.draw()
  game:draw()
end

--[[--
An improved `love.run` implemenation which uses a fixed time step game update loop.

Accomodates old hardware or busy games and creates deterministic simulations.

Ticks 60 times a seconds on each tick:

1. Accumulates delta time.
1. Updates while accumulated time is greater than delta time.
1. Only draw if updated.

]]
function love.run()
  local updated = false
	local dt = 1/60
  local t = 0

	love.math.setRandomSeed(os.time())
  love.load(arg)
  -- step over load time
  love.timer.step()

	while true do
    -- reset updated flag
    updated = false

		if love.event then
			love.event.pump()

			for name, a, b, c, d, e, f in love.event.poll() do
				if name == 'quit' then
					if not love.quit or not love.quit() then
						return a
					end
				end

				love.handlers[name](a,b,c,d,e,f)
			end
		end

		love.timer.step()
    -- accumulate time
		t = t + love.timer.getDelta()

    -- catch up all updates
    while t > dt do
      -- flag that engine updated
      updated = true
      t = t - dt
      love.update(dt)
    end

    -- only draw if updated this tick
		if updated then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
      love.draw()
      love.graphics.present()
		end

    -- remove if you need more performance
    love.timer.sleep(0.001)
	end
end
