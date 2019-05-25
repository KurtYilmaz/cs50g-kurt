--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Hitbox = Class{}

-- AS5.X - Allowed for assigning padding, so absolute coordinates are not needed at all times
function Hitbox:init(params)
	self.x = params.x
	self.y = params.y
	self.padX = params.padX
	self.padY = params.padY
	self.width = params.width
	self.height = params.height
end

-- Moves the hitbox with the entity it is attached to
function Hitbox:move(x, y)
	self.x = x + self.padX
	self.y = y + self.padY
end

-- AS5.X - debug rendering of hitboxes
-- If param is true, it's red, otherwise green
function Hitbox:render(red, green, blue)
	love.graphics.setColor(red, green, blue, 255)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255)

end
