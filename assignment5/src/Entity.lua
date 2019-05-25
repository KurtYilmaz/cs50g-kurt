--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Entity = Class{}

function Entity:init(def)

	-- in top-down games, there are four directions instead of two
	self.direction = 'down'

	self.animations = self:createAnimations(def.animations)

	-- dimensions
	self.x = def.x
	self.y = def.y
	self.width = def.width
	self.height = def.height

	-- drawing offsets for padded sprites
	self.offsetX = def.offsetX or 0
	self.offsetY = def.offsetY or 0

	self.walkSpeed = def.walkSpeed

	self.health = def.health

	-- AS5.X - adding hitboxes and hitboxes for each creature
	-- They come from the same hitbox class, just used differently
	self.hitbox = Hitbox {
		padX = def.hitbox.padX,
		padY = def.hitbox.padY,
		width = def.hitbox.width,
		height = def.hitbox.height
	}
	self.hurtbox = Hitbox {
		padX = def.hurtbox.padX,
		padY = def.hurtbox.padY,
		width = def.hurtbox.width,
		height = def.hurtbox.height,
	}
	-- Setting the absolute coordinates
	self.hitbox:move(self.x, self.y)
	self.hurtbox:move(self.x, self.y)

	-- flags for flashing the entity when hit
	self.invulnerable = false
	self.invulnerableDuration = 0
	self.invulnerableTimer = 0
	self.flashTimer = 0

	self.dead = false

	-- AS5.X = Particle system for dead enemies
	self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 16)
	self.psystem:setParticleLifetime(0.5, 1)
	self.psystem:setEmitterLifetime(0.5)
	self.psystem:setEmissionRate(20)
	-- self.psystem:setSizeVariation(0)
	self.psystem:setLinearAcceleration(-20, -20, 20, 20)
	self.psystem:setAreaSpread('uniform', 1, 1)
	self.psystem:setColors(0, 0, 255, 255, 255, 0, 255, 255)

end

function Entity:createAnimations(animations)
	local animationsReturned = {}

	for k, animationDef in pairs(animations) do
		animationsReturned[k] = Animation {
			texture = animationDef.texture or 'entities',
			frames = animationDef.frames,
			interval = animationDef.interval
		}
	end

	return animationsReturned
end

--[[
	AABB with some slight shrinkage of the box on the top side for perspective.
]]
function Entity:collides(target)
	return not (self.hurtbox.x + self.width < target.x or self.hurtbox.x > target.x + target.width or
				self.hurtbox.y + self.height < target.y or self.hurtbox.y > target.y + target.height)
end

function Entity:damage(dmg)
	self.health = self.health - dmg
	if self.direction == 'down' then
		-- Timer.tween(0.3, {
		-- 	[self] = {self.y = math.min(MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2, self.y - (3 * TILE_SIZE))}
		-- })
	elseif self.direction == 'up' then
		-- Timer.tween(0.3, {
		-- 	[self] = {self. y =  math.min(VIRTUAL_HEIGHT -
		-- 				(VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) +
		-- 				MAP_RENDER_OFFSET_Y - TILE_SIZE, self.y - (3 * TILE_SIZE))}
		-- })
	elseif self.direction == 'left' then
		-- Timer.tween(0.3, {
		-- 	[self] = {self.x =  math.min(VIRTUAL_WIDTH - TILE_SIZE * 2 -
		-- 				self.entity.width, self.y - (3 * TILE_SIZE))}
		-- })
	elseif self.direction == 'right' then
		-- Timer.tween(0.3, {
		-- 	[self] = {self.x =  math.min(MAP_RENDER_OFFSET_X + TILE_SIZE -
		-- 				self.entity.height / 2, self.y - (3 * TILE_SIZE))}
		-- })
	end
end

-- AS5.X - Death function kills and emits
function Entity:death()
	self.dead = true
	self.psystem:emit(16)
end

function Entity:goInvulnerable(duration)
	self.invulnerable = true
	self.invulnerableDuration = duration
end

function Entity:changeState(name)
	self.stateMachine:change(name)
end

function Entity:changeAnimation(name)
	self.currentAnimation = self.animations[name]
end

function Entity:update(dt)
	if not self.dead then
		if self.invulnerable then
			self.flashTimer = self.flashTimer + dt
			self.invulnerableTimer = self.invulnerableTimer + dt

			if self.invulnerableTimer > self.invulnerableDuration then
				self.invulnerable = false
				self.invulnerableTimer = 0
				self.invulnerableDuration = 0
				self.flashTimer = 0
			end
		end

		self.stateMachine:update(dt)

		-- AS5.X - moving hit/hurtboxes
		self.hurtbox:move(self.x, self.y)
		self.hitbox:move(self.x, self.y)

		if self.currentAnimation then
			self.currentAnimation:update(dt)
		end
	else
		self.psystem:update(dt)
	end
end

function Entity:processAI(params, dt)
	self.stateMachine:processAI(params, dt)
end

function Entity:render(adjacentOffsetX, adjacentOffsetY)
	if self.dead then
		love.graphics.draw(self.psystem, self.x + self.width/2, self.y + self.height/2)
	else
		if gRenderHitboxes then
			self.hurtbox:render(0, 255, 0)
		end

		-- draw sprite slightly transparent if invulnerable every 0.04 seconds
		if self.invulnerable and self.flashTimer > 0.06 then
			self.flashTimer = 0
			love.graphics.setColor(255, 255, 255, 64)
		end

		self.x, self.y = self.x + (adjacentOffsetX or 0), self.y + (adjacentOffsetY or 0)
		self.stateMachine:render()
		love.graphics.setColor(255, 255, 255, 255)
		self.x, self.y = self.x - (adjacentOffsetX or 0), self.y - (adjacentOffsetY or 0)
	end
end
