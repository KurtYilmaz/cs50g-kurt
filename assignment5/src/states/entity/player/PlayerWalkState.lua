--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

PlayerWalkState = Class{__includes = EntityWalkState}

function PlayerWalkState:init(player, dungeon)
	self.entity = player
	self.dungeon = dungeon
	-- AS5.2 - needs room to go with EntityWalkState
	self.entity.room = dungeon.currentRoom

	-- render offset for spaced character sprite
	self.entity.offsetY = 5
	self.entity.offsetX = 0

	self.entity.idle = false
	self.entity.directionHit = 'none'
end

function PlayerWalkState:update(dt)
	if love.keyboard.isDown(PLAYER_LEFT) then
		self.entity.direction = 'left'
	elseif love.keyboard.isDown(PLAYER_RIGHT) then
		self.entity.direction = 'right'
	elseif love.keyboard.isDown(PLAYER_UP) then
		self.entity.direction = 'up'
	elseif love.keyboard.isDown(PLAYER_DOWN) then
		self.entity.direction = 'down'
	else
		self.entity:changeState('idle')
	end

	-- perform base collision detection against walls
	EntityWalkState.update(self, dt)

	-- if we bumped something when checking collision, check any object collisions
	if self.bumped then
		if self.entity.direction == 'left' then

			-- temporarily adjust position
			self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt

			for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
				if self.entity:collides(doorway) and doorway.open then

					-- shift entity to center of door to avoid phasing through wall
					self.entity.y = doorway.y + 4
					Event.dispatch('shift-left')
				end
			end

			-- readjust
			self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
		elseif self.entity.direction == 'right' then

			-- temporarily adjust position
			self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt

			for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
				if self.entity:collides(doorway) and doorway.open then

					-- shift entity to center of door to avoid phasing through wall
					self.entity.y = doorway.y + 4
					Event.dispatch('shift-right')
				end
			end

			-- readjust
			self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
		elseif self.entity.direction == 'up' then

			-- temporarily adjust position
			self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt

			for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
				if self.entity:collides(doorway) and doorway.open then

					-- shift entity to center of door to avoid phasing through wall
					self.entity.x = doorway.x + 8
					Event.dispatch('shift-up')
				end
			end

			-- readjust
			self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
		else

			-- temporarily adjust position
			self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt

			for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
				if self.entity:collides(doorway) and doorway.open then

					-- shift entity to center of door to avoid phasing through wall
					self.entity.x = doorway.x + 8
					Event.dispatch('shift-down')
				end
			end

			-- readjust
			self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
		end
	end
end

function PlayerWalkState:action()
	if self.entity.item == nil then
		self.entity:changeState('swing-sword')
	else
		self.entity:changeState('throw')
	end
end
