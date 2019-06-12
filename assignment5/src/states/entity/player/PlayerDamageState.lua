PlayerDamageState = Class{__includes = EntityIdleState}

function PlayerDamageState:init(player)
	-- render offset for spaced character sprite
	self.entity = player
	self.entity.offsetY = 5
	self.entity.offsetX = 0
	self.entity.idle = true
	self.timer = 0.5
end

function PlayerDamageState:enter()
	self.entity.idle = true
	self.timer = 0.5
	-- Avoids walking animation during damage state
	self.entity:changeAnimation('idle-' .. self.entity.direction)
end

function PlayerDamageState:update(dt)
	if self.timer < 0 then
		self.entity:changeState('idle')
	else
		self.timer = self.timer - dt
	end
end

function PlayerDamageState:action(dt)
	-- Empty action function
end
