--[[--
The Phyzzle physics entity.

Has a location, dimension, acceleration and various states.

module: phyzzle.Entity

release: v2.0.0
license: MIT
author: [Gamedevaton](http://gamedevaton.com)
]]

local Entity = {
  --- x Location
  x = 0,

  --- y Location
  y = 0,

  --- Width
  w = 32,

  --- Height
  h = 32,

  --- x Acceleration
  xa = 0,

  --- y Acceleration
  ya = 0,

  --[[--
  State indicating if the entity is static or dynamic.

  Only dynamic entities update.

  Cannot be changed at runtime.
  ]]
  static = false,

  --[[--
  State indicating if the entity collides with others.

  Can be changed at runtime.
  ]]
  collider = true,

  --[[--
  State indicating if the entity is flagged for removal.

  To remove an entity set `remove`` = true`
  ]]
  remove = false
}

--[[--
Create a new entity.

A table of overrides and initial state can be provided.
`x`,`y`,`w`,`h`, `static` and `collider` can be overridden.

param: t Optional table of overrides and initial state.
return: `Entity` instance.
]]
function Entity:new(t)
  t = t or {}
  setmetatable(t, self)
  self.__index = self
  t:init()
  return t
end

--[[--
Initialize the map by creating any instance specific tables.

Called automatically by `Entity:new`.

Override in child entities to specify custom init functionality.
All init functions will always be called unlike other overriden functions.
]]
function Entity:init()
  self.zones = {}
end

--[[--
Map collision response.

Called when this entity collides with another.
The default collision response will touch the other entity.
To pass over an entity override this function in a child table
and remove the coollision response logic.

param: e2 The other entity.
param: dx Change in x.
param: dy Change in y.
]]
function Entity:collision(e2, dx, dy)
  if dy < 0 then
    self.y = e2.y + e2.h
    self.ya = 0
  elseif dy > 0 then
    self.y = e2.y - self.h
    self.ya = 0
  elseif dx < 0 then
    self.x = e2.x + e2.w
    self.xa = 0
  elseif dx > 0 then
    self.x = e2.x - self.w
    self.xa = 0
  end
end

--[[--
Map move response.

Called when this entity moves without colliding.

param: dx Change in x.
param: dy Change in y.
]]
function Entity:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

--[[--
Update the entity.

For predictable results use a fixed timestep and then dt can be ignored.
See the custom `love.run` function in `main`
for a fixed time step game loop implemenation.

param: dt Change in time or delta time.
]]
function Entity:update(dt)
end

--[[--
Draw the entity.

The default draw function does nothing.
Drawing can be implemented entirely in a separate renderer
or the renderer can be implemented to call the entity's draw function.
]]
function Entity:draw()
end

return Entity
