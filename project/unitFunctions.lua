--[[ BASIC UNIT DEFINITIONS ]]--
Unit = {
	health = 10, healthMax = 10,
	strength = 1,
	defense = 0,
	armor = 0,
	skill = 0,
	speed = 0,
	power = 0,
	resolve = 0,
	
	manaMax = 0,
	mana = 0,
	manaRegen = 0,
	
	movement = 5,
	specialMovement = {},
	
	range = {1},
	team = 0,
	name = "?",
	lore = "",
	
	inventory = {},
	items = {},
	equipped = 1,
	
	class = nil,
	delta = nil,
	fixed = nil, 
	
	level = 1,
	experience = 0,
	
	aggression = 1,
	objective = 0,
	inRangeGrid = false,
	
	i = -5, j = -5, x = -160, y = -160, acted = false,
	targetI = nil, targetJ = nil, nextI = nil, nextJ = nil,
	unitMoveDone = false, unitMoveTimer = 0,

	counter = 0,
	counterMax = 0,
	
	buffList = {},
	
	sumStrength = 0,
	sumDefense = 0,
	sumSkill = 0,
	sumSpeed = 0,
	
	sumPower = 0,
	sumResolve = 0,
	
	sumArmor = 0,
	sumMovement = 0,
}
	
function loadUnitSprite(unitIndex, unitSpritePath)
	unitSprites[unitIndex] = love.graphics.newImage(unitSpritePath)
	local spriteW, spriteH = unitSprites[unitIndex]:getWidth(), unitSprites[unitIndex]:getHeight()
	
	unitSubspriteCount = spriteH / unitH	
	unitQuads[unitIndex] = love.graphics.newQuad(0, 0, 16, 16, unitSprites[unitIndex]:getWidth(), unitSprites[unitIndex]:getHeight()) --{}
	
	return unitSubspriteCount
end
	
function initUnits()
	unitList = {}
	unitSprites = {}
	unitQuads = {}
	selectedUnit = -1
	targetUnit = -1
	tradeUnit = -1
	
	teamNames = {"Player","Enemy"}
	teamNames[0] = {"None"}
	teamColors = {{0,160,255},{240,96,32}}
	teamColors[0] = {160,160,160}
	
	inventorySize = 4
	itemSize = 4
	
	objectiveSprites = love.graphics.newImage("assets/unitObjectives.png")
	objectiveQuads = {}
	objectiveQuads[1] = love.graphics.newQuad(0,0,16,16,objectiveSprites:getWidth(),objectiveSprites:getHeight())
	objectiveQuads[2] = love.graphics.newQuad(0,16,16,16,objectiveSprites:getWidth(),objectiveSprites:getHeight())
end

function Unit:newUnit(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
--table.insert(unitList, o)
	
	o.inventory = {nil, nil, nil, nil}
	o.items = {nil, nil, nil, nil}
	o.cooldown = {0,0,0,0}
	o.uses = {0,0,0,0}
	o.buffList = {}
	o.specialMovement = {}
	return o
end


--[[ UNIT INTERACTION ]]--	
function Unit:setTeam(n)
	self.team = n
end

function unitStartTurn(n)
	--Decrement buffs & reset counter for all units on team N
	for _,u in pairs(unitList) do
		if u.team == n then
			for i,c in ipairs(u.cooldown) do
				if c > 0 then
					u.cooldown[i] = u.cooldown[i] - 1
				end
			end
			
			u:updateBuffs()
			u.counter = u:computeCounter()
			u:setCounterMax(u.counter)
		end
	end
	
	turnStartCooldown = turnStartCooldownMax
end

function Unit:unitEndTurn()
	self.acted = true
	
	--Check if they're on a healing / damaging tile	
	if self.health > 0 then
		h = getTileHeal(self.i, self.j)
		
		if (h > 0 and self.health < self.healthMax) or h < 0 then
			callSoloHealth(u,h)
		end
	end	
end

function unitFight(attacker, defender)
-- Top level fight flow control.
-- Inp attacking unit ID, defending unit ID 

	hitA = false
	hitC = false
	
	callCombatSummary(attacker, defender)
	queueCombatSummary(hitL, 0, "")
	
	hitA = unitFightCalculations(attacker, defender, false)
	
	--Counter control
	if defender:canCounter(attacker) then
		hitC = unitFightCalculations(defender, attacker, true)
	end
	
	--Gain XP
	if attacker.team == 1 and attacker.health > 0 then
		local xp = calcAttackXP(attacker, defender, hitA)
		attacker:gainXP(xp)
	elseif defender.team == 1 and defender.health > 0 then
		local xp = calcAttackXP(defender, attacker, hitC)
		defender:gainXP(xp)
	end
end

function unitFightCalculations(attacker, target, hitL)
	local hit = false
	local odds = computeHitRate(attacker, target)
	local damage = computeDamage(attacker, target)
		
	if math.random() < odds then
		queueCombatSummary(hitL, damage, "")
	
		target:damage(damage)
		unitFlashing = target
		flashTimer = 1
--		callPopup(damage, target.x-unitW/2, target.y-unitH/2)
		hit = true
	else
		queueCombatSummary(hitL, 0, "Miss!")
		
--		callPopup(nil, target.x-unitW/2, target.y-unitH/2, "Miss!")
	end
	
	local gwc = getWeaponCooldown(attacker.inventory[attacker.equipped])
	if gwc > 0 then
		attacker.cooldown[attacker.equipped] = gwc
		attacker:cycleWeapon(-1)
	end
	
	return hit
end	
	 
	
	
--[[ UNIT PATHFINDING ]]--
function Unit:move(m,n,t)
	self.x = tileToCoord(lerp(self.i,m,t))
	self.y = tileToCoord(lerp(self.j,n,t))
end

function Unit:setPosition(m,n)
	self.i = m
	self.j = n
	self.x = tileToCoord(m)
	self.y = tileToCoord(n)
end

function pathNext(i,j,m,n)
	if i == m and j == n then
		return m, n
	end

	while tileDistance(i,j,m,n) > 0 do
		mm = m
		nn = n
		m = navGrid[mm][nn].parent[1]
		n = navGrid[mm][nn].parent[2]	
	end
	
	return mm, nn
end
	
function Unit:damage(n)
	self.health = clamp(self.health - n, 0, 100000)
	if self.health <= 0 then
		self:setPosition(-10,-10)
	end
end


--[[ UNIT EXPERIENCE ]]--
function calcAttackXP(attacker, defender, hit)
	local mult = 1
	local levelDiff = defender.level - attacker.level
	
	if hit ~= true then
		mult = 0.5
	end
	
	if defender.health <= 0 then
		mult = mult + 2
		if defender.objective == 1 then
			mult = mult + 1
		end
	end
	
	return math.ceil(clamp(round(10 + levelDiff/2), 1, 100) * mult)
end

function Unit:gainXP(n)
	callExperienceBar(self, n)

	self.experience = self.experience + n
	
	if self.experience >= 100 then
		self.experience = self.experience - 100	
	end
end

function Unit:levelUp()
	bonuses = {0,0,0,0,0}
	self.level = self.level + 1

	if math.random() < self.growthHP / 100 then
		self.healthMax = self.healthMax + 1
		self.health = self.health + 1
		bonuses[1] = 1
	end
	
	if math.random() < self.growthStr / 100 then
		self.strength = self.strength + 1
		bonuses[2] = 1
	end
	
	if math.random() < self.growthDef / 100 then
		self.defense = self.defense + 1
		bonuses[3] = 1
	end
	
	if math.random() < self.growthSkl / 100 then
		self.skill = self.skill + 1
		bonuses[4] = 1
	end
	
	if math.random() < self.growthSpd / 100 then
		self.speed = self.speed + 1
		bonuses[5] = 1
	end
	
	return bonuses
end


--[[ UNIT UTILITY ]]--
function isUnitAt(m,n)
	for id,u in pairs(unitList) do
		if u.i == m and u.j == n and u.health > 0 then
			return u,id
		end
	end
	return nil
end

function Unit:setUnitName(n)
	self.name = n
end

function Unit:setUnitLore(l)
	self.lore = l
end


--[[ UNIT STAT CALCS ]]--
function Unit:setStatArray(mhp,str,def,skl,spd,mve)
	self.healthMax = mhp
	self.health = mhp
	self.strength = str
	self.defense = def
	self.skill = skl
	self.speed = spd
	self.movement = mve
end

function Unit:incrementStatArray(mhp,str,def,skl,spd)
	self.healthMax = self.healthMax + mhp
	self.health = self.health + mhp
	self.strength = self.strength + str
	self.defense = self.defense + def
	self.skill = self.skill + skl
	self.speed = self.speed + spd
end

function Unit:setDelta(a,b,c,d,e)
	self.delta = {}
	self.delta[1] = a
	self.delta[2] = b
	self.delta[3] = c
	self.delta[4] = d
	self.delta[5] = e
end

function Unit:setFixed(a,b,c,d,e)
	self.fixed = {}
	self.fixed[1] = a
	self.fixed[2] = b
	self.fixed[3] = c
	self.fixed[4] = d
	self.fixed[5] = e
end

function Unit:setClass(class)
	self.class = class
	
	local c = classList[class]
	self.armor = c.armor
	
	self.growthHP = c.growthHP
	self.growthStr = c.growthStr
	self.growthDef = c.growthDef
	self.growthSkl = c.growthSkl
	self.growthSpd = c.growthSpd
end

function Unit:setLevel(level)
	self.level = level
end

function Unit:setDefaultArray(class, n)
	--If unit only has a class and level (n), set their stats to the default
	local m = n - 1
	local c = classList[class]
	self:setStatArray(c.health + math.floor(0.01 * m * c.growthHP), c.str + math.floor(0.01 * m * c.growthStr), c.def + math.floor(0.01 * m * c.growthDef), c.skl + math.floor(0.01 * m * c.growthSkl), c.spd + math.floor(0.01 * m * c.growthSpd), c.move)
end

function Unit:setRanges(list)
	self.range = list
end

function Unit:setClassSpecialMovement(class)
	self.specialMovement = classList[class].specialMovement
end		

function Unit:getSpecialMove(i,j)
	local gtt = getTileTags(i,j)
	if gtt == {} then
		return -1
	else
		for _,t in pairs(gtt) do
			for n,v in pairs(self.specialMovement) do
				if n == t then
					return v
				end
			end
		end
	end
	
	return -1
end

--[[ COMBAT CALCS ]]--

function baseDamage(u,i)
	local d = 0
	local sm = 0
	local w = u.inventory[i]
	
	if w ~= nil then
		if getWeaponClass(w) == "bow" then	
			sm = 0.5
		elseif getWeaponClass(w) == "gun" then
			sm = 0
		else 
			sm = 1
		end
		
		d = getWeaponDamage(w) + math.floor(sm * u.sumStrength)
	end
	
	return d
end

function baseHitRate(u,i)
	local a = 0
	local bonus = 0
	
	if u.inventory[i] ~= nil then
		a = getWeaponAccuracy(u.inventory[i])
		
		getClassHitBonus(u.class, u.inventory[i])	
	end
	
	return 50 + 5 * u.sumSkill + 4 * a + 2 * u.sumStrength + bonus
end

function baseEvadeRate(u,i)
	local s = u.sumSpeed
	local e = 4 * s
	
	if isInMap(u.i, u.j) then
		e = e + getTileEvade(u.i, u.j)
	end

	return e
end

function computeDamage(attacker, target)
	local a = baseDamage(attacker, attacker.equipped)	
	local d = target.sumDefense --+ getTileDefense(target.i,target.j)
	local p = round(target.sumArmor * (2 - getWeaponPierce(attacker.inventory[attacker.equipped]))/2)
	
	return clamp(a-d-p, 0,1000)
end

function computeHitRate(attacker, target)
	local a = baseHitRate(attacker, attacker.equipped)
	local d = baseEvadeRate(target, target.equipped)
	
	return clamp(0.01 * (a - d),0,1)
end

function Unit:computeCounter()
	local s = self.sumSpeed
	return s
end

function Unit:canCounter(u)
	local uc = u:computeCounter()
	if self.counter >= math.ceil(uc / 2) and self.health > 0 then
		local a,b = getWeaponRange(self.inventory[self.equipped])
		local d = tileDistance(self.i, self.j, u.i, u.j)
		if d >= a and d <= b then
			return true
		end
	end
	return false
end

function Unit:removeCounter(n)
	self.counter = math.max(0,self.counter - n)
end

function Unit:setCounterMax(n)
	self.counterMax = n
end

--[[ UNIT INVENTORY ]]--

function Unit:addWeapon(name)
	compressInventory(self)

	local added = false
	for i = 1,inventorySize do 
		if self.inventory[i] == nil and not added then
			self.inventory[i] = name
			added = true
		end
	end
end

function Unit:removeWeapon(name)
	local removed = false
	for i = 1,inventorySize do
		if self.inventory[i] == name and not removed then
			self.inventory[i] = nil
			removed = true
		end
	end
	
	compressInventory(self)
end

function Unit:cycleWeapon(d)
	local n = self.equipped + d
	local v = nil
	
	while n ~= self.equipped do
		if isWeaponReady(self, n) then
			v = n
			break
		end		
		
		n = n + d
		if n > inventorySize then
			n = 1
		elseif n < 1 then
			n = inventorySize
		end
	end
	
	self.equipped = v
	
	if countReadyWeapons(self) <= 0 then
		self.equipped = nil
	end
end


function Unit:getRangeList()
	local rangeStore = {}
	for i = 1, inventorySize do
		if self.inventory[i] ~= nil then
			if isWeaponReady(self, i) then				
				local mi,ma = getWeaponRange(self.inventory[i])
				for i = mi,ma do
					rangeStore[i] = true
				end
			end
		end
	end
	
	local rangeList = {}
	for i,_ in pairs(rangeStore) do
		table.insert(rangeList, i)
	end
	return rangeList
end


--[[ UNIT ITEMS ]]--

function Unit:addItem(name)
	compressItems(self)

	local added = false
	local newItem = nil
	for i = 1,itemSize do 
		if self.items[i] == nil and not added then
			self.items[i] = name
			newItem = i
			added = true
		end
	end
	
	if newItem ~= nil then
		self.uses[newItem] = getItemUses(self.items[newItem])
	end
end

function Unit:removeItem(n)
	self.items[n] = nil
	self.uses[n] = 0
	
	compressItems(self)
end

function Unit:computeSumScores()
	-- Aggregate special effects for stat calculations
	self.sumStrength = self.strength
	self.sumDefense = self.defense
	self.sumSpeed = self.speed
	self.sumSkill = self.skill
	
	self.sumArmor = self.armor
	self.sumMovement = self.movement

	for i,v in pairs(self.buffList) do
		if v[1] == "str" then
			self.sumStrength = self.sumStrength + v[2]
		elseif v[1] == "def" then	
			self.sumDefense = self.sumDefense + v[2]
		elseif v[1] == "spd" then	
			self.sumSpeed = self.sumSpeed + v[2]
		elseif v[1] == "skl" then	
			self.sumSkill = self.sumSkill + v[2]
		elseif v[1] == "pow" then	
			self.sumPower = self.sumPower + v[2]
		elseif v[1] == "res" then	
			self.sumResolve = self.sumResolve + v[2]
		elseif v[1] == "arm" then	
			self.sumArmor  = self.sumArmor + v[2]
		elseif v[1] == "mov" then	
			self.sumMovement = self.sumMovement + v[2]
		end
	end
	
	if isInMap(self.i, self.j) then
		local d = getTileDefense(self.i, self.j)
		if d ~= 0 then
			self.sumDefense = self.sumDefense + d
		end
	end
		
	if self.inventory[self.equipped] ~= nil then
		self.sumSpeed = self.sumSpeed + getWeaponSpeed(self.inventory[self.equipped])
	end
	
	self.maxMana = computeMaxMana(self)
	self.manaRegen = computeManaRegen(self)
end

function updateAllSumScores()
	for _,u in pairs(unitList) do
		u:computeSumScores()
	end	
end

function Unit:updateBuffs()
	for i,v in ipairs(self.buffList) do	
		v[4] = v[4] - 1
		
		if v[4] <= 0 then
			table.remove(self.buffList, i)
		end
		
		v[2] = v[2] + v[3]
	end
end


--[[ UNIT GRAPHICS ]]--
function drawUnits()
	for n,u in pairs(unitList) do
	
		if u == unitFlashing then
			shaderFlash:send("magnitude", flashTimer)
			love.graphics.setShader(shaderFlash)
		elseif u.acted then
			love.graphics.setShader(shaderGreyOut)
		end
		love.graphics.draw(unitSprites[n], unitQuads[n], u.x - unitW/2, u.y - unitH/2)
		love.graphics.setShader()
		
		if u.objective > 0 then
			love.graphics.draw(objectiveSprites, objectiveQuads[u.objective], u.x - unitW/2, u.y - unitH/2)
		end
	
		love.graphics.setColor(64,0,0,255)
		love.graphics.rectangle("fill", u.x - unitW/2, u.y + unitH/2 + 1, unitW, 1)
		love.graphics.setColor(255,0,0,255)
		love.graphics.rectangle("fill", u.x - unitW/2, u.y + unitH/2 + 1, math.ceil(unitW * u.health/u.healthMax), 1)
		
		love.graphics.setColor(0,64,16,255)
		love.graphics.rectangle("fill", u.x - unitW/2, u.y + unitH/2 + 2.5, unitW, 1)
		love.graphics.setColor(0,224,64,255)
		love.graphics.rectangle("fill", u.x - unitW/2, u.y + unitH/2 + 2.5, math.ceil(unitW * u.counter/u.counterMax), 1)
		
		love.graphics.setColor(255,255,255,255)
	end
end