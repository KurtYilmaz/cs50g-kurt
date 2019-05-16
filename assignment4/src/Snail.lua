--[[
	GD50
	Super Mario Bros. Remake

	-- Snail Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Snail = Class{__includes = Entity}

function Snail:init(def)
	Entity.init(self, def)
	-- AS4.X - Slowing down turning animation to reduce rapid change in direction
	self.turnLag = SNAIL_TURN_LAG
	self.turnTimer = SNAIL_TURN_LAG
	self.isTurning = false
end

-- AS4.X - Global snail turn lag

function Snail:render()
	love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
		math.floor(self.x) + 8, math.floor(self.y) + 8, 0, self.direction == 'left' and 1 or -1, 1, 8, 10)
end

function Snail:turn()
	if self.isTurning == false then
		self.isTurning = true
		if self.direction == 'left' then
			self.direction = 'right'
		else
			self.direction = 'left'
		end
		return true
	else
		return false
	end
end

function Snail:turnTimerUpdate(dt)
	if self.isTurning == true then
		self.turnTimer = self.turnTimer - dt
		if self.turnTimer <= 0 then
			self.turnTimer = SNAIL_TURN_LAG
			self.isTurning  = false
		end
	end
end
