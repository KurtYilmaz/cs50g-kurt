--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(entity)
	self.entity = entity

	if self.entity.item == nil then
		self.entity:changeAnimation('walk-' .. self.entity.direction)
	else
		self.entity:changeAnimation('carry-' .. self.entity.direction)
	end

	-- used for AI control
	self.moveDuration = 0
	self.movementTimer = 0

	-- keeps track of whether we just hit a wall
	self.entity.bumped = false
end

function EntityWalkState:update(dt)
	if self.entity.health <= 0 then
		self.entity:changeState('idle')
		return
	end

	-- assume we didn't hit a wall
	self.entity.bumped = false

	if self.entity.direction == 'left' then
		self.entity.x = self.entity.x - self.entity.walkSpeed * dt

		if self.entity.x <= MAP_LEFT_EDGE then
			self.entity.x = MAP_LEFT_EDGE
			self.entity.bumped = true
		end
		if self.entity.y + self.entity.height > MAP_BOTTOM_EDGE then
			self.entity.y = MAP_BOTTOM_EDGE - self.entity.height
			self.entity.bumped = true
		end

	elseif self.entity.direction == 'right' then
		self.entity.x = self.entity.x + self.entity.walkSpeed * dt

		if self.entity.x + self.entity.width >= MAP_RIGHT_EDGE then
			self.entity.x = MAP_RIGHT_EDGE - self.entity.width
			self.entity.bumped = true
		end
		if self.entity.y + self.entity.height > MAP_BOTTOM_EDGE then
			self.entity.y = MAP_BOTTOM_EDGE - self.entity.height
			self.entity.bumped = true
		end

	elseif self.entity.direction == 'up' then
		self.entity.y = self.entity.y - self.entity.walkSpeed * dt

		if self.entity.y <= MAP_TOP_EDGE - self.entity.height / 2 then
			self.entity.y = MAP_TOP_EDGE - self.entity.height / 2
			self.entity.bumped = true
		end

	elseif self.entity.direction == 'down' then
		self.entity.y = self.entity.y + self.entity.walkSpeed * dt

		if self.entity.y + self.entity.height >= MAP_BOTTOM_EDGE then
			self.entity.y = MAP_BOTTOM_EDGE - self.entity.height
			self.entity.bumped = true
		end
	end

	self.entity:checkObjectCollisions(dt)

	self.entity.hitbox:move(self.entity.x, self.entity.y)
	self.entity.hurtbox:move(self.entity.x, self.entity.y)
end

function EntityWalkState:processAI(dt)
	local directions
	if self.moveDuration == 0 or self.entity.bumped then
		directions = {'left', 'right', 'up', 'down'}
		-- set an initial move duration and direction
		self.moveDuration = math.random(5)
		self.entity.direction = directions[math.random(#directions)]
		self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
		if self.entity.bumped then
			self.entity.bumped = false
		end
	elseif self.movementTimer > self.moveDuration then
		self.movementTimer = 0
		directions = {'left', 'right', 'up', 'down'}
		-- chance to go idle
		if math.random(3) == 1 then
			self.entity:changeState('idle')
		else
			self.moveDuration = math.random(5)
			self.entity.direction = directions[math.random(#directions)]
			self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
		end
	end

	self.movementTimer = self.movementTimer + dt
end

function EntityWalkState:render()
	if self.entity.item == nil then
		self.entity:changeAnimation('walk-' .. self.entity.direction)
	else
		self.entity:changeAnimation('carry-' .. self.entity.direction)
	end
	local anim = self.entity.currentAnimation
	love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
		math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
	-- AS5.2 - rendering lifted item
	if self.entity.item ~= nil then
		self.entity.item.x = self.entity.x
		self.entity.item.y = self.entity.y - self.entity.item.height/2
		self.entity.item:render(0, 0)
	end
end
