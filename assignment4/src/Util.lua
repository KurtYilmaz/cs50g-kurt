--[[
	GD50
	Super Mario Bros. Remake

	-- StartState Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu

	Helper functions for writing Match-3.
]]

--[[
	Given an "atlas" (a texture with multiple sprites), as well as a
	width and a height for the tiles therein, split the texture into
	all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
	local sheetWidth = atlas:getWidth() / tilewidth
	local sheetHeight = atlas:getHeight() / tileheight

	local sheetCounter = 1
	local spritesheet = {}

	for y = 0, sheetHeight - 1 do
		for x = 0, sheetWidth - 1 do
			spritesheet[sheetCounter] =
				love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
				tileheight, atlas:getDimensions())
			sheetCounter = sheetCounter + 1
		end
	end

	return spritesheet
end

-- AS4.3 - Dealing with the way the sprite sheet laid out the poles and flags
function GenerateQuadsPoles(atlas, polecount, tilewidth, tileheight)
	local sheetCounter = 1
	local spritesheet = {}

	for x = 0, polecount - 1 do
		spritesheet[sheetCounter] =
			love.graphics.newQuad(x * tilewidth, 0, tilewidth,
			tileheight * 3, atlas:getDimensions())
		sheetCounter = sheetCounter + 1
	end

	return spritesheet
end

function GenerateQuadsFlags(atlas, polecount, flagcount, tilewidth, tileheight)
	local sheetWidth = atlas:getWidth()
	local sheetHeight = atlas:getHeight()

	local sheetCounter = 1
	local spritesheet = {}

	for x = 0, 3 do
		for y = 0, flagcount - 1 do
			spritesheet[sheetCounter] =
				love.graphics.newQuad((x + polecount) * tilewidth, y * tileheight, tilewidth,
				tileheight, atlas:getDimensions())
			sheetCounter = sheetCounter + 1
		end
	end

	return spritesheet
end

--[[
	Divides quads we've generated via slicing our tile sheet into separate tile sets.
]]
function GenerateTileSets(quads, setsX, setsY, sizeX, sizeY)
	local tilesets = {}
	local tableCounter = 0
	local sheetWidth = setsX * sizeX
	local sheetHeight = setsY * sizeY

	-- for each tile set on the X and Y
	for tilesetY = 1, setsY do
		for tilesetX = 1, setsX do

			-- tileset table
			table.insert(tilesets, {})
			tableCounter = tableCounter + 1

			for y = sizeY * (tilesetY - 1) + 1, sizeY * (tilesetY - 1) + 1 + sizeY do
				for x = sizeX * (tilesetX - 1) + 1, sizeX * (tilesetX - 1) + 1 + sizeX do
					table.insert(tilesets[tableCounter], quads[sheetWidth * (y - 1) + x])
				end
			end
		end
	end

	return tilesets
end

--[[
	Recursive table printing function.
	https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
function print_r ( t )
	local print_r_cache={}
	local function sub_print_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						print(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
						print(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(val)=="string") then
						print(indent.."["..pos..'] => "'..val..'"')
					else
						print(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(tostring(t).." {")
		sub_print_r(t,"  ")
		print("}")
	else
		sub_print_r(t,"  ")
	end
	print()
end
