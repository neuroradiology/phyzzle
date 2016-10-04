
local Map = {
  -- map dimensions
  w = 800,
  h = 640,
  -- zone size
  zs = 128,
  -- counts
  entitiesCount = 0,
  updatersCount = 0,
  -- enums
  -- collision axis
  X = 1, Y = 2,
  -- collision direction
  UP = 1, DOWN = 2, LEFT = 3, RIGHT = 4
}

-- Create a new entity.
-- A table of overrides can be provided.
-- w,h,zs can be overridden.
function Map:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o:init()
  return o
end

-- Initialize the map by creating any instance specific tables
-- and initializing state.
function Map:init()
  -- all the entities
  self.entities = {}
  -- all the non static entities
  self.updaters = {}
  -- Axis Aligned Bounding Box (AABB)
  self.zones = {}

  -- zones dimensions
  -- calculated at initialization because zones dimensions and zone size
  -- can be supplied in new
  self.zw = math.ceil(self.w / self.zs)
  self.zh = math.ceil(self.h / self.zs)

  -- create empty zones
  for x = 0, self.zw - 1 do
    self.zones[x] = {}
    for y = 0, self.zh - 1 do
      self.zones[x][y] = {}
    end
  end
end

-- Add an entity to the map.
-- Specify whether the entity is static and therfore does not update.
-- Returns the entity.
function Map:add(e, static)
  -- zone the entity
  self:zone(e)
  e.map = self
  self.entities[e] = e
  self.entitiesCount = self.entitiesCount + 1

  -- if the entity is not static
  if not e.static then
    self.updaters[e] = e
    self.updatersCount = self.updatersCount + 1
  end

  return e
end

-- Get a zone region that encompasses the supplied object.
-- Object needs an x,y,w,h.
function Map:region(e)
  local x1 = math.floor((e.x - 0.1) / self.zs)
  if x1 < 0 then x1 = 0 end
  local y1 = math.floor((e.y - 0.1) / self.zs)
  if y1 < 0 then y1 = 0 end
  local x2 = math.floor((e.x + e.w + 0.1) / self.zs)
  if x2 > self.zw - 1 then x2 = self.zw - 1 end
  local y2 = math.floor((e.y + e.h + 0.1) / self.zs)
  if y2 > self.zh - 1 then y2 = self.zh - 1 end

  return x1, y1, x2, y2
end

-- Get a list of entities that intersect an object.
-- Object needs an x,y,w,h.
function Map:get(e1)
  local n = 0
  local entities = {}
  local x1, y1, x2, y2 = self:region(e1)

  for zx = x1, x2 do
    for zy = y1, y2 do
      for k, e2 in pairs(self.zones[zx][zy]) do
        -- if not flagged for removal
        if not e2.remove and
           -- collision check
           e1.x < e2.x + e2.w and e2.x < e1.x + e1.w and
           e1.y < e2.y + e2.h and e2.y < e1.y + e1.h then

          n = n + 1
          entities[k] = e2
        end
      end
    end
  end

  return entities, n
end

-- Add an entity to zones.
function Map:zone(e)
  local x1, y1, x2, y2 = self:region(e)

  for key, zone in pairs(e.zones) do
    zone[e] = nil
    e.zones[key] = nil
  end

  for zx = x1, x2 do
    for zy = y1, y2 do
      self.zones[zx][zy][e] = e
      e.zones[self.zones[zx][zy]] = self.zones[zx][zy]
    end
  end
end

-- Move an entity, checking for collisions.
-- Will either trigger the entity's move or collision response handler.
-- Movement is done one axis at a time, X first, Y second.
function Map:move(e, dx, dy)
  if not self:collision(e, dx, 0) then e:move(dx, 0) end
  if not self:collision(e, 0, dy) then e:move(0, dy) end
end

-- Check for a collision between an entity and others in its zones.
-- A new x, new y and collision axis need to be supplied.
-- Only set the appropriate new value that corresponds with the axis
-- and supply the existing value for the other.
-- See Map:move for an example.
-- Returns whether a collision was made.
function Map:collision(e1, dx, dy)
  -- does not collide
  if not e1.collider then return false end

  local checks = {}
  local collision = false
  local d = nil

  for k, zone in pairs(e1.zones) do
    for ek, e2 in pairs(zone) do
      -- if not the same entity and not flagged for removal
      if e1 ~= e2 and e2.collider and not e2.remove and not checks[e2] then
        -- flag that we have checked this entity
        -- as it could cross multiple zones
        checks[e2] = true

        -- collision check
        if e1.x + dx < e2.x + e2.w and e2.x < e1.x + dx + e1.w and
           e1.y + dy < e2.y + e2.h and e2.y < e1.y + dy + e1.h then

          collision = true
          e1:collision(e2, dx, dy)
        end
      end
    end
  end

  return collision
end

-- Update all the non static entities.
function Map:update(dt)
  for k, e in pairs(self.updaters) do
    -- if the entity has been flagged for removal
    if e.remove then
      -- remove it from lists
      self.entities[e] = nil
      self.updaters[e] = nil

      -- remove it from zones
      for key, zone in pairs(e.zones) do
        zone[e] = nil
        e.zones[key] = nil
      end
    else
      -- update and rezone to account for movement
      e:update(dt)
      self:zone(e)
    end
  end
end

return Map
