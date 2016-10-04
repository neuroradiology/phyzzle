
local Map = require('map')
local Entity = require('entity')
local Player = require('player')
local Renderer = require('renderer')

local map, renderer

function love.load(arg)
  love.graphics.setDefaultFilter('linear', 'nearest', 1)

  local chars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  chars = chars .. "0123456789.,!?-+/():;%&`'*#=[]\""

  font = love.graphics.newImageFont('content/font.png', chars)
  love.graphics.setFont(font)

  map = Map:new{ w = 800, h = 600, zs = 200 }
  renderer = Renderer:new{ map = map }

  -- static (non updating) walls
  map:add(Entity:new{ x = 0, y = 0, w = 800, h = 20, static = true })
  map:add(Entity:new{ x = 0, y = 580, w = 800, h = 20, static = true })
  map:add(Entity:new{ x = 0, y = 20, w = 20, h = 560, static = true })
  map:add(Entity:new{ x = 780, y = 20, w = 20, h = 560, static = true })

  -- boxes
  map:add(Entity:new{ x = 200, y = 400, w = 100, h = 100 })
  map:add(Entity:new{ x = 300, y = 275, w = 400, h = 50 })

  -- static non collider
  map:add(Entity:new{ x = 250, y = 100, w = 50, h = 50, static = true, collider = false })

  map:add(Player:new{ x = 100, y = 100, w = 32, h = 50 })

  -- demonstrate getting entities in a region
  local gets = map:get{ x = 40, y = 40, w = 600, h = 500 }

  for k,v in pairs(gets) do
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
