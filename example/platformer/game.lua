--[[--
Add description.
module: platformer.Game

release: v2.0.0
license: MIT
author: [Gamedevaton](http://gamedevaton.com)
]]

local Map = require('phyzzle.map')
local Entity = require('phyzzle.entity')
local Player = require('example.platformer.entity.player')
local Elevator = require('example.platformer.entity.elevator')
local Renderer = require('example.platformer.renderer')

local Game = {
  --- The Game map.
  map = nil,
  --- The Game renderer.
  renderer = nil
}

--[[--
Create a new game state.

param: t optional table of overrides and initial state.
return: `Game` instance
]]
function Game:new(t)
  t = t or {}
  setmetatable(t, self)
  self.__index = self
  t:init()
  return t
end

--[[--
Initialize the Game state.

Sets the font, creates the map, adds entities and creates the renderer.

Called automatically by `Game:new`.
]]
function Game:init()
  love.graphics.setDefaultFilter('linear', 'nearest', 1)

  love.graphics.setFont(love.graphics.newImageFont('example/platformer/content/font.png',
    " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
    "0123456789.,!?-+/():;%&`'*#=[]\""))

  self.map = Map:new{ w = 600, h = 300, zs = 150 }
  self.renderer = Renderer:new{ map = self.map }

  -- add static walls
  self.map:add(Entity:new{ x = 0, y = 0, w = 600, h = 20, static = true })
  self.map:add(Entity:new{ x = 0, y = 280, w = 600, h = 20, static = true })
  self.map:add(Entity:new{ x = 0, y = 20, w = 20, h = 260, static = true })
  self.map:add(Entity:new{ x = 580, y = 20, w = 20, h = 260, static = true })

  -- add obstacles
  self.map:add(Entity:new{ x = 75, y = 230, w = 200, h = 50, static = true  })
  self.map:add(Entity:new{ x = 200, y = 100, w = 75, h = 20, static = true  })

  -- custom entity which overrides collision callback
  self.map:add(Elevator:new{ x = 350, y = 100, w = 175, h = 20 })

  -- custom player controlled entity
  self.map:add(Player:new{ x = 100, y = 100, w = 32, h = 50 })

  -- position the renderer for the first time
  self.renderer.x = (self.map.w - love.graphics.getWidth()) / 2
  self.renderer.y = (self.map.h - love.graphics.getHeight()) / 2
end

--[[--
Update the Game map.
]]
function Game:update()
  if love.keyboard.isDown('escape') then love.event.quit() end
  self.map:update(dt)
end

--[[--
Draw that Game map using the renderer.
]]
function Game:draw()
  self.renderer:draw()
end

return Game
