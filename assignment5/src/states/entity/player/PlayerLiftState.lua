PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(player)
	-- render offset for spaced character sprite
	self.entity = player
	self.entity.offsetY = 5
	self.entity.offsetX = 0
end

function PlayerLiftState:enter()
	self.entity.idle = false
	self.timer = PLAYER_LIFT_SPEED * 3 - 0.01
	self.entity:changeAnimation('lift-' .. self.entity.direction)
end

function PlayerLiftState:update(dt)
	if self.timer < 0 then
		-- TEMPORARY, WILL NEED ITEM PICKED UP LATER (JUST NEED HERE TO TEST ANIMATION)
		self.entity:changeState('idle')
	end
	self.timer = self.timer - dt
end

function PlayerLiftState:action(dt)
	-- Empty action function
end

function PlayerLiftState:render()
	local anim = self.entity.currentAnimation
	love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
		math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
end
