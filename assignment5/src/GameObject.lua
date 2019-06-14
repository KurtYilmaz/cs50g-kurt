--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
	-- string identifying this object type
	self.type = def.type

	self.texture = def.texture
	self.frame = def.frame or 1

	-- whether it acts as an obstacle or not
	self.solid = def.solid

	self.defaultState = def.defaultState
	self.state = self.defaultState
	self.states = def.states

	-- dimensions
	self.x = x
	self.y = y
	self.width = def.width
	self.height = def.height

	-- AS5.1 - Can define onCollide
	-- (also can be a placeholder for later definition)
	if def.onCollide == nil then
		self.onCollide = function(player) end
	else
		self.onCollide = def.onCollide
	end

	-- AS5.1 - tells Room to consume object (specify in onCollide)
	self.consumed = false

	-- AS5.2 - tells if object is liftable
	self.liftable = def.liftable

	-- AS5.3 - for explosion effect
	self.exploded = false
	self.color_primary = def.color_primary
	self.color_secondary = def.color_secondary
	self.fireDirection = nil
	self.timeExploded = 0
	self.dx = 0
	self.dy = 0
	self.targetX = 0
	self.targetY = 0
	self.fired = false
	-- Primary and secondary colors don't need to be there for non-projectiles
	self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 50)
	self.psystem:setParticleLifetime(3, 4)
	self.psystem:setEmitterLifetime(3)
	self.psystem:setEmissionRate(50)
	self.psystem:setAreaSpread('uniform', 1, 1)
	self.psystem:setLinearAcceleration(-1, -1, 1, 1)
	-- Colors of the pot
	if self.color_primary ~= nil and self.color_secondary ~= nil then
		self.psystem:setColors(self.color_secondary[1], self.color_secondary[2],
							self.color_secondary[3], 255, self.color_primary[1],
							self.color_primary[2], self.color_primary[3], 255)
	else
		self.psystem:setColors(0, 0, 255, 255, 255, 0, 255, 255)
	end

end

function GameObject:update(dt)
	-- AS5.3 - we don't have to check x and Y both, because it will be a
	-- straight line to the target
	if self.fired then
		if not self.exploded then
			if self.fireDirection ~= 'up' and self.y >= self.targetY then
				self:explode()
			elseif self.fireDirection == 'up' and self.y <= self.targetY then
				self:explode()
			else
				self.x = self.x + self.dx * dt
				self.y = self.y + self.dy * dt
			end
		else
			self.psystem:update(dt)
			self.timeExploded = self.timeExploded + dt
		end
	end
end

function GameObject:fire(direction, destX, destY, speed)
	self.fired = true
	self.fireDirection = direction
	self.targetX = destX
	self.targetY = destY
	self.dx = (self.targetX - self.x) * speed
	self.dy = (self.targetY - self.y) * speed
end

function GameObject:explode()
	self.exploded = true
	self.psystem:emit(50)
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
	if self.exploded then
		love.graphics.draw(self.psystem, self.x + self.width/2, self.y + self.height/2)
	else
		love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
			self.x + adjacentOffsetX, self.y + adjacentOffsetY)
	end
end
