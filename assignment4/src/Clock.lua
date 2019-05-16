
Clock = Class{}

-- AS4.X - for keeping track of time
function Clock:init(def)
	self.splitSeconds = 0
	self.splitMinutes = 0
	self.splitHours = 0

	self.totalSeconds = 0
	self.totalMinutes = 0
	self.totalHours = 0

	self.pause = false

	self.levelSplits = {}
end

function Clock:update(dt)
	if not self.pause then
		self.splitSeconds = self.splitSeconds + dt
		if self.splitSeconds > 59 then
			self.splitSeconds = 0
			self.splitMinutes = self.splitMinutes + 1
		end
		if self.splitMinutes > 59 then
			self.splitMinutes = 0
			self.splitHours = self.splitHours + 1
		end
	end
end

function Clock:split()
	local time = {
		seconds = self.splitSeconds,
		minutes = self.splitMinutes,
		hours = self.splitHours
	}
	table.insert(self.levelSplits, time)
	self.totalSeconds = self.totalSeconds + self.splitSeconds
	self.totalMinutes = self.totalMinutes + self.splitMinutes
	self.totalHours = self.totalHours + self.totalHours
	self.splitSeconds = 0
	self.splitMinutes = 0
	self.splitHours = 0
	self.pause = false
end

function Clock:render()
	-- render split time
	local displaySeconds
	local displayMinutes

	if self.splitSeconds < 10 then
		displaySeconds = '0' .. tostring(math.floor(self.splitSeconds))
	else
		displaySeconds = tostring(math.floor(self.splitSeconds))
	end

	if self.splitMinutes < 10 then
		displayMinutes = '0' .. tostring(math.floor(self.splitMinutes))
	else
		displayMinutes = tostring(math.floor(self.splitMinutes))
	end

	love.graphics.setFont(gFonts['medium'])
	gPrint(displayMinutes .. ':' .. displaySeconds .. ' ', 4, 4, VIRTUAL_WIDTH - 8, 'right')
end

function Clock:generateSplitString()
	self.splitString = 'Time: '

	if self.splitHours < 10 then
		-- Maxing displayed hours at 99
		self.splitString = self.splitString .. '0' .. tostring((self.splitHours < 99 ) and self.splitHours or 99)
	else
		self.splitString = self.splitString .. tostring((self.splitHours < 99 ) and self.splitHours or 99)
	end

	if self.splitMinutes < 10 then
		self.splitString = self.splitString .. ':0' .. tostring(self.splitMinutes)
	else
		self.splitString = self.splitString .. ':' .. tostring(self.splitMinutes)
	end

	if self.splitSeconds < 10 then
		self.splitString = self.splitString .. ':0' .. tostring(math.floor(self.splitSeconds))
	else
		self.splitString = self.splitString .. ':' .. tostring(math.floor(self.splitSeconds))
	end

	return self.splitString
end

function Clock:generateTotalString()
	self.totalString = 'Time: '

	if self.totalHours < 10 then
		-- Maxing displayed hours at 99
		self.totalString = self.totalString .. '0' .. tostring((self.totalHours < 99 ) and self.totalHours or 99)
	else
		self.totalString = self.totalString .. tostring((self.totalHours < 99 ) and self.totalHours or 99)
	end

	if self.totalMinutes < 10 then
		self.totalString = self.totalString .. ':0' .. tostring(self.totalMinutes)
	else
		self.totalString = self.totalString .. ':' .. tostring(self.totalMinutes)
	end

	if self.totalSeconds < 10 then
		self.totalString = self.totalString .. ':0' .. tostring(math.floor(self.totalSeconds))
	else
		self.totalString = self.totalString .. ':' .. tostring(math.floor(self.totalSeconds))
	end

	return self.totalString
end
