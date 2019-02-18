--[[
	GD50 2018
	Flappy Bird Remake

	Author: Colton Ogden
	cogden@cs50.harvard.edu

	A mobile game by Dong Nguyen that went viral in 2013, utilizing a very simple
	but effective gameplay mechanic of avoiding pipes indefinitely by just tapping
	the screen, making the player's bird avatar flap its wings and move upwards slightly.
	A variant of popular games like "Helicopter Game" that floated around the internet
	for years prior. Illustrates some of the most basic procedural generation of game
	levels possible as by having pipes stick out of the ground by varying amounts, acting
	as an infinitely generated obstacle course for the player.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- a basic StateMachine class which will allow us to transition to and from
-- game states smoothly and avoid monolithic code in one file
require 'StateMachine'

-- all states our StateMachine can transition between
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'

require 'Bird'
require 'Pipe'
require 'PipePair'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

-- AS1.3 Rank medals (in main in case they want to be used elsewhere)
rank_bronze = love.graphics.newImage('rank-bronze-1.png')
rank_silver = love.graphics.newImage('rank-silver-1.png')
rank_gold = love.graphics.newImage('rank-gold-1.png')

-- AS1.4 pause and icon variables
pause = false
pauseIcon = love.graphics.newImage('pause.png')
pause_scaling = 1
pause_height = pauseIcon:getHeight() * pause_scaling
pause_width = pauseIcon:getWidth() * pause_scaling

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

function love.load()
	-- initialize our nearest-neighbor filter
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- seed the RNG
	math.randomseed(os.time())

	-- app window title
	love.window.setTitle('Fifty Bird')

	-- initialize our nice-looking retro text fonts
	smallFont = love.graphics.newFont('font.ttf', 8)
	mediumFont = love.graphics.newFont('flappy.ttf', 14)
	flappyFont = love.graphics.newFont('flappy.ttf', 28)
	hugeFont = love.graphics.newFont('flappy.ttf', 56)
	love.graphics.setFont(flappyFont)

	-- AS1.3 Dimensions for medals
	medal_scaling = 0.1
	medal_width = rank_bronze:getWidth() * medal_scaling
	medal_height = rank_bronze:getHeight() * medal_scaling


	-- initialize our table of sounds
	sounds = {
		['jump'] = love.audio.newSource('jump.wav', 'static'),
		['explosion'] = love.audio.newSource('explosion.wav', 'static'),
		['hurt'] = love.audio.newSource('hurt.wav', 'static'),
		['score'] = love.audio.newSource('score.wav', 'static'),
		-- AS1.4 pause fx
		['pause'] = love.audio.newSource('pause.wav', 'static'),

		-- AS1.X loops from my DAW, because I really hated mario's way
		['music'] = love.audio.newSource('music.wav', 'static')
	}

	-- kick off music
	sounds['music']:setLooping(true)
	sounds['music']:play()

	-- initialize our virtual resolution
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true
	})

	-- initialize state machine with all state-returning functions
	gStateMachine = StateMachine {
		['title'] = function() return TitleScreenState() end,
		['countdown'] = function() return CountdownState() end,
		['play'] = function() return PlayState() end,
		['score'] = function() return ScoreState() end
	}
	gStateMachine:change('title')

	-- initialize input table
	love.keyboard.keysPressed = {}

	-- initialize mouse input table
	love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.keypressed(key)
	-- add to our table of keys pressed this frame
	love.keyboard.keysPressed[key] = true

	if key == 'escape' then
		love.event.quit()
	end
	-- AS1.4 pause logic
	if key == 'p' then
		if pause == false then
			sounds['music']:pause()
			sounds['pause']:play()
			pause = true
		elseif pause == true then
			sounds['music']:play()
			pause = false
		end
	end

end

--[[
	LÖVE2D callback fired each time a mouse button is pressed; gives us the
	X and Y of the mouse, as well as the button in question.
]]
function love.mousepressed(x, y, button)
	love.mouse.buttonsPressed[button] = true
end

--[[
	Custom function to extend LÖVE's input handling; returns whether a given
	key was set to true in our input table this frame.
]]
function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
end

--[[
	Equivalent to our keyboard function from before, but for the mouse buttons.
]]
function love.mouse.wasPressed(button)
	return love.mouse.buttonsPressed[button]
end

function love.update(dt)
	if pause == false then
		-- scroll our background and ground, looping back to 0 after a certain amount
		backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
		groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

		gStateMachine:update(dt)
	end

	love.keyboard.keysPressed = {}
	love.mouse.buttonsPressed = {}
end

function love.draw()
	push:start()

	love.graphics.draw(background, -backgroundScroll, 0)
	gStateMachine:render()
	love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

	-- AS1.4 pause icon
	if pause == true then
		love.graphics.draw(pauseIcon, VIRTUAL_WIDTH/2 - pause_width/2, VIRTUAL_HEIGHT/2 - pause_height/2, 0, pause_scaling, pause_scaling)
	end

	push:finish()
end
