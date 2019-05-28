--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
	-- render offset for spaced character sprite
	self.entity.offsetY = 5
	self.entity.offsetX = 0
	self.entity.idle = true
end

function PlayerIdleState:update(dt)
	EntityIdleState.update(self, dt)
end

function PlayerIdleState:update(dt)
	if love.keyboard.isDown(PLAYER_LEFT) or love.keyboard.isDown(PLAYER_RIGHT) or
	   love.keyboard.isDown(PLAYER_UP) or love.keyboard.isDown(PLAYER_DOWN) then
		self.entity:changeState('walk')
	end

	if love.keyboard.wasPressed(PLAYER_ATTACK) then
		self.entity:changeState('swing-sword')
	end
end
