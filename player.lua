
local Entity = require('entity')

-- Inherit from the Entity table.
local Player = Entity:new()

Player.speed = 400

function Player:init()
end

-- Override the Entity update function.
-- Check for key presses and attemp to move the player in the map.
-- Uses default Entity collision and move response handlers.
function Player:update(dt)
  local x = self.x
  local y = self.y

  if love.keyboard.isDown('w') then y = self.y - self.speed * dt end
  if love.keyboard.isDown('s') then y = self.y + self.speed * dt end
  if love.keyboard.isDown('a') then x = self.x - self.speed * dt end
  if love.keyboard.isDown('d') then x = self.x + self.speed * dt end

  self.map:move(self, x, y)
end

return Player
