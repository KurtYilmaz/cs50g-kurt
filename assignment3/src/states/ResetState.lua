--[[
	GD50
	Match-3 Remake

	Author: Kurt Yilmaz
	AS3.4 - reset state for when board is stuck
]]

ResetState = Class{__includes = BaseState}

function ResetState:init()

end

function ResetState:enter(params)
	self.score = params.score
	self.timer = params.timer
	self.level = params.level
	self.scoreGoal = params.goal
	self.board = Board(GRID_START_X, GRID_START_Y, self.level)
	Timer.after(2, function()
		self.continue = true
	end)

	Timer.every(0.5, function()
		self.blinkText = not self.blinkText
	end)
end

function ResetState:update(dt)
	if (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) and self.continue then

		gStateMachine:change('play', {
		score = self.score,
		timer = self.timer,
		level = self.level,
		board = self.board,
		alpha = self.transitionAlpha,
		})
	end

	Timer.update(dt)
end

function ResetState:render()

	self.board:render()

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setColor(56, 56, 56, 234)
	love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

	love.graphics.setColor(99, 155, 255, 255)
	love.graphics.setFont(gFonts['medium'])
	love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
	love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
	love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
	love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')

	love.graphics.setFont(gFonts['max'])

	love.graphics.setColor(56, 56, 56, 234)
	love.graphics.rectangle('fill', VIRTUAL_WIDTH - 272, 16, 256, 256)

	love.graphics.setColor(99, 155, 255, 255)
	love.graphics.printf('BOARD\nRESET', VIRTUAL_WIDTH - 272, VIRTUAL_HEIGHT / 2 - 60, 272, 'center')

	if self.continue then
		if self.blinkText then
			love.graphics.setColor(99, 155, 255, 255)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.setFont(gFonts['medium'])
		love.graphics.printf('Press Enter to Continue...', VIRTUAL_WIDTH - 272, VIRTUAL_HEIGHT / 2 + 52, 272, 'center')
	end
end
