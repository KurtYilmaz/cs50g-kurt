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

end

function GameObject:update(dt)

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
	love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
		self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end
