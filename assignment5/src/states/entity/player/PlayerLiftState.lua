PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(player)
	-- render offset for spaced character sprite
	self.entity = player
	self.entity.offsetY = 5
	self.entity.offsetX = 0
end

function PlayerLiftState:enter()
	self.entity.idle = false
	self.timer = 0.9

end

function PlayerLiftState:update(dt)
	if self.timer < 0 then
		self.entity:changeState('idle')
		-- TEMPORARY, WILL NEED ITEM PICKED UP LATER (JUST NEED HERE TO TEST ANIMATION)
		self.item = 1
	end
	self.timer = self.timer - dt
end

function PlayerLiftState:action()
	-- Empty action function
end
