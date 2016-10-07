--[[--
Map

module: phyzzle.Map

release: v2.0.0
license: MIT
author: [Gamedevaton](http://gamedevaton.com)
]]

local Map = {
  --- Map width in pixels.
  w = 800,

  --- Map height in pixels.
  h = 640,

  --[[--
  The zone size, the width and height of a zone in pixels.

  A map will be divided in to a grid of zones
  to optimise collisions and renderering.
  ]]
  zs = 128,

  --- Total number of entities in the map.
  entitiesCount = 0,

  --- Total number of updating entities in the map.
  updatersCount = 0
}

--[[--
Create a new map.

-- `w`,`h`,`zs` can be overridden.

param: t Optional table of overrides and initial state.
return: `Map` instance.
]]
function Map:new(t)
  t = t or {}
  setmetatable(t, self)
  self.__index = self
  t:init()
  return t
end

--[[--
Initialize the map by creating the zones.

Called automatically by `Map:new`.

Override in child maps to specify custom init functionality.
All init functions will always be called unlike other overriden functions.
]]
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

--[[--
Add an entity to the map.

param: e The `Entity` to add.
return: The added `Entity`.
]]
function Map:add(e)
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

--[[--
Get a list of entities that intersect a AABB.

Useful for checking for collisions in specific places.

Every `Entity` is an AABB. A generic AABB needs an x,y,w,h.

param: t AABB to check for collisions.
return: `table` Table of entities indexed by `Entity` table key.
]]
function Map:get(t)
  local n = 0
  local entities = {}
  local x1, y1, x2, y2 = self:region(t)

  for zx = x1, x2 do
    for zy = y1, y2 do
      for k, e2 in pairs(self.zones[zx][zy]) do
        -- if not flagged for removal
        if not e2.remove and
           -- collision check
           t.x < e2.x + e2.w and e2.x < t.x + t.w and
           t.y < e2.y + e2.h and e2.y < t.y + t.h then

          n = n + 1
          entities[k] = e2
        end
      end
    end
  end

  return entities, n
end

--[[--
Move an entity in the map and check for collisions.

Will either trigger the entity's move or collision response handler.
Movement is done one axis at a time, X first, Y second.

param: e The `Entity` to move in the map.
param: dx The amount to move in the X axis.
param: dy The amount to move in the Y axis.
]]
function Map:move(e, dx, dy)
  if not self:collision(e, dx, 0) then e:move(dx, 0) end
  if not self:collision(e, 0, dy) then e:move(0, dy) end
end

--[[
Check for a collision between an entity and others in its zones.

Called automatically by 'Map:move' no need to call it manually.

The amount of movement in an axis needs to be provide.
Only provide one axis at a time and set the other to `0`.
See `Map:move` for example usage.

param: e The `Entity` to check collisions with.
param: dx The amount to move in the X axis.
param: dy The amount to move in the Y axis.
return: `boolean` Was there a collision.
]]
function Map:collision(e, dx, dy)
  -- does not collide
  if not e.collider then return false end

  local checks = {}
  local collision = false
  local d = nil

  for k, zone in pairs(e.zones) do
    for ek, e2 in pairs(zone) do
      -- if not the same entity and not flagged for removal
      if e ~= e2 and e2.collider and not e2.remove and not checks[e2] then
        -- flag that we have checked this entity
        -- as it could cross multiple zones
        checks[e2] = true

        -- collision check
        if e.x + dx < e2.x + e2.w and e2.x < e.x + dx + e.w and
           e.y + dy < e2.y + e2.h and e2.y < e.y + dy + e.h then

          collision = true
          e:collision(e2, dx, dy)
        end
      end
    end
  end

  return collision
end


--[[--
Update `Entity.zones` base on the new location.

Called automatically by `Map:add`.
Needs to be called after manually setting an `Entity` locaiton `x` or `y`.
You only have to manually set an Entity location
if you want to avoid collision checks.

param: e The `Entity to zone.
]]
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

--[[--
Update all dynamic entities.

If an entity is flagged for removal it is removed.

param: dt Change in time or delta time.
]]
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
      e:update(dt)
      self:zone(e)
    end
  end
end


--[[--
Get a zone region that encompasses the supplied AABB.
The AABB needs an x,y,w,h.

Useful for creating viewport based renderers
or querying sections of the map.

param: t AABB zones need to cover.
return: x1 The top-left zone's x location.
return: y1 The top-left zone's y location.
return: x1 The bottom-right zone's x location.
return: y1 The bottom-right zone's y location.
]]
function Map:region(t)
  local x1 = math.floor((t.x - 0.1) / self.zs)
  if x1 < 0 then x1 = 0 end
  local y1 = math.floor((t.y - 0.1) / self.zs)
  if y1 < 0 then y1 = 0 end
  local x2 = math.floor((t.x + t.w + 0.1) / self.zs)
  if x2 > self.zw - 1 then x2 = self.zw - 1 end
  local y2 = math.floor((t.y + t.h + 0.1) / self.zs)
  if y2 > self.zh - 1 then y2 = self.zh - 1 end

  return x1, y1, x2, y2
end

return Map
