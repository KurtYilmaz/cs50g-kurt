--[[
	GD50
	Super Mario Bros. Remake

	-- LevelMaker Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
	local tiles = {}
	local entities = {}
	local objects = {}

	local tileID = TILE_ID_GROUND

	-- whether we should draw our tiles with toppers
	local topper = true
	local tileset = math.random(20)
	local topperset = math.random(20)

	-- AS4.2 - Key and lock locations randomly generated
	local keyLocation = math.floor(math.random(width - 4))
	local lockLocation = math.floor(math.random(width - 4))
	local keyColor = math.random(4)
	-- In case key and lock end in same location (or too close)
	while (math.abs(lockLocation - keyLocation) < 2) do
		lockLocation = math.random(width - 4)
	end

	-- AS4.X - Editable low ground
	local lowGround = 8

	-- insert blank tables into tiles for later access
	for y = 1, height do
		table.insert(tiles, {})
	end

	-- column by column generation instead of row; sometimes better for platformers
	for x = 1, width do
		local tileID = TILE_ID_EMPTY

		-- lay out the empty space
		for y = 1, lowGround - 1 do
			table.insert(tiles[y],
				Tile(x, y, tileID, nil, tileset, topperset))
		end

		-- chance to just be emptiness
		-- AS4.1 - the game already checked to make sure column 1 has solid ground
		-- Removed the condition for no chasms on column 1 to demonstrate 4.1 working
		-- No chasm allowed at the end of the level so goal can spawn there easily
		if (math.random(10) == 1) and (x ~= keyLocation) and (x ~= lockLocation) and (x < width - 3) then
			for y = lowGround, height do
				table.insert(tiles[y],
					Tile(x, y, tileID, nil, tileset, topperset))
			end

		else
			tileID = TILE_ID_GROUND

			local blockHeight = lowGround - 3

			for y = lowGround, height do
				table.insert(tiles[y],
					Tile(x, y, tileID, y == lowGround and topper or nil, tileset, topperset))
			end

			-- chance to generate a lower or higher terrain
			-- No hill allowed at the end of the level so goal can spawn there easily
			if (math.random(4) == 1) and (x ~= keyLocation + 1) and (x ~= lockLocation + 1) and (x < width - 3) then
				local terrainHeight = math.floor(math.random(5, lowGround - .001))
				blockHeight = terrainHeight - 3

				-- chance to generate bush on pillar
				if math.random(4) == 1 then
					table.insert(objects,
						GameObject {
							texture = 'bushes',
							x = (x - 1) * TILE_SIZE,
							y = (terrainHeight - 2) * TILE_SIZE,
							width = 16,
							height = 16,

							-- select random frame from bush_ids whitelist, then random row for variance
							frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
						}
					)
				end

				-- Laying pillar tiles
				-- tiles[lowGround][x].topper = nil
				for i = terrainHeight, lowGround do
					-- if i = terrainHeight, topper is true
					tiles[i][x] = Tile(x, i, tileID, i == terrainHeight, tileset, topperset)
				end

			-- chance to generate bushes
			elseif math.random(8) == 1 then
				table.insert(objects,
					GameObject {
						texture = 'bushes',
						x = (x - 1) * TILE_SIZE,
						y = (lowGround - 2) * TILE_SIZE,
						width = 16,
						height = 16,
						frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
						collidable = false
					}
				)
			end

			-- AS4.2 - Logic for block containing key
			if (x == keyLocation) then
				-- Making sure it's an odd blocktype so it's not exhausted
				local blockType = 2 * math.floor(math.random(#JUMP_BLOCKS / 2)) - 1
				table.insert(objects,

					-- key block
					GameObject {
						texture = 'jump-blocks',
						x = (x - 1) * TILE_SIZE,
						y = (blockHeight - 1) * TILE_SIZE,
						width = 16,
						height = 16,
						frame = blockType,
						collidable = true,
						hit = false,

						-- collision function takes itself
						onCollide = function(player, obj)

							-- AS4.2 - Spawning key
							if (not obj.hit) then
								local key = GameObject {
									texture = 'keys-and-locks',
									x = (x - 1) * TILE_SIZE,
									y = (blockHeight - 1) * TILE_SIZE - 4,
									width = 16,
									height = 16,
									frame = keyColor,
									collidable = false,
									consumable = true,

									-- Key gives player a key powerup
									onConsume = function(player, object)
										gSounds['pickup']:play()
										player.key = keyColor
									end
								}

								-- make the key move up from the block and play a sound
								Timer.tween(0.1, {
									[key] = {y = (blockHeight - 2) * TILE_SIZE}
								})
								gSounds['powerup-reveal']:play()

								table.insert(objects, key)

								obj.hit = true
								obj.frame = obj.frame + 1
							end

							gSounds['empty-block']:play()
						end
					}
				)

			-- AS4.2 - Logic for lock block
			elseif (x == lockLocation) then
				table.insert(objects,
					-- lock block
					GameObject {
						texture = 'keys-and-locks',
						x = (x - 1) * TILE_SIZE,
						y = (blockHeight - 1) * TILE_SIZE,
						width = 16,
						height = 16,
						frame = keyColor + 4,
						collidable = true,
						consumable = false,

						-- AS4.3 - Spawning goal
						onCollide = function(player, object)
							gSounds['empty-block']:play()

							if player.key > 0 then
								local pole = GameObject {
									texture = 'poles',
									x = (width - 3) * TILE_SIZE,
									y = (lowGround - 4) * TILE_SIZE,
									width = TILE_SIZE,
									height = TILE_SIZE * 3,
									frame = 2,
									collidable = false,
									consumable = true,

									-- AS4.3 - Goal shifts to next level
									onConsume = function(player2, object2)
										local fakePole = GameObject {
											texture = 'poles',
											x = (width - 3) * TILE_SIZE,
											y = (lowGround - 4) * TILE_SIZE,
											width = TILE_SIZE,
											height = TILE_SIZE * 3,
											frame = keyColor + 2,
											collidable = false,
											consumable = false,
										}

										local flag = GameObject {
											texture = 'flags',
											x = (width - 3) * TILE_SIZE  + 9,
											y = (lowGround - 4) * TILE_SIZE + 5,
											width = TILE_SIZE,
											height = TILE_SIZE,
											animation = Animation {
												frames = {keyColor, keyColor + #FLAGS},
												interval = 0.25
											},
											collidable = false,
											consumable = false
										}

										table.insert(objects, fakePole)
										table.insert(objects, flag)

										player.goal = 0
										player.victory = true
									end
								}



								table.insert(objects, pole)

								player.goal = player.key
								player.key = 0
								object.consumable = true
							end
						end,

						onConsume = function(player, object)
							gSounds['powerup-reveal']:play()
						end
					}
				)

			-- chance to spawn a block
			-- Keeping it away from the key and lock locations to prevent unreachable bug
			elseif (x < width - 1 and math.random(10) == 1) and (x ~= keyLocation + 1) and (x ~= lockLocation + 1) then
				-- AS4.X - chance to spawn gem reliant on type of block
				local blockType = math.floor(math.random(#JUMP_BLOCKS))
				table.insert(objects,

					-- jump block
					GameObject {
						texture = 'jump-blocks',
						x = (x - 1) * TILE_SIZE,
						y = (blockHeight - 1) * TILE_SIZE,
						width = 16,
						height = 16,
						frame = blockType,
						collidable = true,
						hit = false,

						-- collision function takes itself
						onCollide = function(player, obj)

							-- AS4.X - Chance for gems and others on non-exhausted blocks
							if (not obj.hit) and (obj.frame % 2 == 1) then

								-- AS4.X - Chance for snail
								if (obj.frame % 6 == 5) then
									-- Can't generate snail in LevelMaker
									-- Flags and locations for PlayState to handle
									obj.spawnEnemy = true
									obj.enemyX = (x - 1) * TILE_SIZE
									obj.enemyY = (blockHeight - 1) * TILE_SIZE - 4

								-- AS4.X - Gem chance
								elseif (obj.frame % 6 < 4) then
									-- maintain reference so we can set it to nil
									local gem = GameObject {
										texture = 'gems',
										x = (x - 1) * TILE_SIZE,
										y = (blockHeight - 1) * TILE_SIZE - 4,
										width = 16,
										height = 16,
										frame = math.random(#GEMS),
										collidable = false,
										consumable = true,

										-- gem has its own function to add to the player's score
										onConsume = function(player, object)
											gSounds['pickup']:play()
											player.score = player.score + 100
											-- Big gems give extra points
											if object.frame > 4 then
												player.score = player.score + 200
											end
										end
									}

									-- make the gem move up from the block and play a sound
									Timer.tween(0.1, {
										[gem] = {y = (blockHeight - 2) * TILE_SIZE}
									})
									gSounds['powerup-reveal']:play()

									table.insert(objects, gem)

								end
								obj.hit = true
								obj.frame = obj.frame + 1
							end

							gSounds['empty-block']:play()
						end
					}
				)
			end
		end
	end

	local map = TileMap(width, height)
	map.tiles = tiles

	return GameLevel(entities, objects, map)
end
