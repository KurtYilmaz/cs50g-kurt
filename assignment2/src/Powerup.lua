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
	self.width = 16
	self.height = 16
	self.typeCount = 8

	-- used to determine whether this powerup should be rendered
	self.inPlay = true

	-- AS2.1 - adding ability to have multiple types
	-- AS3.1 - key will only spawn if locked brick exists
	self.type = math.random(0, 8 + keyValid);

	-- Decided that particles with the powerup may be confusing
end

function Powerup:collides(target)




end

function Powerup:update(dt)
	-- Needs velocity
end

function Powerup:render()
	if self.inPlay then
		love.graphics.draw(gTextures['main'],
			-- multiply color by 4 (-1) to get our color offset, then add tier to that
			-- to draw the correct tier and color powerup onto the screen
			gFrames['powerups'][1 + ((self.color - 1) * 4) + self.tier],
			self.x, self.y)
	end
end

function Powerup:effect()
	-- Effects can be listed here
end
