-- AS5.3 - throw state

PlayerThrowState = Class{__includes = BaseState}

function PlayerThrowState:init(player)
	-- render offset for spaced character sprite
	self.entity = player
	self.entity.offsetY = 5
	self.entity.offsetX = 0
end

function PlayerThrowState:enter()
	self.entity.idle = false
	self.timer = PLAYER_THROW_SPEED * 3 - 0.01
	self.entity:changeAnimation('throw-' .. self.entity.direction)

	local throwX, throwY
	if self.entity.direction == 'up' then
		throwX = self.entity.x
		throwY = self.entity.y - PLAYER_THROW_DISTANCE
	elseif self.entity.direction == 'down' then
		throwX = self.entity.x
		throwY = self.entity.y + PLAYER_THROW_DISTANCE
	elseif self.entity.direction == 'left' then
		throwX = self.entity.x - PLAYER_THROW_DISTANCE
		throwY = self.entity.y + self.entity.height - self.entity.item.height
	else
		throwX = self.entity.x + PLAYER_THROW_DISTANCE
		throwY = self.entity.y + self.entity.height - self.entity.item.height
	end
	-- Takes x and y destinations, as well as speed (timer)
	self.entity.item:fire(self.entity.direction, throwX, throwY, 0.5)
	table.insert(self.entity.room.projectiles, self.entity.item)
	self.entity.item = nil
end

function PlayerThrowState:update(dt)
	if self.timer < 0 then
		self.entity:changeState('idle')
	end
	self.timer = self.timer - dt

	-- AS5.3 - Need this because we miss some update when transferring to Room's table
	-- if self.entity.item ~= nil then
	-- 	self.entity.item:update(dt)
	-- end
end

function PlayerThrowState:action(dt)
	-- Empty action function (you want the throw to lag)
end

function PlayerThrowState:render()
	local anim = self.entity.currentAnimation
	love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
		math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
	-- AS5.3 - Need this because we miss some render when transferring to Room's table
	if self.entity.item ~= nil then
		self.entity.item:render(0,0)
	end
end
