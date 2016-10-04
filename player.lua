
local Entity = require('entity')

-- Inherit from the Entity table.
local Player = Entity:new()

Player.type = 'player'

-- are we currently jumping
Player.jumping = false
-- was the jump key pressed last update
Player.jumpPressed = false

-- acceleration
Player.jump = 550
Player.gravity = 40

-- speed
Player.speed = 300

function Player:init()
end

-- Override the Entity collision function.
-- Check for downward collision to set the grounded flag.
function Player:collision(e2, dx, dy)
  -- call parent method (super)
  Entity.collision(self, e2, dx, dy)

  if dy > 0 then
    self.jumping = false
  end
end

-- Override the Entity update function.
-- Check for key presses and attempt to move the player in the map.
-- Uses default Entity collision and move response handlers.
function Player:update(dt)
  local dx = 0
  local dy = 0

  -- left
  if love.keyboard.isDown('a') then
    dx = -self.speed * dt
  end

  -- right
  if love.keyboard.isDown('d') then
    dx = self.speed * dt
  end

  -- jump acceleration
  local entities, n = self.map:get{ x = self.x, y = self.y + self.h, w = self.w, h = 10 }

  if love.keyboard.isDown('w') and not self.jumpPressed and not self.jumping and n > 0 then
    self.jumping = true
    self.ya = self.ya - self.jump * dt
  end

  -- old jump key state
  self.jumpPressed = love.keyboard.isDown('w')

  -- gravity acceleration
  self.ya = self.ya + self.gravity * dt

  dy = dy + self.ya

  self.map:move(self, dx, dy)
end

return Player
