--[[
	GD50
	Super Mario Bros. Remake

	-- PlayerFallingState Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

PlayerFallingState = Class{__includes = BaseState}

function PlayerFallingState:init(player, gravity)
	self.player = player
	self.gravity = gravity
	self.animation = Animation {
		frames = {3},
		interval = 1
	}
	self.player.currentAnimation = self.animation
end

function PlayerFallingState:enter(params)
	self.xMomentum = params.xMomentum
	self.player.speed = self.xMomentum
end

function PlayerFallingState:update(dt)
	self.player.currentAnimation:update(dt)
	self.player.dy = self.player.dy + self.gravity
	self.player.y = self.player.y + (self.player.dy * dt)

	-- look at two tiles below our feet and check for collisions
	local tileBottomLeft = self.player.map:pointToTile(self.player.x + 4, self.player.y + self.player.height)
	local tileBottomRight = self.player.map:pointToTile(self.player.x + self.player.width - 4, self.player.y + self.player.height)

	-- if we get a collision beneath us, go into either walking or idle
	if (tileBottomLeft and tileBottomRight) and (tileBottomLeft:collidable() or tileBottomRight:collidable()) then
		self.player.dy = 0

		-- set the player to be walking or idle on landing depending on input
		if love.keyboard.isDown(PLAYER_LEFT) or love.keyboard.isDown(PLAYER_RIGHT) then
			self.player:changeState('walking')
		else
			self.player:changeState('idle')
		end

		self.player.y = (tileBottomLeft.y - 1) * TILE_SIZE - self.player.height

	-- go back to start if we fall below the map boundary
	elseif self.player.y > VIRTUAL_HEIGHT then
		self.player.gameOver = true
		self.player:changeState('death')
	-- check side collisions and reset position
	elseif love.keyboard.isDown(PLAYER_LEFT) then
		self.player.direction = 'left'
		self.player.x = self.player.x - self.xMomentum * dt
		self.player:checkLeftCollisions(dt)
	elseif love.keyboard.isDown(PLAYER_RIGHT) then
		self.player.direction = 'right'
		self.player.x = self.player.x + self.xMomentum * dt
		self.player:checkRightCollisions(dt)
	end

	-- check if we've collided with any collidable game objects
	for k, object in pairs(self.player.level.objects) do
		if object:collides(self.player) then
			if object.collidable then
				self.player.dy = 0
				self.player.y = object.y - self.player.height

				if love.keyboard.isDown(PLAYER_LEFT) or love.keyboard.isDown(PLAYER_RIGHT) then
					self.player:changeState('walking')
				else
					self.player:changeState('idle')
				end
			end
			-- AS4.2 - allowing for object to be both collidable and consumable
			if object.consumable then
				object.onConsume(self.player, object)
				table.remove(self.player.level.objects, k)
			end
		end
	end

	-- check if we've collided with any entities and kill them if so
	for k, entity in pairs(self.player.level.entities) do
		if entity:collides(self.player) then
			gSounds['kill']:play()
			if entity.hp == 1 then
				gSounds['kill2']:play()
				self.player.score = self.player.score + 100 * entity.scoreMod
				if entity.id == 'snail1' then
					self.player.killCount[1] = self.player.killCount[1] + 1
				elseif entity.id == 'snail2' then
					self.player.killCount[2] = self.player.killCount[2] + 1
				end
				table.remove(self.player.level.entities, k)
			else
				entity.hp = entity.hp - 1
				self.player.y = self.player.y - 1
			end

			self.player:changeState('jump', {heightMod = PLAYER_JUMP_VELOCITY / 2, xMomentum = self.xMomentum})
		end
	end
end
