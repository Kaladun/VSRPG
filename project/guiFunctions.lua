function drawSmallStatBox()
	local mouseI = coordToTile(input.mouseX)
	local mouseJ = coordToTile(input.mouseY)
	local x = 10
	local y = 10
	local w = 200
	local tw = 140
	
	if isInMap(mouseI, mouseJ) then
		u = isUnitAt(mouseI, mouseJ)
		if u ~= nil then
			local t = tileTable[mouseI][mouseJ]
			local c = teamColors[u.team]
			
			love.graphics.setColor(c[1],c[2],c[3],192)
			love.graphics.rectangle("fill",10,10,w,72,8,4)
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf(u.name, x, y, w, "center")
			
			y = y + 24
			love.graphics.line(x+4,y,x+w-4,y)
			
			love.graphics.print("Health", x+4, y)
			love.graphics.print(tostring(u.health) .. "/" .. tostring(u.healthMax), x+tw, y)
			
			y = y + 24
			love.graphics.print("Counter", x+4, y)
			love.graphics.print(tostring(u.counter) .. "/" .. tostring(u.counterMax), x+tw, y)
		end
	end
end

function drawFullStatBox()
	local mouseI = coordToTile(input.mouseX)
	local mouseJ = coordToTile(input.mouseY)
	local x = 10
	local y = 10
	local h = 12 * 24
	local w = 200
	local tw = 140
	local ti = 180
	
	if isInMap(mouseI, mouseJ) then
		u = isUnitAt(mouseI, mouseJ)
		if u ~= nil then
			local c = teamColors[u.team]
			
			love.graphics.setColor(c[1],c[2],c[3],192)
			love.graphics.rectangle("fill",10,10,2*w,h,8,8,4)
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf(u.name, x, y, w, "center")
--			y = y + 24
--			love.graphics.printf(u.lore, x+4, y, w, "left")
			
			y = y + 24
			love.graphics.print(u.class .. "  " .. tostring(u.level), x+4, y)
			if u.team == 1 then
				love.graphics.print(u.experience .. "xp", x+tw, y)
			end
			
			y = y + 36
			love.graphics.line(x+4,y,x+w,y)
			y = y + 12
			
			love.graphics.print("Health", x+4, y)
			love.graphics.print(tostring(u.health) .. "/" .. tostring(u.healthMax), x+tw, y)
			
			y = y + 24
			love.graphics.print("Strength", x+4, y)
			if u.strength == u.sumStrength then
				love.graphics.print(tostring(u.strength), x+tw, y)
			else
				love.graphics.print(tostring(u.strength) .. "+" .. tostring(u.sumStrength - u.strength), x+tw, y)
			end
			
			y = y + 24
			love.graphics.print("Defense", x+4, y)
			if u.defense == u.sumDefense then
				love.graphics.print(tostring(u.defense), x+tw, y)
			else
				love.graphics.print(tostring(u.defense) .. "+" .. tostring(u.sumDefense - u.defense), x+tw, y)
			end
			
			y = y + 24
			love.graphics.print("Armor", x+4, y)
			if u.armor == u.sumArmor then
				love.graphics.print(tostring(u.armor), x+tw, y)
			else
				love.graphics.print(tostring(u.armor) .. "+" .. tostring(u.sumArmor - u.armor), x+tw, y)
			end
			
			y = y + 24
			love.graphics.print("Skill", x+4, y)
			if u.skill == u.sumSkill then
				love.graphics.print(tostring(u.skill), x+tw, y)
			else
				love.graphics.print(tostring(u.skill) .. "+" .. tostring(u.sumSkill - u.skill), x+tw, y)
			end
			
			y = y + 24
			love.graphics.print("Speed", x+4, y)
			if u.speed == u.sumSpeed then
				love.graphics.print(tostring(u.speed), x+tw, y)
			else
				love.graphics.print(tostring(u.speed) .. "+" .. tostring(u.sumSpeed - u.speed), x+tw, y)
			end
			
			y = y + 36
			love.graphics.line(x+4, y, x+w, y)			
			y = y + 12 
			
			love.graphics.print("Counter", x+4, y)
			love.graphics.print(tostring(u.counter) .. "/" .. tostring(u.counterMax), x+tw, y)
			
			love.graphics.line(x+w,10+4,x+w,10+h-4)
		
			
			
			y = 10
			local h = 0
			local d = 0
			
			for i = 1,inventorySize do
				if u.inventory[i] ~= nil then
					if u.cooldown[i] > 0 then
						love.graphics.setColor(208,208,208,255)
						love.graphics.print(u.inventory[i], x+w+8, y)
						love.graphics.print(u.cooldown[i], x+w+ti, y)
					else
						love.graphics.print(u.inventory[i], x+w+8, y)
					end
					love.graphics.setColor(255,255,255,255)
				
					if i == u.equipped then
						love.graphics.rectangle("line",x+w+5,y+2,w-9,20,2,2,3)
						h = baseHitRate(u, i)
						d = baseDamage(u, i) --getWeaponDamage(u.inventory[i])
					end
					y = y + 24
				end
			end
			
			y = 10 + 24 * inventorySize + 12
			love.graphics.line(x+w,y,x+2*w,y)
			y = y+12
			
			for i = 1,itemSize do
				if u.items[i] ~= nil then
					love.graphics.print(u.items[i], x+w+8, y)
					love.graphics.print(u.uses[i], x+w+ti, y)
					y = y + 24
				end
			end			
			
			y = 10 + 24 * (inventorySize + itemSize) + 12
			love.graphics.line(x+w,y,x+2*w-4,y)
			y = y + 12
			
			love.graphics.print("Hit%", x+w+4, y)
			love.graphics.print("Damage", x+w+4, y+24)
			love.graphics.print("Evade%", x+w+4, y+48)
			
			local sd = tostring(d)
			if getWeaponPierce(u.inventory[u.equipped]) > 0 then
				sd = sd .. "  p" .. tostring(math.floor(50 * getWeaponPierce(u.inventory[u.equipped]))) .. "%"
			end
			
			local e = baseEvadeRate(u, i)
			
			love.graphics.print(tostring(h), x+w+tw-40, y)
			love.graphics.print(sd, x+w+tw-40, y+24)
			love.graphics.print(tostring(e), x+w+tw-40, y+48)
		end
	end	
end

function drawOptionSelect(x,y,u) 
	if u ~= nil then
		local w,tw = 200,140
		local c = teamColors[u.team]
		love.graphics.setColor(c[1],c[2],c[3],192)		 			
		love.graphics.rectangle("fill",x,y,200, 24*#optionStateList,8,8,4)
		
		love.graphics.setColor(255,255,255,255)
		
		for i = 1,#optionStateList do
			love.graphics.print(optionStateList[i], x+8, y)
			
			if i == optionState then
				love.graphics.rectangle("line",x+5,y+2,w-9,20,2,2,3)
			end
			
			y = y + 24
		end
	end
end

function drawItemSelect(x,y,u)
	if u ~= nil then
		local w,tw = 200,140
		x = clamp(x, 0, WINDOWWIDTH - w)
		
		local c = teamColors[u.team]
		love.graphics.setColor(c[1],c[2],c[3],192)
		
		if countReadyItems(u) > 0 then			
			love.graphics.rectangle("fill",x,y,w, 24*6,8,8,4)
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.line(x+4,y+24*4,x+w-4,y+24*4)
			
			for i = 1,itemSize do
				if u.items[i] ~= nil then
					if u.uses[i] > 0 then
						love.graphics.print(u.items[i], x+8, y)
						love.graphics.print(u.uses[i], x+tw, y)
					end
				
					if i == optionItem then
						love.graphics.rectangle("line",x+5,y+2,w-9,20,2,2,3)
					end
				end
				y = y + 24
			end
			
			if u.items[optionItem] ~= nil then
				love.graphics.printf(getItemDescription(u.items[optionItem]), x+8, y, w-16, "left")
			end
		else
			love.graphics.rectangle("fill",x,y,w,24,8,8,4)
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf("No items available",x,y,w,"center")
		end
	end
	love.graphics.setColor(255,255,255,255)
end

function drawWeaponSelect(x,y,u)
	if u ~= nil then
		local w,tw = 200,140
		x = clamp(x, 0, WINDOWWIDTH - w)
		
		local c = teamColors[u.team]
		love.graphics.setColor(c[1],c[2],c[3],192)
		
		if countReadyWeapons(u) > 0 then			
			love.graphics.rectangle("fill",x,y,200, 24*6,8,8,4)
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.line(x+4,y+24*4,x+w-4,y+24*4)
			
			for i = 1,inventorySize do
				if u.inventory[i] ~= nil then
					if u.cooldown[i] > 0 then
						love.graphics.setColor(208,208,208,255)
						love.graphics.print(u.inventory[i], x+8, y)
						love.graphics.print(u.cooldown[i], x+tw, y)
					else
						love.graphics.print(u.inventory[i], x+8, y)
					end
					love.graphics.setColor(255,255,255,255)
				
					if i == u.equipped then
						love.graphics.rectangle("line",x+5,y+2,w-9,20,2,2,3)
						h = baseHitRate(u, i)
						d = baseDamage(u, i) --getWeaponDamage(u.inventory[i])
					end
				end
				y = y + 24
			end
			
			love.graphics.print("Hit%",x+4,y)
			love.graphics.print(tostring(baseHitRate(u,u.equipped)), x+tw, y)
			
			y = y + 24
			love.graphics.print("Damage",x+4,y)
			love.graphics.print(tostring(baseDamage(u,u.equipped)), x+tw, y)
		else
			love.graphics.rectangle("fill",x,y,w,24,8,8,4)
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf("No weapons ready!",x,y+4,100,"center")
		end
	end
	love.graphics.setColor(255,255,255,255)
end

function drawCombatPrediction(u,t)
	if u ~= -1 and t ~= -1 then
		local x,y = coordsToGUI(t.x, t.y)
		x = clamp(x, 0, WINDOWWIDTH - w)
	
		local w,tw = 200,140
		local c = teamColors[u.team]
		
		love.graphics.setColor(c[1], c[2], c[3], 192)		
		love.graphics.rectangle("fill",x,y,200, 24*3,8,8,4)
			
		love.graphics.setColor(255,255,255,255)
	--	love.graphics.line(x+4,y+24*4,x+w-4,y+24*4)
		
		love.graphics.printf(u.inventory[u.equipped],x,y,200,"center")
		y = y + 24
		
		love.graphics.print("Hit Rate",x+4,y)
		love.graphics.print(tostring(computeHitRate(u,t) * 100) .. "%", x+tw, y)
		
		y = y + 24
		love.graphics.print("Damage",x+4,y)
		local d = computeDamage(u,t)
		love.graphics.print(tostring(d), x+tw, y)
		
		if t:canCounter(u) then
			y = y + 30
			
			local c = teamColors[t.team]
			love.graphics.setColor(c[1], c[2], c[3], 192)		
			love.graphics.rectangle("fill",x,y,200, 24*3,8,8,4)
		
			love.graphics.setColor(c[1], c[2], c[3], 192)		
			love.graphics.rectangle("fill",x,y,200, 24*3,8,8,4)
				
			love.graphics.setColor(255,255,255,255)
		--	love.graphics.line(x+4,y+24*4,x+w-4,y+24*4)
			
			love.graphics.printf("Counter!",x,y,200,"center")
			y = y + 24
			
			love.graphics.print("Hit Rate",x+4,y)
			love.graphics.print(tostring(computeHitRate(t,u) * 100) .. "%", x+tw, y)
			
			y = y + 24
			love.graphics.print("Damage",x+4,y)
			local d = computeDamage(t,u)
			love.graphics.print(tostring(d), x+tw, y)
		end
	end
end

function drawTerrainInfo()
	local mouseI = coordToTile(input.mouseX)
	local mouseJ = coordToTile(input.mouseY)
	local y = 10
	local x = WINDOWWIDTH - 170
	
	if isInMap(mouseI, mouseJ) then
		local d = getTileDefense(mouseI, mouseJ)
		local e = getTileEvade(mouseI, mouseJ)
		local h = getTileHeal(mouseI, mouseJ)
		
		local m = 1
		local ns = false
		local n = getTileName(mouseI, mouseJ)
		
		if d ~= 0 then
			m = m + 1
		end
		
		if e ~= 0 then
			m = m + 1
		end
		
		if h ~= 0 then
			m = m + 1
		end
		
		if m == 1 then
			ns = true
		end
		
		m = clamp(m,2,10)
		
		local c = teamColors[1]	
		love.graphics.setColor(c[1],c[2],c[3],192)
		love.graphics.rectangle("fill",x,10,160,24*m,8,8,4)
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(n, x, y, 160, "center")
		y = y + 24
		
		if ns then
			love.graphics.printf("no effects", x, y, 160, "center")
		else
			if d ~= 0 then
				love.graphics.print("+"..tostring(d).." Defense",x + 4, y)
				y = y + 24
			end
			
			if e ~= 0 then 
				love.graphics.print("+"..tostring(e).."% Evade",x + 4, y)
				y = y + 24
			end
			
			if h < 0 then
				love.graphics.print("Damages "..tostring(math.abs(h)),x + 4, y)
			elseif h > 0 then
				love.graphics.print("Heals "..tostring(h),x + 4, y)
			end
		end
	end
end

function drawTurnBanner(text, n, m)
	local x,y,dx = WINDOWWIDTH / 2, WINDOWHEIGHT / 2, WINDOWWIDTH * 0.75
	
	local to = love.graphics.newText(megaFont, text)
	tx = smoothnormal(x - dx, x + dx, n/m, 0.33) - to:getWidth()/2
	love.graphics.draw(to, tx, y - to:getHeight()/2)
end