--[[
	GD50
	Super Mario Bros. Remake

	-- SnailIdleState Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

SnailIdleState = Class{__includes = BaseState}

function SnailIdleState:init(tilemap, player, snail)
	self.tilemap = tilemap
	self.player = player
	self.snail = snail
	self.waitTimer = 0
	-- AS4.X - Support for multiple snail types
	if self.snail.type > 1 then
		self.frameMod = 4
	else
		self.frameMod = 0
	end
	self.animation = Animation {
		frames = {51 + self.frameMod},
		interval = 1
	}
	self.snail.currentAnimation = self.animation
end

function SnailIdleState:enter(params)
	self.waitPeriod = params.wait
end

function SnailIdleState:update(dt)
	self.snail:turnTimerUpdate(dt)
	if self.waitTimer < self.waitPeriod then
		self.waitTimer = self.waitTimer + dt
	else
		self.snail:changeState('moving')
	end

	-- calculate difference between snail and player on X axis
	-- and only chase if <= 5 tiles
	local diffX = math.abs(self.player.x - self.snail.x)

	if diffX < 5 * TILE_SIZE then
		self.snail:changeState('chasing')
	end
end
