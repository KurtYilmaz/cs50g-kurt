--[[
	GD50
	Super Mario Bros. Remake

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
	self.player = player

	self.animation = Animation {
		frames = {1},
		interval = 1
	}

	self.player.currentAnimation = self.animation
end

function PlayerIdleState:update(dt)

	-- AS4.X - player victory state
	if self.player.victory then
		self.player:changeState('victory')
	end

	if love.keyboard.isDown(PLAYER_LEFT) or love.keyboard.isDown(PLAYER_RIGHT) then
		self.player:changeState('walking')
	end

	if love.keyboard.wasPressed('space') then
		self.player:changeState('jump', {heightMod = 0, xMomentum = PLAYER_WALK_SPEED})
	end

	-- check if we've collided with any entities and die if so
	for k, entity in pairs(self.player.level.entities) do
		if entity:collides(self.player) then
			self.player.gameOver = true
			self.player:changeState('death')
		end
	end
end
