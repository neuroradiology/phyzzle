
local Entity = require('entity')

-- Inherit from the Entity table.
local Platform = Entity:new()

Platform.type = 'platform'

Platform.travel = 150
Platform.speed = 70
Platform.direction = -1

function Platform:init()
  -- starting x and y
  self.sx = self.x
  self.sy = self.y
end

-- Override the Entity collision function.
-- Check for downward collision to set the grounded flag.
function Platform:collision(e2, dx, dy)
  local y = self.y

  if dy < 0 then
    if not e2.static then
      self.y = y + dy
      e2.y = self.y - e2.h - 0.1
      self.map:zone(e2)
    end
  elseif dy > 0 then
    self.y = e2.y - self.h
  end

end

-- Override the Entity update function.
-- Check for key presses and attempt to move the Platform in the map.
-- Uses default Entity collision and move response handlers.
function Platform:update(dt)
  if self.y > self.sy + self.travel then
    self.direction = -1
  end

  if self.y < self.sy then
    self.direction = 1
  end

  local dy = self.direction * self.speed * dt

  self.map:move(self, 0, dy)
end

return Platform
