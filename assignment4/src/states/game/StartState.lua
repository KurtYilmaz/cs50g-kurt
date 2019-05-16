--[[
	GD50
	Super Mario Bros. Remake

	-- StartState Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

StartState = Class{__includes = BaseState}

function StartState:init()
	self.map = LevelMaker.generate(100, 10)
	self.background = math.random(3)

	gSounds['play-bg']:setLooping(true)
	gSounds['play-bg']:setVolume(0.3)
	gSounds['play-bg']:play()
end

function StartState:update(dt)
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		gStateMachine:change('play', {
			level = self.map,
			background = self.background,
			levelNumber = 1,
			score = 0,
			clock = Clock()
		})
	end
end

function StartState:render()
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
		gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
	self.map:render()

	love.graphics.setFont(gFonts['title'])
	gPrint('Super 50 Bros.', 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')

	love.graphics.setFont(gFonts['medium'])
	gPrint('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
end
