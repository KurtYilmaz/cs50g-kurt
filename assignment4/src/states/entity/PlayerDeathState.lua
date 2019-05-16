PlayerDeathState = Class{__includes = BaseState}

function PlayerDeathState:init(player, gravity)
	self.player = player
	self.gravity = gravity

	self.animation = Animation {
		frames = {5},
		interval = 1
	}

	self.player.currentAnimation = self.animation

	self.player.dy = PLAYER_JUMP_VELOCITY * 2
end

function PlayerDeathState:update(dt)
	self.player.dy = self.player.dy + self.gravity * 2
	self.player.y = self.player.y + (self.player.dy * dt)
end
