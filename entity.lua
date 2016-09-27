
local Entity = {
  -- position
  x = 0,
  y = 0,
  -- dimensions
  w = 32,
  h = 32,
  -- does this entity update
  static = false,
  -- is the entity flagged for removal
  remove = false
}

-- Create a new entity.
-- A table of overrides can be provided.
-- x,y,w,h,static can be overridden.
function Entity:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o:init()
  return o
end

-- Initialize the map by creating any instance specific tables.
function Entity:init()
  self.zones = {}
end

-- Map collision response.
-- Called when this entity collides with another.
-- The default collision response will touch the other entity.
function Entity:collision(e2, nx, ny, direction)
  if direction == self.map.UP then
    self.y = e2.y + e2.h
    self.ya = 0
  elseif direction == self.map.DOWN then
    self.y = e2.y - self.h
    self.ya = 0
  elseif direction == self.map.LEFT then
    self.x = e2.x + e2.w
    self.xa = 0
  elseif direction == self.map.RIGHT then
    self.x = e2.x - self.w
    self.xa = 0
  end
end

-- Map move response.
-- Called when this entity moves without colliding.
function Entity:move(nx, ny)
  self.x = nx
  self.y = ny
end

-- Update entity.
-- See Player:update for an example.
function Entity:update(dt)
end

return Entity
