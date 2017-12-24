function saveMap(path)
	mapPath = path .. campaignMapList[campaignLevel] .. ".txt"

	love.filesystem.write(mapPath, "width "..tostring(MAPWIDTH).."\n")
	love.filesystem.append(mapPath, "height "..tostring(MAPHEIGHT).."\n\n")
	
	for j = 1, MAPHEIGHT do
		newMapLine = "m"
		for i = 1, MAPWIDTH do
			newMapLine = newMapLine .. tostring(tileTable[i][j])
			local s = tostring(secondaryTable[i][j])
			if #s == 1 then
				s = "0"..s
			end
			newMapLine = newMapLine .. s
			
			local u,id = isUnitAt(i,j)
			if u ~= nil then
				newMapLine = newMapLine .. id
			else
				newMapLine = newMapLine .. "00"
			end
		end
		newMapLine = newMapLine .. "\n"
		love.filesystem.append(mapPath, newMapLine) 
	end
	
	love.filesystem.append(mapPath, "\n")
	
	for i,t in pairs(tileList) do
		saveTile(i, mapPath)
	end
	
	for i,u in pairs(unitList) do
		if u.team == 1 then
			unitSaveFile(i, writePath)
		else
			unitSaveMap(i, mapPath)
		end
	end
	
	for i,g in pairs(goalList) do
		saveGoal(i, mapPath)
	end
end


function saveTile(n, path)
	local t = tileList[n]
	
	love.filesystem.append(path, "\nTILE " .. tostring(n) .. "\n")
	love.filesystem.append(path, "tpath " .. tostring(t.path):sub(8) .. "\n")
	love.filesystem.append(path, "tname " .. tostring(t.name) .. "\n")
	
	love.filesystem.append(path, "cost " .. tostring(t.cost) .. "\n")
	
	if t.def ~= 0 then
		love.filesystem.append(path, "def " .. tostring(t.def) .. "\n")
	end
	
	if t.eva ~= 0 then
		love.filesystem.append(path, "eva " .. tostring(t.eva) .. "\n")
	end
end

function saveGoal(n, path)
	local g = goalList[n]
	
	love.filesystem.append(path, "\nGOAL " .. g.goalType .. "\n")
	
	if g.goalU ~= nil then
		love.filesystem.append(path, "unit " .. tostring(g.goalU) .. "\n")
	end
	
	if g.goalI ~= nil then
		love.filesystem.append(path, "gi " .. tostring(g.goalI) .. "\n")
	end
	
	if g.goalJ ~= nil then
		love.filesystem.append(path, "gj " .. tostring(g.goalJ) .. "\n")
	end
end


---------------------
---- UNIT MANAGE ----
---------------------

function unitSaveAll()
	for n,u in pairs(unitList) do
		if u.health > 0 then
			unitSaveFile(n, writePath)
		end
	end
end

function unitSaveFile(n, path)
	u = unitList[n]
	uFilename = u.name .. tostring(n) .. ".txt"	
	path = path .. uFilename
	
	love.filesystem.write(path, "uname ".. u.name .."\n")
	love.filesystem.append(path, "ulore ".. u.lore .."\n")
	love.filesystem.append(path, "team ".. u.team .."\n")
	
	love.filesystem.append(path, "class ".. u.class .."\n")
	love.filesystem.append(path, "level ".. u.level .."\n")
	love.filesystem.append(path, "exper ".. u.experience .."\n")
	love.filesystem.append(path, "upath ".. u.path .."\n")
	
	love.filesystem.append(path, "maxhp ".. u.healthMax .."\n")
	love.filesystem.append(path, "curhp ".. u.health .."\n")
	love.filesystem.append(path, "stren ".. u.strength .."\n")
	love.filesystem.append(path, "defen ".. u.defense .."\n")
	love.filesystem.append(path, "speed ".. u.speed .."\n")
	love.filesystem.append(path, "skill ".. u.skill .."\n")
	love.filesystem.append(path, "move ".. u.movement .."\n")

	love.filesystem.append(path, "Gmaxhp ".. u.growthHP .."\n")
	love.filesystem.append(path, "Gstren ".. u.growthStr .."\n")
	love.filesystem.append(path, "Gdefen ".. u.growthDef .."\n")
	love.filesystem.append(path, "Gspeed ".. u.growthSpd .."\n")
	love.filesystem.append(path, "Gskill ".. u.growthSkl .."\n")
	
	love.filesystem.append(path, "acted ".. tostring(u.acted) .. "\n")
	
	for i = 1,inventorySize do 
		if u.inventory[i] ~= nil then
			love.filesystem.append(path, "inv " .. u.inventory[i] .."\n")
		end
	end
end

function unitSaveMap(n, path)
	u = unitList[n]

	love.filesystem.append(path, "\n\n")
	
	love.filesystem.append(path, "uname ".. u.name .."\n")
	love.filesystem.append(path, "ulore ".. u.lore .."\n")
	love.filesystem.append(path, "team ".. u.team .."\n")
	
	love.filesystem.append(path, "class ".. u.class .."\n")
	love.filesystem.append(path, "level ".. u.level .."\n")
	love.filesystem.append(path, "upath ".. u.path .."\n")
	
	love.filesystem.append(path, "maxhp ".. u.healthMax .."\n")
	love.filesystem.append(path, "curhp ".. u.health .."\n")
	love.filesystem.append(path, "stren ".. u.strength .."\n")
	love.filesystem.append(path, "defen ".. u.defense .."\n")
	love.filesystem.append(path, "speed ".. u.speed .."\n")
	love.filesystem.append(path, "skill ".. u.skill .."\n")
	love.filesystem.append(path, "move ".. u.movement .."\n")
	
	love.filesystem.append(path, "acted ".. tostring(u.acted) .. "\n")
	
	for i = 1,inventorySize do 
		if u.inventory[i] ~= nil then
			love.filesystem.append(path, "inv " .. u.inventory[i] .."\n")
		end
	end
end

function unitParse(n, name)
	-- Read an external unit file
	unitList[n]:setTeam(1)
	
	local savePath = campaignSavePath.. name .. ".txt"
	local newPath = campaignLoadPath .. name .. ".txt"
	
	if not love.filesystem.exists(savePath) then
		path = newPath
	else 
		path = savePath
	end
	
	local unitStrings = {}
	local line
	for line in love.filesystem.lines(path) do
		table.insert(unitStrings, line)
	end
	
	for _,s in ipairs(unitStrings) do
		if s:sub(1,4) == "team" then
			unitList[n]:setTeam(tonumber(s:sub(6)))
		elseif s:sub(1,5) == "class" then
			unitList[n]:setClass(s:sub(7))
		elseif s:sub(1,5) == "level" then
			unitList[n]:setLevel(tonumber(s:sub(7)))
		elseif s:sub(1,5) == "exper" then
			unitList[n].experience = tonumber(s:sub(7))
		elseif s:sub(1,5) == "uname" then
			unitList[n]:setUnitName(s:sub(7))
		elseif s:sub(1,5) == "ulore" then
			unitList[n]:setUnitLore(s:sub(7))
		elseif s:sub(1,5) == "upath" then
			pathIndex = "assets/"..s:sub(7)
			unitList[n].path = pathIndex
			loadUnitSprite(n, pathIndex)
		elseif s:sub(1,3) == "inv" then
			unitList[n]:addWeapon(s:sub(5))	
		elseif s:sub(1,4) == "item" then
			unitList[n]:addItem(s:sub(6))
--- SET STATS
		elseif s:sub(1,5) == "maxhp" then
			unitList[n].healthMax = tonumber(s:sub(7))
		elseif s:sub(1,5) == "curhp" then
			unitList[n].health = tonumber(s:sub(7))
		elseif s:sub(1,5) == "stren" then
			unitList[n].strength = tonumber(s:sub(7))
		elseif s:sub(1,5) == "defen" then
			unitList[n].defense = tonumber(s:sub(7))
		elseif s:sub(1,5) == "speed" then
			unitList[n].speed = tonumber(s:sub(7))
		elseif s:sub(1,5) == "skill" then
			unitList[n].skill = tonumber(s:sub(7))
		elseif s:sub(1,4) == "move" then
			unitList[n].movement = tonumber(s:sub(6))
--- SET GROWTHS
		elseif s:sub(1,5) == "Gmaxhp" then
			unitList[n].growthHP = tonumber(s:sub(7))
		elseif s:sub(1,5) == "Gstren" then
			unitList[n].growthStr = tonumber(s:sub(7))
		elseif s:sub(1,5) == "Gdefen" then
			unitList[n].growthDef = tonumber(s:sub(7))
		elseif s:sub(1,5) == "Gspeed" then
			unitList[n].growthSpd = tonumber(s:sub(7))
		elseif s:sub(1,5) == "Gskill" then
			unitList[n].growthSkl = tonumber(s:sub(7))	
		end
	end
end


---------------------
--- LOAD MAP DATA ---
---------------------

function loadMapFile(path)
	if not love.filesystem.exists(path) then
		return false
	else
		local mapStrings = {}
		local line
		for line in love.filesystem.lines(path) do
			table.insert(mapStrings, line)
		end
		
		local mm = 1
		
		for _,s in ipairs(mapStrings) do
			if s:sub(1, 5) == "width" then
				MAPWIDTH = tonumber(s:sub(-2,-1))
			elseif s:sub(1, 6) == "height" then
				MAPHEIGHT = tonumber(s:sub(-2,-1))
			end
		end
		
		initMap(99,99) --MAPWIDTH, MAPHEIGHT)
		
		for _,s in ipairs(mapStrings) do 
			if s:sub(1, 1) == "m" then
				line = s:sub(2)
				for i = 1,line:len(),5 do
					if mm <= MAPWIDTH then
						local li = math.ceil(i / 5)
						tileTable[li][mm] = tonumber(line:sub(i,i))
						secondaryTable[li][mm] = tonumber(line:sub(i+1,i+2))
						unitTable[li][mm] = line:sub(i+3,i+4)
					end
				end
				mm = mm + 1
			end  
		end
		
		local currentTile = nil
		local currentUnit = nil
		local currentGoal = nil
		local g = 0
		local setStats = false
		
		for _,s in ipairs(mapStrings) do
--- LOAD TILE INFO
			if s:sub(1, 4) == "TILE" then
				currentTile = tonumber(s:sub(6,6))
				local nt = Tile:newTile()
				tileList[currentTile] = nt
			elseif s:sub(1,5) == "tpath" then
				pathIndex = "assets/"..s:sub(7)
				tileList[currentTile].path = pathIndex
				local n,x = loadMapTiles(currentTile, pathIndex)
				tileList[currentTile].xCount = x
				tileList[currentTile].subCount = n
			elseif s:sub(1,5) == "tname" then
				tileList[currentTile]:setTileName(s:sub(7))
			elseif s:sub(1,4) == "cost" then
				tileList[currentTile]:setTileCost(tonumber(s:sub(6)))
			elseif s:sub(1,3) == "def" then
				tileList[currentTile]:setTileDefense(tonumber(s:sub(5)))
			elseif s:sub(1,3) == "eva" then
				tileList[currentTile]:setTileEvade(tonumber(s:sub(5)))
			elseif s:sub(1,3) == "hea" then
				tileList[currentTile]:setTileHeal(tonumber(s:sub(5)))
			elseif s:sub(1,3) == "fra" then
				tileList[currentTile].frames = tostring(s:sub(8))
			elseif s:sub(1,3) == "tag" then
				table.insert(tileList[currentTile].tags,s:sub(5))
			end
			
--- LOAD AI UNITS			
			if s:sub(1,6) == "AIUNIT" then
				currentUnit = s:sub(8,9)
				local nu = Unit:newUnit()
				unitList[currentUnit] = nu
				setStats = false
			elseif s:sub(1,4) == "team" then
				unitList[currentUnit]:setTeam(tonumber(s:sub(6)))
			elseif s:sub(1,5) == "class" then
				unitList[currentUnit]:setClass(s:sub(7))
			elseif s:sub(1,5) == "level" then
				unitList[currentUnit]:setLevel(tonumber(s:sub(7)))
			elseif s:sub(1,5) == "uname" then
				unitList[currentUnit]:setUnitName(s:sub(7))
			elseif s:sub(1,5) == "ulore" then
				unitList[currentUnit]:setUnitLore(s:sub(7))
			elseif s:sub(1,5) == "upath" then
				pathIndex = "assets/"..s:sub(7)
				unitList[currentUnit].path = pathIndex
				loadUnitSprite(currentUnit, pathIndex)	
			elseif s:sub(1,5) == "aggro" then
				unitList[currentUnit].aggression = tonumber(s:sub(7))
			elseif s:sub(1,5) == "delta" then
				unitList[currentUnit]:setDelta(tonumber(s:sub(7,8)),tonumber(s:sub(9,10)),tonumber(s:sub(11,12)),tonumber(s:sub(13,14)),tonumber(s:sub(15,16)))
			elseif s:sub(1,5) == "fixed" then
				unitList[currentUnit]:setFixed(tonumber(s:sub(7,8)),tonumber(s:sub(9,10)),tonumber(s:sub(11,12)),tonumber(s:sub(13,14)),tonumber(s:sub(15,16)))
			elseif s:sub(1,3) == "inv" then
				unitList[currentUnit]:addWeapon(s:sub(5))
			elseif s:sub(1,4) == "item" then
				unitList[currentUnit]:addItem(s:sub(6))
			elseif s:sub(1,5) == "acted" then
				unitList[currentUnit].acted = s:sub(7)
			end
			
			
--- LOAD PERSISTENT UNITS	
			if s:sub(1,6) == "PLUNIT" then
				currentUnit = s:sub(8,9)
				local nu = Unit:newUnit()
				unitList[currentUnit] = nu
				
				unitParse(currentUnit, s:sub(11))
				unitList[currentUnit].setStats = true
			end
			
			
--- LOAD GOAL INFO			
			if s:sub(1,4) == "GOAL" then
				g = g + 1
				local ng = Goal:newGoal()
				goalList[g] = ng
				goalList[g].goalType = s:sub(6)
				
				if goalList[g].goalType == "KILL" or goalList[g].goalType == "CAPTURE" or goalList[g].goalType == "SURVIVE" then
					goalWinMax = goalWinMax + 1
				end
			elseif s:sub(1,2) == "gi" then
				goalList[g].goalI = tonumber(s:sub(4))
			elseif s:sub(1,2) == "gj" then
				goalList[g].goalJ = tonumber(s:sub(4))
			elseif s:sub(1,4) == "unit" then
				goalList[g].goalU = s:sub(6)
				if unitList[goalList[g].goalU] ~= nil then
					if goalList[g].goalType == "KILL" then
						unitList[goalList[g].goalU].objective = 1
					elseif goalList[g].goalType == "SAVE" then
						unitList[goalList[g].goalU].objective = 2
					end
				end
			elseif s:sub(1,2) == "gn" then
				goalList[g].goalN = tonumber(s:sub(4))
			end
		end
		
		for m = 1,MAPWIDTH do
			for n = 1,MAPHEIGHT do
				local u = unitTable[m][n]
				if u ~= "00" then
					unitList[u]:setPosition(m,n)
					local unitClass = unitList[u].class
					if unitClass ~= nil then
					
						unitList[u].movement = classList[unitClass].move
						unitList[u]:setClassSpecialMovement(unitClass)
						
						if not unitList[u].setStats then
							if unitList[u].fixed == nil then
								unitList[u]:setDefaultArray(unitClass, unitList[u].level)
								if unitList[u].delta ~= nil then
									unitList[u]:incrementStatArray(unitList[u].delta[1],unitList[u].delta[2],unitList[u].delta[3],unitList[u].delta[4],unitList[u].delta[5])
								end
							else
								unitList[u]:setStatArray(unitList[u].fixed[1],unitList[u].fixed[2],unitList[u].fixed[3],unitList[u].fixed[4],unitList[u].fixed[5],unitList[u].move)
							end						
						end	
					end
				end	
			end  
		end
	end
	
	initCamera()
end