--[[
	GD50
	Super Mario Bros. Remake

	-- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
	self.camX = 0
	self.camY = 0
	self.backgroundX = 0

	self.gravityOn = true
	self.gravityAmount = 6

	gSounds['play-bg']:setLooping(true)
	gSounds['play-bg']:setVolume(0.3)
	gSounds['play-bg']:play()

	-- AS4.4 - Time until victory state and game over state
	self.victoryTimer = 0
	self.gameOverTimer = 0
	self.victory = false

end

-- AS4.X - Allows passing in level for efficiency and less jarring visuals
-- Reassigning a lot from the init function to the enter function
function PlayState:enter(params)

	-- Level from StartSate
	self.level = params.level
	self.levelNumber = params.levelNumber
	self.background = params.background
	self.tileMap = self.level.tileMap
	self.clock = params.clock
	local passedScore = params.score

	-- AS4.1 - Finding a non-chasm to drop player
	self.drop = 0
	for column = 1, self.level.tileMap.width do
		-- Checking if column is empty
		local columnEmpty = true
		for row = 1, self.level.tileMap.height do
			-- If column has ground is not empty
			if self.level.tileMap.tiles[row][column].id == TILE_ID_GROUND then
				columnEmpty = false
				-- Assigning drop location to particular column
				self.drop = column - 1
				break
			end
		end
		-- If column is not empty, drop column is found. Exit loop
		if columnEmpty == false then
			break
		end
	end

	self.player = Player({
		-- AS4.1 - Dropping player at the drop column
		x = self.drop * TILE_SIZE, y = 0,
		width = 16, height = 20,
		texture = 'green-alien',
		stateMachine = StateMachine {
			['idle'] = function() return PlayerIdleState(self.player) end,
			['walking'] = function() return PlayerWalkingState(self.player) end,
			['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
			['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end,
			['death'] = function() return PlayerDeathState(self.player, self.gravityAmount) end,
			['victory'] = function() return PlayerVictoryState(self.player) end
		},
		map = self.tileMap,
		level = self.level,
		score = (passedScore == 0) and 0 or passedScore
	})

	self:spawnEnemies()

	self.player:changeState('falling', {xMomentum = PLAYER_WALK_SPEED})

	self.clock.pause = false
end

function PlayState:update(dt)
	Timer.update(dt)
	self.clock:update(dt)

	-- AS4.4 - Adding victory state
	if self.player.victory then
		self.victory = true
	end

	if self.victory and self.victoryTimer == 0 then
		gSounds['play-bg']:stop()
		gSounds['win']:setVolume(0.5)
		gSounds['win']:play()
		self.clock.pause = true
		self.victoryTimer = 2.87 -- 2.87
	end

	if self.victoryTimer < 0 then
		gStateMachine:change('victory', {
			player = self.player,
			levelNumber = self.levelNumber,
			background = self.background,
			clock = self.clock
		})
	end

	if self.victoryTimer > 0 then
		self.victoryTimer = self.victoryTimer - dt
	end

	-- AS4.X - Adding game over state
	if self.player.gameOver then
		love.audio.stop()
		gSounds['death']:setVolume(0.5)
		gSounds['death']:play()
		self.clock.pause = true
		self.gameOverTimer = 1.5
		self.player.dead = true
		self.player.gameOver = false
	end

	if self.gameOverTimer > 0 then
		self.gameOverTimer = self.gameOverTimer - dt
	end

	if self.gameOverTimer < 0 then
		gStateMachine:change('game-over', {
			player = self.player,
			levelNumber = self.levelNumber,
			background = self.background,
			clock = self.clock
		})
	end

	-- remove any nils from pickups, etc.
	self.level:clear()

	-- update player and level
	self.player:update(dt)
	self.level:update(dt)

	-- constrain player X no matter which state
	if self.player.x <= 0 then
		self.player.x = 0
	elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width and not self.victory then
		self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
	end

	self:updateCamera()
end

function PlayState:render()
	love.graphics.push()
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
		gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
		gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

	-- translate the entire view of the scene to emulate a camera
	love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))

	self.level:render()

	self.player:render()
	love.graphics.pop()

	-- render score
	love.graphics.setFont(gFonts['medium'])
	gPrint(tostring(self.player.score), 4, 4)

	-- AS4.X - render clock
	self.clock:render()

	-- AS4.2 - key and graphics
	if self.player.key > 0 then
		love.graphics.setColor(0, 0, 0, 128)
		love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 16, 16, 16)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(gTextures['keys-and-locks'], gFrames['keys-and-locks'][self.player.key], 0, VIRTUAL_HEIGHT - 16)

	-- AS4.3 - goal graphics
	elseif self.player.goal > 0 then
		love.graphics.setColor(0, 0, 0, 128)
		love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 16, 16, 16)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(gTextures['flags'], gFrames['flags'][self.player.goal], 0, VIRTUAL_HEIGHT - 12)
	end
end

function PlayState:updateCamera()
	if not self.victory then
		-- clamp movement of the camera's X between 0 and the map bounds - virtual width,
		-- setting it half the screen to the left of the player so they are in the center
		self.camX = math.max(0,
			math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
			self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

		-- adjust background X to move a third the rate of the camera for parallax
		self.backgroundX = (self.camX / 3) % 256
	end
end

--[[
	Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
	-- spawn snails in the level
	for x = 1, self.tileMap.width do

		-- flag for whether there's ground on this column of the level
		local groundFound = false

		for y = 1, self.tileMap.height do
			if not groundFound then
				if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
					groundFound = true

					-- random chance, 1 in 10
					if math.random(2) == 1 then
						local snailType = (math.random(4) < 3) and 1 or 2

						-- instantiate snail, declaring in advance so we can pass it into state machine
						local snail
						snail = Snail {
							texture = 'creatures',
							id = (snailType == 1) and 'snail1' or 'snail2',
							x = (x - 1) * TILE_SIZE,
							y = (y - 2) * TILE_SIZE + 2,
							width = 16,
							height = 16,
							type = snailType,
							hp = snailType,
							scoreMod = snailType * snailType,
							stateMachine = StateMachine {
								['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
								['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
								['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
							}
						}
						snail:changeState('idle', {
							wait = math.random(5)
						})

						table.insert(self.level.entities, snail)
					end
				end
			end
		end
	end
end
