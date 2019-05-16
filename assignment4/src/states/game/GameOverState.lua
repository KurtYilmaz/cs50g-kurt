GameOverState = Class{__includes = BaseState}

function GameOverState:init()
	gSounds['game-over-bg']:setLooping(true)
	gSounds['game-over-bg']:setVolume(0.5)
	gSounds['game-over-bg']:play()

	self.timer = 0
end

function GameOverState:enter(params)
	self.levelNumber = params.levelNumber
	self.player = params.player
	self.background = params.background
	self.clock = params.clock
	self.clock:split()

end

function GameOverState:update(dt)
	if self.timer > 2.5 and (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) then
		gSounds['game-over-bg']:stop()
		gStateMachine:change('start')
	end

	self.timer = self.timer + dt
end

function GameOverState:render()
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
		gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

	love.graphics.setColor(0, 0, 0, 120)
	love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

	love.graphics.setFont(gFonts['large'])
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf('GAME OVER', 1, VIRTUAL_HEIGHT / 2 - 70 + 1, VIRTUAL_WIDTH, 'center')
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 2 - 70, VIRTUAL_WIDTH, 'center')


	local text = {
		'Max Lv.: '.. tostring(self.player.score),
		'Score: '.. tostring(self.player.score),
		self.clock:generateTotalString(),
	}

	if self.timer > 0.5 then
		love.graphics.setFont(gFonts['medium'])
		gPrint(text[1], 4, VIRTUAL_HEIGHT / 2 - 29, VIRTUAL_WIDTH, 'left')

	end

	if self.timer > 1 then
		love.graphics.setFont(gFonts['medium'])
		gPrint(text[2], 4, VIRTUAL_HEIGHT / 2 - 29, VIRTUAL_WIDTH - 8, 'right')
	end

	if self.timer > 1.5 then
		love.graphics.setFont(gFonts['medium'])
		gPrint(text[3], 4, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'left')
	end

	if self.timer > 2.5 and self.timer % 1 < 0.5 then
		love.graphics.setFont(gFonts['medium'])
		gPrint('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 54, VIRTUAL_WIDTH, 'center')
	end
end
