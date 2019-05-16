--[[
	GD50
	Super Mario Bros. Remake

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

SnailChasingState = Class{__includes = BaseState}

function SnailChasingState:init(tilemap, player, snail)
	self.tilemap = tilemap
	self.player = player
	self.snail = snail
	-- AS4.X - Support for multiple snail types
	if self.snail.type > 1 then
		self.frameMod = 4
	else
		self.frameMod = 0
	end

	self.animation = Animation {
		frames = {49 + self.frameMod, 50 + self.frameMod},
		interval = 0.5
	}
	self.snail.currentAnimation = self.animation
	-- AS4.X - Frames of lag while turning to avoid jarring dash-dance.
end

function SnailChasingState:update(dt)
	self.snail.currentAnimation:update(dt)
	self.snail:turnTimerUpdate(dt)

	-- calculate difference between snail and player on X axis
	-- and only chase if <= 5 tiles
	local diffX = math.abs(self.player.x - self.snail.x)

	if diffX > 5 * TILE_SIZE then
		self.snail:changeState('moving')
	-- Turning snail around if player is behind them
elseif (self.player.x + self.player.width / 2 < self.snail.x + self.snail.width / 2 and self.snail.direction == 'right') or
		   (self.player.x + self.player.width / 2 > self.snail.x + self.snail.width / 2 and self.snail.direction == 'left') then
		self.snail:turn()
	end

	-- AS4.X - separated this logic to be seperate from snail turning logic
	if self.snail.direction == 'left' then
		self.snail.x = self.snail.x - SNAIL_MOVE_SPEED * self.snail.type * dt

		-- stop the snail if there's a missing tile on the floor to the left or a solid tile directly left
		local tileLeft = self.tilemap:pointToTile(self.snail.x, self.snail.y)
		local tileBottomLeft = self.tilemap:pointToTile(self.snail.x, self.snail.y + self.snail.height)

		if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
			self.snail.x = self.snail.x + SNAIL_MOVE_SPEED * self.snail.type * dt
		end
	elseif self.snail.direction == 'right' then
		self.snail.x = self.snail.x + SNAIL_MOVE_SPEED * self.snail.type * dt

		-- stop the snail if there's a missing tile on the floor to the right or a solid tile directly right
		local tileRight = self.tilemap:pointToTile(self.snail.x + self.snail.width, self.snail.y)
		local tileBottomRight = self.tilemap:pointToTile(self.snail.x + self.snail.width, self.snail.y + self.snail.height)

		if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
			self.snail.x = self.snail.x - SNAIL_MOVE_SPEED * self.snail.type * dt
		end
	end
end
