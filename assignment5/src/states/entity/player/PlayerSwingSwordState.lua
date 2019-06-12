--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

PlayerSwingSwordState = Class{__includes = BaseState}

function PlayerSwingSwordState:init(player, dungeon)
	self.entity = player
	self.dungeon = dungeon

	-- render offset for spaced character sprite
	self.entity.offsetY = 5
	self.entity.offsetX = 8

	-- create hitbox based on where the player is and facing
	local direction = self.entity.direction

	local padX, padY, hitboxWidth, hitboxHeight

	if direction == 'left' then
		hitboxWidth = 10
		hitboxHeight = 18
		padX = -hitboxWidth + self.entity.hurtbox.padX
		padY = 2
	elseif direction == 'right' then
		hitboxWidth = 10
		hitboxHeight = 18
		padX = self.entity.hurtbox.width
		padY = 2
	elseif direction == 'up' then
		hitboxWidth = 18
		hitboxHeight = 10
		padX = -2
		padY = -hitboxHeight + self.entity.hurtbox.padY - 1
	else
		hitboxWidth = 19
		hitboxHeight = 10
		padX = -2
		padY = self.entity.height - 2
	end

	self.swordHitbox = Hitbox {
		padX = padX,
		padY = padY,
		height = hitboxHeight,
		width = hitboxWidth
	}
	self.swordHitbox:move(self.entity.x, self.entity.y)
	self.entity:changeAnimation('sword-' .. self.entity.direction)
end

function PlayerSwingSwordState:enter(params)
	gSounds['sword']:setVolume(0.6)
	gSounds['sword']:stop()
	gSounds['sword']:play()

	-- restart sword swing animation
	self.entity.currentAnimation:refresh()
end

function PlayerSwingSwordState:update(dt)
	self.swordHitbox:move(self.entity.x, self.entity.y)
	-- check if hitbox collides with any entities in the scene
	for k, entity in pairs(self.dungeon.currentRoom.entities) do
		if entity:collides(self.swordHitbox) and not entity.dead then
			if self.entity.direction == 'left' then
				entity.directionHit = 'right'
			elseif self.entity.direction == 'right' then
				entity.directionHit = 'left'
			elseif self.entity.direction == 'up' then
				entity.directionHit = 'down'
			elseif self.entity.direction == 'down' then
				entity.directionHit = 'up'
			end
			entity:damage(1)
			gSounds['hit-enemy']:setVolume(0.6)
			gSounds['hit-enemy']:play()
		end
	end

	if self.entity.currentAnimation.timesPlayed > 0 then
		self.entity.currentAnimation.timesPlayed = 0
		self.entity:changeState('idle')
	end
end

function PlayerSwingSwordState:action(dt)
	self.entity:changeState('swing-sword')
end

function PlayerSwingSwordState:render()
	if gRenderHitboxes then
		self.swordHitbox:render(255, 0, 0)
	end
	local anim = self.entity.currentAnimation
	love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
		math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
end
