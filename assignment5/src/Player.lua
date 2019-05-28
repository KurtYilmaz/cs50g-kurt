--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
	Entity.init(self, def)
	self:goInvulnerable(1.5)
end

function Player:update(dt)
	Entity.update(self, dt)
end

function Player:collides(target)
	-- Triggers for everything but doorways
	if target.room == nil then
		return not (self.hurtbox.x + self.hurtbox.width < target.x or self.hurtbox.x > target.x + target.width or
					self.hurtbox.y + self.hurtbox.height < target.y or self.hurtbox.y > target.y + target.height)

	-- Triggers for doorways only. Allows doorway logic to be separate from hurtboxes
	else
		return not (self.x + self.width < target.x or self.x > target.x + target.width or
					self.hurtbox.y + self.hurtbox.height < target.y or self.hurtbox.y > target.y + target.height)
	end
end

function Player:render()
	if gRenderHitboxes then
		self.hurtbox:render(0, 0, 255)
	end
	Entity.render(self)
	-- love.graphics.setColor(255, 0, 255, 255)
	-- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
	-- love.graphics.setColor(255, 255, 255, 255)
end
