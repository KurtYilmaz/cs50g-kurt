--[[
	GD50
	Super Mario Bros. Remake

	-- SnailMovingState Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

SnailMovingState = Class{__includes = BaseState}

function SnailMovingState:init(tilemap, player, snail)
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

	self.snail.direction = math.random(2) == 1 and 'left' or 'right'
	self.movingDuration = math.random(5)
	self.movingTimer = 0
end

function SnailMovingState:update(dt)
	self.snail:turnTimerUpdate(dt)
	self.movingTimer = self.movingTimer + dt
	self.snail.currentAnimation:update(dt)

	-- reset movement direction and timer if timer is above duration
	if self.movingTimer > self.movingDuration then

		-- chance to go into idle state randomly
		if math.random(4) == 1 then
			self.snail:changeState('idle', {

				-- random amount of time for snail to be idle
				wait = math.random(5)
			})
		else
			self.snail.direction = math.random(2) == 1 and 'left' or 'right'
			self.movingDuration = math.random(5)
			self.movingTimer = 0
		end
	elseif self.snail.direction == 'left' then
		self.snail.x = self.snail.x - SNAIL_MOVE_SPEED * self.snail.type * dt

		-- stop the snail if there's a missing tile on the floor to the left or a solid tile directly left
		local tileLeft = self.tilemap:pointToTile(self.snail.x, self.snail.y)
		local tileBottomLeft = self.tilemap:pointToTile(self.snail.x, self.snail.y + self.snail.height)

		if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
			self.snail.x = self.snail.x + SNAIL_MOVE_SPEED * self.snail.type * dt

			-- reset direction if we hit a wall
			-- AS4.X - turning function to prevent rapid snail turns
			self.snail:turn()
			self.movingDuration = math.random(5)
			self.movingTimer = 0
		end
	else
		self.snail.direction = 'right'
		self.snail.x = self.snail.x + SNAIL_MOVE_SPEED * self.snail.type * dt

		-- stop the snail if there's a missing tile on the floor to the right or a solid tile directly right
		local tileRight = self.tilemap:pointToTile(self.snail.x + self.snail.width, self.snail.y)
		local tileBottomRight = self.tilemap:pointToTile(self.snail.x + self.snail.width, self.snail.y + self.snail.height)

		if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
			self.snail.x = self.snail.x - SNAIL_MOVE_SPEED * self.snail.type * dt

			-- reset direction if we hit a wall
			-- AS4.X - turning function to prevent rapid snail turns
			self.snail:turn()
			self.movingDuration = math.random(5)
			self.movingTimer = 0
		end
	end

	-- calculate difference between snail and player on X axis
	-- and only chase if <= 5 tiles
	local diffX = math.abs(self.player.x - self.snail.x)

	if diffX < 5 * TILE_SIZE then
		self.snail:changeState('chasing')
	end
end
