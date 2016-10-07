--[[--
An example debug renderer.

Implements a naive camera which simply centres the map on the screen.

module: platformer.Renderer

release: v2.0.0
license: MIT
author: [Gamedevaton](http://gamedevaton.com)
]]

-- Pico8 colors
local color = {
  black = { 0, 0, 0 },
	dark_blue = { 29, 43, 83 },
	dark_purple = { 126, 37, 83 },
	dark_green = { 0, 135, 81 },
	brown = { 171, 82, 54 },
	dark_grey = { 95, 87, 79 },
	light_grey = { 194, 195, 199 },
	white = { 255, 241, 232 },
	red = { 255, 0, 77 },
	orange = { 255, 163, 0 },
	yellow = { 255, 240, 36 },
	green = { 0, 231, 86 },
	blue = { 41, 173, 255 },
	indigo = { 131, 118, 156 },
	pink = { 255, 119, 168 },
	peach = { 255, 204, 170 }
}

local Renderer = {
  -- camera position
  x = 0,
  y = 0,

  --- The `phyzzle.Map` to render.
  map = nil
}

--[[--
Create a new renderer.

param: t Table of initial state, needs a `Phyzzle.Map` assigned to `map`.
return: `Renderer` instance.
]]
function Renderer:new(t)
  t = t or {}
  setmetatable(t, self)
  self.__index = self
  t:init()
  return t
end

--[[
Initialize the renderer and set the background color.

Called automatically by `Map:new`.
]]
function Renderer:init()
  love.graphics.setBackgroundColor(unpack(color.black))
end

--[[--
Draw the game.

Loops over the `map` zones and draws
static entties green and dynamic entties blue.

Also displays stats about the map.
]]
function Renderer:draw()
  -- camera
  love.graphics.push()
  love.graphics.translate(-self.x, -self.y)

  -- zones
  for x = 0, self.map.zw - 1 do
    for y = 0, self.map.zh - 1 do

      -- zone
      love.graphics.setLineWidth(2)
      love.graphics.setColor(unpack(color.red))
      love.graphics.rectangle('line', x * self.map.zs, y * self.map.zs,
        self.map.zs, self.map.zs)

      -- entities
      love.graphics.setLineWidth(2)

      for k, entity in pairs(self.map.zones[x][y]) do
        if entity.static then
          love.graphics.setColor(unpack(color.dark_green))
        else
          love.graphics.setColor(unpack(color.blue))
        end

        love.graphics.rectangle('line', entity.x, entity.y, entity.w, entity.h)
      end

      -- number of entities in the zone
      love.graphics.setColor(unpack(color.white))

      local entityCount = 0

      for k, v in pairs(self.map.zones[x][y]) do
        entityCount = entityCount + 1
      end

      love.graphics.print(entityCount, x * self.map.zs + 5, y * self.map.zs + 3)
    end
  end

  love.graphics.pop()

  -- self.map summary
  love.graphics.setColor(255, 255, 255)
  love.graphics.print('Phyzzle v2.0.0', 5, 5)
  love.graphics.print('https://github.com/gamedevaton/phyzzle', 5, 20)
  love.graphics.print('https://twitter.com/gamedevaton', 5, 35)
end

return Renderer
