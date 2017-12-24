Weapon = {
	damage = 0,
	accuracy = 0,
	rMin = 0,
	rMax = 0,
	cooldownMax = 0,
	pierce = 0,
	speed = 0,
	class = "melee"
}

function Weapon:newWeapon(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	table.insert(weaponList, o)
	return o
end	

function loadWeapons(path)
	local weaponStrings = {}
	local line
	for line in love.filesystem.lines(path) do
		table.insert(weaponStrings, line)
	end
			
	weaponList = {}		
			
	local currentWeapon	= nil
	
	for _,s in ipairs(weaponStrings) do 
		local spre = s:sub(1,3)
		if spre == "NEW" then
			currentWeapon = s:sub(5)
			weaponList[currentWeapon] = Weapon:newWeapon() --{damage = 0, accuracy = 0, rMin = 0, rMax = 0}
		elseif spre == "dam" then
			weaponList[currentWeapon].damage = tonumber(s:sub(8))
		elseif spre == "acc" then
			weaponList[currentWeapon].accuracy = tonumber(s:sub(10))
		elseif spre == "rMi" then
			weaponList[currentWeapon].rMin = tonumber(s:sub(6))
		elseif spre == "rMa" then
			weaponList[currentWeapon].rMax = tonumber(s:sub(6))
		elseif spre == "coo" then
			weaponList[currentWeapon].cooldownMax = tonumber(s:sub(6))
		elseif spre == "cla" then
			weaponList[currentWeapon].class = s:sub(7)
		elseif spre == "pie" then
			weaponList[currentWeapon].pierce = tonumber(s:sub(8))
		elseif spre == "spe" then
			weaponList[currentWeapon].speed = tonumber(s:sub(7))
		end
	end
end

function isWeapon(name)
	if weaponList[name] ~= nil then
		return true
	end
	
	return false
end

function getWeaponDamage(name)
	if isWeapon(name) then
		return weaponList[name].damage
	end
	return 0
end

function getWeaponAccuracy(name)
	if isWeapon(name) then	
		return weaponList[name].accuracy
	end

	return 0
end

function getWeaponRange(name)
	if isWeapon(name) then
		return weaponList[name].rMin, weaponList[name].rMax
	end
		
	return 0
end

function getWeaponRangeList(name)
	if isWeapon(name) then
		local p,q = getWeaponRange(name)
		local l = {}
		for i = p,q do
			table.insert(l,i)
		end
		return l
	end
	
	return {0}
end

function getWeaponCooldown(name)
	if isWeapon(name) then
		return weaponList[name].cooldownMax
	end 
		
	return 0
end

function getWeaponPierce(name)
	if isWeapon(name) then
		return weaponList[name].pierce
	end
		
	return 0
end

function getWeaponSpeed(name)
	if isWeapon(name) then
		return weaponList[name].speed
	end
	
	return 0
end	

function getWeaponClass(name)
	if isWeapon(name) then
		return weaponList[name].class
	end
		
	return 0
end

function isWeaponReady(u, i)
	if u.inventory[i] == nil then
		return false
	end
	
	if u.cooldown[i] > 0 then
		return false
	end
	
	return true
end

function countReadyWeapons(u)
	local n = 0
	for i = 1,inventorySize do
		if u.inventory[i] ~= nil then
			if isWeaponReady(u,i) then
				n = n + 1
			end
		end
	end
	return n
end

function compressInventory(u)
	local iTemp = {nil, nil, nil, nil}
	local cTemp = {0,0,0,0}
	
	local i,j
	
	for i = 1,inventorySize do
		if u.inventory[i] ~= nil then
			for j = 1,i do
				if iTemp[j] == nil then
					iTemp[j] = u.inventory[i]
					cTemp[j] = u.cooldown[i]
					if u.equipped == i then 
						u.equipped = j
					end
					break
				end
			end	
		end
	end
	
	for i = 1,inventorySize do
		u.inventory[i] = iTemp[i]
		u.cooldown[i] = cTemp[i]
	end
end


-------------
--- ITEMS ---
-------------


Item = {
	heal = 0,
	uses = 1,
	description = "",
	buffs = {}
}

function Item:newItem(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	table.insert(itemList, o)
	
	o.buffs = {}
	return o
end	

function loadItems(path)
	local itemStrings = {}
	local line
	for line in love.filesystem.lines(path) do
		table.insert(itemStrings, line)
	end
			
	itemList = {}		
			
	local currentItem = nil
	
	for _,s in ipairs(itemStrings) do 
		local spre = s:sub(1,3)
		if spre == "NEW" then
			currentItem = s:sub(5)
			itemList[currentItem] = Item:newItem() --{damage = 0, accuracy = 0, rMin = 0, rMax = 0}
		elseif spre == "hea" then
			itemList[currentItem].heal = tonumber(s:sub(6))
		elseif spre == "use" then
			itemList[currentItem].uses = tonumber(s:sub(6))
		elseif spre == "des" then
			itemList[currentItem].description = s:sub(6)
		elseif spre == "buf" then
			local b = {s:sub(6,8), tonumber(s:sub(10,11)), tonumber(s:sub(13,14)), tonumber(s:sub(16,17))}
			table.insert(itemList[currentItem].buffs, b)
		end
	end
end

function getItemUses(name)
	return itemList[name].uses
end

function getItemHeal(name)
	return itemList[name].heal
end

function getItemDescription(name)
	return itemList[name].description
end

function getItemBuffs(name)
	return itemList[name].buffs
end

function countReadyItems(u)
	local n = 0
	for i = 1,itemSize do
		if u.items[i] ~= nil and u.uses[i] > 0 then
			n = n + 1
		end
	end
	return n
end

function callSoloHealth(u, n)
	callSoloSummary(u, n, "")
	u.health = clamp(u.health + n, 0, u.healthMax)
	
	if u.health <= 0 then
		u:damage(0)
	end	
end

function useBuffItem(u, b)
	local bt = {b[1], b[2], b[3], b[4]}	
	table.insert(u.buffList, bt)
end

function compressItems(u)
	local iTemp = {nil, nil, nil, nil}
	local uTemp = {0,0,0,0}
	
	local i,j
	
	for i = 1,itemSize do
		if u.items[i] ~= nil then
			for j = 1,i do
				if iTemp[j] == nil then
					iTemp[j] = u.items[i]
					uTemp[j] = u.uses[i]
					break
				end
			end	
		end
	end
	
	for i = 1,inventorySize do
		u.items[i] = iTemp[i]
		u.uses[i] = uTemp[i]
	end
end