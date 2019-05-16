--[[
	GD50
	Super Mario Bros. Remake

	Author: Colton Ogden
	cogden@cs50.harvard.edu

	-- Dependencies --

	A file to organize all of the global dependencies for our project, as
	well as the assets for our game, rather than pollute our main.lua file.
]]

--
-- libraries
--
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

--
-- our own code
--

-- utility
require 'src/constants'
require 'src/StateMachine'
require 'src/Util'

-- game states
require 'src/states/BaseState'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'
-- AS4.4 - Adding game over and victory states
require 'src/states/game/VictoryState'
require 'src/states/game/GameOverState'

-- entity states
require 'src/states/entity/PlayerFallingState'
require 'src/states/entity/PlayerIdleState'
require 'src/states/entity/PlayerJumpState'
require 'src/states/entity/PlayerWalkingState'
-- AS4.X - Adding player death state and victory state
require 'src/states/entity/PlayerDeathState'
require 'src/states/entity/PlayerVictoryState'

require 'src/states/entity/snail/SnailChasingState'
require 'src/states/entity/snail/SnailIdleState'
require 'src/states/entity/snail/SnailMovingState'

-- general
require 'src/Animation'
require 'src/Entity'
require 'src/GameObject'
require 'src/GameLevel'
require 'src/LevelMaker'
require 'src/Player'
require 'src/Snail'
require 'src/Tile'
require 'src/TileMap'
-- AS4.X - Created a clock
require 'src/Clock'


gSounds = {
	['jump'] = love.audio.newSource('sounds/jump.wav'),
	['death'] = love.audio.newSource('sounds/death.wav'),
	['play-bg'] = love.audio.newSource('sounds/music.wav'),
	['powerup-reveal'] = love.audio.newSource('sounds/powerup-reveal.wav'),
	['pickup'] = love.audio.newSource('sounds/pickup.wav'),
	['empty-block'] = love.audio.newSource('sounds/empty-block.wav'),
	['kill'] = love.audio.newSource('sounds/kill.wav'),
	['kill2'] = love.audio.newSource('sounds/kill2.wav'),
	-- AS4.4 - Win music
	['win'] = love.audio.newSource('sounds/win.wav'),
	-- AS4.X - VictoryState and GameOverState background music
	['victory-bg'] = love.audio.newSource('sounds/victory-bg.mp3'),
	['game-over-bg'] = love.audio.newSource('sounds/gameover-bg.mp3')
}

gTextures = {
	['tiles'] = love.graphics.newImage('graphics/tiles.png'),
	['toppers'] = love.graphics.newImage('graphics/tile_tops.png'),
	['bushes'] = love.graphics.newImage('graphics/bushes_and_cacti.png'),
	['jump-blocks'] = love.graphics.newImage('graphics/jump_blocks.png'),
	['gems'] = love.graphics.newImage('graphics/gems.png'),
	['backgrounds'] = love.graphics.newImage('graphics/backgrounds.png'),
	['green-alien'] = love.graphics.newImage('graphics/green_alien.png'),
	['creatures'] = love.graphics.newImage('graphics/creatures.png'),
	['keys-and-locks'] = love.graphics.newImage('graphics/keys_and_locks.png'),
	-- AS4.3 - adding poles and flags. Same file needs to load twice because of how GameObject is written
	['poles'] = love.graphics.newImage('graphics/flags.png'),
	['flags'] = love.graphics.newImage('graphics/flags.png')
}

gFrames = {
	['tiles'] = GenerateQuads(gTextures['tiles'], TILE_SIZE, TILE_SIZE),

	['toppers'] = GenerateQuads(gTextures['toppers'], TILE_SIZE, TILE_SIZE),

	['bushes'] = GenerateQuads(gTextures['bushes'], 16, 16),
	['jump-blocks'] = GenerateQuads(gTextures['jump-blocks'], 16, 16),
	['gems'] = GenerateQuads(gTextures['gems'], 16, 16),
	['backgrounds'] = GenerateQuads(gTextures['backgrounds'], 256, 128),
	['green-alien'] = GenerateQuads(gTextures['green-alien'], 16, 20),
	['creatures'] = GenerateQuads(gTextures['creatures'], 16, 16),
	['keys-and-locks'] = GenerateQuads(gTextures['keys-and-locks'], 16, 16),
	-- AS4.3 - adding poles and flags
	['poles'] = GenerateQuadsPoles(gTextures['poles'], 6, 16, 16),
	['flags'] = GenerateQuadsFlags(gTextures['flags'], 6, 4, 16, 16)
}

-- these need to be added after gFrames is initialized because they refer to gFrames from within
gFrames['tilesets'] = GenerateTileSets(gFrames['tiles'],
	TILE_SETS_WIDE, TILE_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFrames['toppersets'] = GenerateTileSets(gFrames['toppers'],
	TOPPER_SETS_WIDE, TOPPER_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFonts = {
	['small'] = love.graphics.newFont('fonts/font.ttf', 8),
	['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
	['large'] = love.graphics.newFont('fonts/font.ttf', 32),
	['title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 32)
}

-- AS4.X - Easy printing of text. Storing local variables for readability
function gPrint(text, x, y, limit, align)
	love.graphics.setColor(0, 0, 0, 255)
	-- printf
	if align ~= nil or limit ~= nil then
		if limit == nil then
			limit = VIRTUAL_WIDTH
		elseif align == nil then
			align = 'left'
		end
		local font = love.graphics.getFont()
		if font == gFonts['title'] or font == gFonts['large'] then
			love.graphics.printf(text, x + 2, y + 2, limit, align)
		end
		love.graphics.printf(text, x + 1, y + 1, limit, align)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf(text, x, y, limit, align)

	-- regular print
	else
		love.graphics.print(text, x + 1, y + 1)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(text, x, y)
	end
end
