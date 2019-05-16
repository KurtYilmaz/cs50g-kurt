--[[
	GD50
	Super Mario Bros. Remake

	-- Player Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
	Entity.init(self, def)
	self.score = def.score
	-- If player has a key (number refers to color frame)
	self.key = 0
	-- If player has a flag (number refers to color frame)
	self.goal = 0
	-- If player is set to win
	self.victory = false
	-- If player gets a game over
	self.gameOver = false
	-- List of enemies killed for score screens
	self.killCount = {0, 0}
	-- AS4.X - accomodating different speeds
	self.speed = PLAYER_WALK_SPEED
end

function Player:update(dt)
	Entity.update(self, dt)

	-- AS4.X - Adding ability to run
	if love.keyboard.isDown(PLAYER_RUN) then
		self.speed = PLAYER_RUN_SPEED
	else
		self.speed = PLAYER_WALK_SPEED
	end
end

function Player:render()
	Entity.render(self)
end

function Player:checkLeftCollisions(dt)
	-- check for left two tiles collision
	local tileTopLeft = self.map:pointToTile(self.x + 3, self.y + 3)
	local tileBottomLeft = self.map:pointToTile(self.x + 3, self.y + self.height - 3)

	-- place player outside the X bounds on one of the tiles to reset any overlap
	if (tileTopLeft and tileBottomLeft) and (tileTopLeft:collidable() or tileBottomLeft:collidable()) then
		self.x = (tileTopLeft.x - 1) * TILE_SIZE + tileTopLeft.width - 3
	else

		self.y = self.y - 1
		local collidedObjects = self:checkObjectCollisions()
		self.y = self.y + 1

		-- reset X if new collided object
		if #collidedObjects > 0 then
			self.x = self.x + self.speed * dt
		end
	end
end

function Player:checkRightCollisions(dt)
	-- check for right two tiles collision
	local tileTopRight = self.map:pointToTile(self.x + self.width - 3, self.y + 3)
	local tileBottomRight = self.map:pointToTile(self.x + self.width - 3, self.y + self.height - 3)

	-- place player outside the X bounds on one of the tiles to reset any overlap
	if (tileTopRight and tileBottomRight) and (tileTopRight:collidable() or tileBottomRight:collidable()) then
		self.x = (tileTopRight.x - 1) * TILE_SIZE - self.width + 3
	else

		self.y = self.y - 1
		local collidedObjects = self:checkObjectCollisions()
		self.y = self.y + 1

		-- reset X if new collided object
		if #collidedObjects > 0 then
			self.x = self.x - self.speed * dt
		end
	end
end

function Player:checkObjectCollisions()
	local collidedObjects = {}

	for k, object in pairs(self.level.objects) do
		if object:collides(self) then
			if object.collidable then
				table.insert(collidedObjects, object)
			end
			-- AS4.2 - allowing for object to be both collidable and consumable
			if object.consumable then
				object.onConsume(self, object)
				table.remove(self.level.objects, k)
			end
		end
	end

	return collidedObjects
end
