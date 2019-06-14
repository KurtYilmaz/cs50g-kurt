--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

EntityIdleState = Class{__includes = BaseState}

function EntityIdleState:init(entity)
	self.entity = entity

	if self.entity.item == nil then
		self.entity:changeAnimation('idle-' .. self.entity.direction)
	else
		self.entity:changeAnimation('hold-' .. self.entity.direction)
	end

	-- used for AI waiting
	self.waitDuration = 0
	self.waitTimer = 0
end

function EntityIdleState:processAI(dt)
	if self.waitDuration == 0 then
		self.waitDuration = math.random()
	else
		self.waitTimer = self.waitTimer + dt

		if self.waitTimer > self.waitDuration then
			self.entity:changeState('walk')
		end
	end
end

function EntityIdleState:render()
	if self.entity.item == nil then
		self.entity:changeAnimation('idle-' .. self.entity.direction)
	else
		self.entity:changeAnimation('hold-' .. self.entity.direction)
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
