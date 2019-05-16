PlayerVictoryState = Class{__includes = BaseState}


-- AS4.X - Victory walkoff for player
function PlayerVictoryState:init(player)
	self.player = player

	self.animation = Animation {
		frames = {10, 11},
		interval = 0.1
	}

	self.player.currentAnimation = self.animation

	self.player.victory = false
end

function PlayerVictoryState:update(dt)
	self.player.currentAnimation:update(dt)
	self.player.x = self.player.x + 30 * dt
end
