--[[
	GD50
	Breakout Remake

	-- Ball Class --

	Author: Kurt Yilmaz
	kurtyilmaz@ufl.edu

	Assignment 2.1

	"Add a Powerup class to the game that spawns a powerup (images located at the bottom of the sprite sheet in the distribution code).
	This Powerup should spawn randomly, be it on a timer or when the Ball hits a Block enough times, and gradually descend toward the player.
	Once collided with the Paddle, two more Balls should spawn and behave identically to the original, including all collision and scoring points for the player.
	Once the player wins and proceeds to the VictoryState for their current level, the Balls should reset so that there is only one active again.""
]]

-- AS2.1 - the Powerup class

Powerup = Class{}

function Powerup:init(x, y, keyValid)
	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0
	self.width = 16
	self.height = 16
	-- AS2.1 type
	if keyValid then
		self.type = 10
	else
		self.type = math.random(1, 9)
	end
	self.typeCount = 8
	self.collided = false
	-- AS2.1 -variables for the startup animation
	self.blinkTimer = 0
	self.startupTimer = 0
	self.visible = true

end

function Powerup:update(dt)
	if self.startupTimer < 3.4285 then
		self.startupTimer = self.startupTimer + dt
		self.blinkTimer = self.blinkTimer + dt
		-- AS2.1 Syncing the blink to the BPM of the music
		if self.blinkTimer > 0.4285 then
			self.blinkTimer = self.blinkTimer - 0.4285
			self.visible = not self.visible
		end
	else
		self.y = self.y + 1
	end
end

function Powerup:collides(target)
	-- first, check to see if the left edge of either is farther to the right
	-- than the right edge of the other
	if self.x > target.x + target.width or target.x > self.x + self.width then
		return false
	end

	-- then check to see if the bottom edge of either is higher than the top
	-- edge of the other
	if self.y > target.y + target.height or target.y > self.y + self.height then
		return false
	end

	-- if the above aren't true, they're overlapping
	return true
end

function Powerup:render()
	if self.visible then
		love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],
			self.x, self.y)
	end
end
