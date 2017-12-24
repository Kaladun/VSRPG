Class = {
	health = 15,
	str = 1,
	def = 1,
	skl = 1,
	spd = 1,

	growthHP = 35,
	growthStr = 10,
	growthDef = 10,
	growthSkl = 10,
	growthSpd = 10,
	
	armor = 0,
	move = 5,
	
	specialMovement = {},
	bonusMana = 0,
}

function loadClassData(path)
	local classStrings = {}
	local line
	for line in love.filesystem.lines("data/classes.txt") do
		table.insert(classStrings, line)
	end
			
	classList = {}		
			
	local currentClass = nil
	
	for _,s in ipairs(classStrings) do 
		local spre = s:sub(1,3)
		if spre == "NEW" then
			currentClass = s:sub(5)
			classList[currentClass] = Class:newClass()
		elseif spre == "mhp" then
			classList[currentClass].health = tonumber(s:sub(5,6))
			classList[currentClass].growthHP = tonumber(s:sub(8))
		elseif spre == "str" then
			classList[currentClass].str = tonumber(s:sub(5,6))
			classList[currentClass].growthStr = tonumber(s:sub(8))
		elseif spre == "def" then
			classList[currentClass].def = tonumber(s:sub(5,6))
			classList[currentClass].growthDef = tonumber(s:sub(8))
		elseif spre == "skl" then
			classList[currentClass].skl = tonumber(s:sub(5,6))
			classList[currentClass].growthSkl = tonumber(s:sub(8))
		elseif spre == "spd" then
			classList[currentClass].spd = tonumber(s:sub(5,6))
			classList[currentClass].growthSpd = tonumber(s:sub(8))
		elseif spre == "mov" then
			classList[currentClass].move = tonumber(s:sub(6))
		elseif spre == "arm" then
			classList[currentClass].armor = tonumber(s:sub(7))
		elseif spre == "smo" then
			local csml = classList[currentClass].specialMovement
			local smname = s:sub(7,-4)
			local smval = tonumber(s:sub(-2))
			csml[smname] = smval
		end
	end
end

function Class:newClass(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	o.specialMovement = {}
	return o
end

function getClassHitBonus(class,item)
	local b = 0
	local g = getWeaponClass(item) 
	
	if (g == "gun" or g == "bow") and class == "Marksman" then
		b = 10
	elseif g == "melee" and class == "Soldier" then
		b = 10
	end
	
	return b
end

function getClassManaBonus(class)
	return classList[class].bonusMana
end