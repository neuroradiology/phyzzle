--[[--
A custom dynamic `phyzzle.Entity` which response to keyboard input
and can move left, right and jump.
Player is affected by gravity.

Extends `phyzzle.Entity`.

module: platformer.entity.Player

release: v2.0.0
license: MIT
author: [Gamedevaton](http://gamedevaton.com)

]]

local Entity = require('phyzzle.entity')

-- Inherit from the Entity table.
local Player = Entity:new()

--- String type value.
Player.type = 'player'

--- State indicating if the player is juming.
Player.jumping = false

--- State indicating if the jump key was pressed last update
Player.jumpPressed = false

--- Jump impulse.
Player.jump = 10

--- Gravity acceleration.
Player.gravity = 0.6

--- Movement velocity.
Player.speed = 5

--[[--
Override the Entity collision function.

Check for downward collision to set `jumping`` = false`.

param: e2 The other entity.
param: dx Change in x.
param: dy Change in y.
]]
function Player:collision(e2, dx, dy)
  -- call parent method (super)
  Entity.collision(self, e2, dx, dy)

  if dy > 0 then
    self.jumping = false
  end
end

--[[--
Override the Entity update function.

Check for key presses and attempt to move the player in the map.
]]
function Player:update()
  local dx = 0
  local dy = 0

  -- left
  if love.keyboard.isDown('a') then
    dx = -self.speed
  end

  -- right
  if love.keyboard.isDown('d') then
    dx = self.speed
  end

  -- jump acceleration
  local entities, n = self.map:get{ x = self.x, y = self.y + self.h, w = self.w, h = 10 }

  if love.keyboard.isDown('w') and not self.jumpPressed and not self.jumping and n > 0 then
    self.jumping = true
    self.ya = self.ya - self.jump
  end

  -- old jump key state
  self.jumpPressed = love.keyboard.isDown('w')

  -- gravity acceleration
  self.ya = self.ya + self.gravity

  dy = dy + self.ya

  self.map:move(self, dx, dy)
end

return Player
