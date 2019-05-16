--[[
	GD50
	Super Mario Bros. Remake

	-- Entity Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Entity = Class{}

function Entity:init(def)
	-- position
	self.x = def.x
	self.y = def.y

	-- velocity
	self.dx = 0
	self.dy = 0

	-- dimensions
	self.width = def.width
	self.height = def.height

	self.texture = def.texture
	self.stateMachine = def.stateMachine

	self.direction = 'left'

	-- reference to tile map so we can check collisions
	self.map = def.map

	-- reference to level for tests against other entities + objects
	self.level = def.level

	-- AS4.X - Adding ability for multiple types of enemies
	self.type = def.type
	self.scoreMod = def.scoreMod

	-- AS4.X - Adding HP element
	self.hp = self.type

	-- AS4.X - Adding an entity ID
	self.id = def.id
end

function Entity:changeState(state, params)
	self.stateMachine:change(state, params)
end

function Entity:update(dt)
	self.stateMachine:update(dt)
end

function Entity:collides(entity)
	return not (self.x > entity.x - 2 + entity.width or entity.x + 2 > self.x + self.width or
				self.y > entity.y - 2 + entity.height or entity.y + 2 > self.y + self.height)
end

function Entity:render()
	love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
		math.floor(self.x) + 8, math.floor(self.y) + 10, 0, self.direction == 'right' and 1 or -1, 1, 8, 10)
end
