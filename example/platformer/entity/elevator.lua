--[[--
A custom dynamic `phyzzle.Entity` which moves up and down
and lifts other dynamic entities.

Extends `phyzzle.Entity`.

module: platformer.entity.Elevator

release: v2.0.0
license: MIT
author: [Gamedevaton](http://gamedevaton.com)
]]

local Entity = require('phyzzle.entity')

-- Inherit from the Entity table.
local Elevator = Entity:new()

--- String type value.
Elevator.type = 'elevator'

--- Travel distance.
Elevator.travel = 150

--- Travel speed.
Elevator.speed = 0.7

--- Travel direction.
Elevator.direction = -1

--- Starting x location.
Elevator.sx = 0

--- Starting y location.
Elevator.sy = 0

--[[--
Initialize the Elevator.

Records the starting position.

Called automatically by `Entity:new`.
]]
function Elevator:init()
  self.sx = self.x
  self.sy = self.y
end

--[[--
Override the `phyzzle.Entity:collision` function.

If moving upward checks and the other `Entity` is dynamic
`phyzzle.Entity.static`` = false` then move the entity else touch the entity.

param: e2 The other entity.
param: dx Change in x.
param: dy Change in y.
]]
function Elevator:collision(e2, dx, dy)
  -- moving up
  if dy < 0 then
    -- lift dynamic entities
    if not e2.static then
      -- new y if pushed completely
      local ny = (self.y + dy) - e2.h
      -- move e2 the distance of current y - new y
      -- check for collisions
      self.map:move(e2, 0, ny - e2.y)
      -- move the elevator to just below where e2 moved
      self.y = e2.y + e2.h
    else
      -- touch static
      self.y = e2.y + self.h
    end
  -- moving down
  elseif dy > 0 then
    -- touch
    self.y = e2.y - self.h
  end
end

--[[--
Override the Entity update function.
]]
function Elevator:update(dt)
  -- if traveled past the distance change direction
  if self.y > self.sy + self.travel then
    self.direction = -1
  end

  -- if traveled past the start change direction
  if self.y < self.sy then
    self.direction = 1
  end

  local dy = self.direction * self.speed

  self.map:move(self, 0, dy)
end

return Elevator
