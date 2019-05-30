--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

PlayerSwingSwordState = Class{__includes = BaseState}

function PlayerSwingSwordState:init(player, dungeon)
	self.player = player
	self.dungeon = dungeon

	-- render offset for spaced character sprite
	self.player.offsetY = 5
	self.player.offsetX = 8

	-- create hitbox based on where the player is and facing
	local direction = self.player.direction

	local padX, padY, hitboxWidth, hitboxHeight

	if direction == 'left' then
		hitboxWidth = 10
		hitboxHeight = 18
		padX = -hitboxWidth + self.player.hurtbox.padX
		padY = 2
	elseif direction == 'right' then
		hitboxWidth = 10
		hitboxHeight = 18
		padX = self.player.hurtbox.width
		padY = 2
	elseif direction == 'up' then
		hitboxWidth = 18
		hitboxHeight = 10
		padX = -2
		padY = -hitboxHeight + self.player.hurtbox.padY - 1
	else
		hitboxWidth = 19
		hitboxHeight = 10
		padX = -2
		padY = self.player.height - 2
	end

	self.swordHitbox = Hitbox {
		padX = padX,
		padY = padY,
		height = hitboxHeight,
		width = hitboxWidth
	}
	self.swordHitbox:move(self.player.x, self.player.y)
	self.player:changeAnimation('sword-' .. self.player.direction)
end

function PlayerSwingSwordState:enter(params)
	gSounds['sword']:setVolume(0.6)
	gSounds['sword']:stop()
	gSounds['sword']:play()

	-- restart sword swing animation
	self.player.currentAnimation:refresh()
end

function PlayerSwingSwordState:update(dt)
	self.swordHitbox:move(self.player.x, self.player.y)
	-- check if hitbox collides with any entities in the scene
	for k, entity in pairs(self.dungeon.currentRoom.entities) do
		if entity:collides(self.swordHitbox) and not entity.dead then
			if self.player.direction == 'left' then
				entity.directionHit = 'right'
			elseif self.player.direction == 'right' then
				entity.directionHit = 'left'
			elseif self.player.direction == 'up' then
				entity.directionHit = 'down'
			elseif self.player.direction == 'down' then
				entity.directionHit = 'up'
			end
			entity:damage(1)
			gSounds['hit-enemy']:setVolume(0.6)
			gSounds['hit-enemy']:play()
		end
	end

	if self.player.currentAnimation.timesPlayed > 0 then
		self.player.currentAnimation.timesPlayed = 0
		self.player:changeState('idle')
	end

	if love.keyboard.wasPressed('space') then
		self.player:changeState('swing-sword')
	end
end

function PlayerSwingSwordState:render()
	if gRenderHitboxes then
		self.swordHitbox:render(255, 0, 0)
	end
	local anim = self.player.currentAnimation
	love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
		math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

	-- debug for player and hurtbox collision rects
	-- love.graphics.setColor(255, 0, 255, 255)
	-- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
	-- love.graphics.rectangle('line', self.swordHurtbox.x, self.swordHurtbox.y,
	--     self.swordHurtbox.width, self.swordHurtbox.height)
	-- love.graphics.setColor(255, 255, 255, 255)
end
