PlayerDamageState = Class{__includes = EntityIdleState}

function PlayerDamageState:enter(params)
	-- render offset for spaced character sprite
	self.entity.offsetY = 5
	self.entity.offsetX = 0
	self.entity.idle = true

	self.timer = 0.35
end

function PlayerDamageState:update(dt)
	EntityIdleState.update(self, dt)

	if self.timer < 0 then
		self.entity:changeState('idle')
	else
		self.timer = self.timer - dt
	end
end
