
local Map = require('map')
local Entity = require('entity')
local Player = require('player')
local Platform = require('platform')
local Renderer = require('renderer')

local map, renderer

function love.load(arg)
  love.graphics.setDefaultFilter('linear', 'nearest', 1)

  local chars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  chars = chars .. "0123456789.,!?-+/():;%&`'*#=[]\""

  font = love.graphics.newImageFont('content/font.png', chars)
  love.graphics.setFont(font)

  map = Map:new{ w = 600, h = 300, zs = 150 }
  renderer = Renderer:new{ map = map }

  -- static (non updating) walls
  map:add(Entity:new{ x = 0, y = 0, w = 600, h = 20, static = true })
  map:add(Entity:new{ x = 0, y = 280, w = 600, h = 20, static = true })
  map:add(Entity:new{ x = 0, y = 20, w = 20, h = 260, static = true })
  map:add(Entity:new{ x = 580, y = 20, w = 20, h = 260, static = true })

  -- boxes
  map:add(Entity:new{ x = 75, y = 230, w = 200, h = 50 })
  map:add(Entity:new{ x = 200, y = 100, w = 75, h = 20 })

  -- static non collider
  map:add(Entity:new{ x = 500, y = 50, w = 50, h = 50, static = true, collider = false })

  -- custom entity
  map:add(Platform:new{ x = 350, y = 100, w = 175, h = 20 })

  -- custom player controlled entity
  map:add(Player:new{ x = 100, y = 100, w = 32, h = 50 })

  -- demonstrate getting entities in a region
  local entities, n = map:get{ x = 40, y = 40, w = 600, h = 500 }

  for k,v in pairs(entities) do
    print(v.x, v.y, v.w, v.h)
  end

  -- position the renderer for the first time
  love.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function love.resize(w, h)
  renderer.x = (map.w - love.graphics.getWidth()) / 2
  renderer.y = (map.h - love.graphics.getHeight()) / 2
end

function love.update(dt)
  if love.keyboard.isDown('escape') then love.event.quit() end

  map:update(dt)
end

function love.draw()
  renderer:draw(map)
end
