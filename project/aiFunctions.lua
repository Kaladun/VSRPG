function initAI()
	aiGrid = {}
	for i = 1,MAPWIDTH do
		aiGrid[i] = {}
			aiGrid[i][j] = {}
		end
	end
end

function aiMoveTarget(u)
	
	if target == nil then
		return false, u.i, u.j, nil
	else	
		return true, ti, tj, target
end

function unitsInRange(list)
	for i = 1,MAPWIDTH do
			if attackGrid[i][j] then
				local u = isUnitAt(i,j)
				if u ~= nil then
					if u.team ~= activePlayer then
						table.insert(list, u)
					end
				end
			end
		end
	end			
end

function clearAIGrid()
	for i = 1,MAPWIDTH do
		aiGrid[i] = {}
		for j = 1,MAPHEIGHT do
			aiGrid[i][j] = {}
		end
	end
end

function chooseTarget(u, tmax)
	clearAIGrid()
	foundTarget = false
	
	t = 0
-- STEP 1 -- Create intersect of can-hit, can-end-turn, and can-move-to grids
	while t <= tmax and not foundTarget do
		for i = 1,MAPWIDTH do
			for j = 1,MAPHEIGHT do
				for _,r in ipairs(u:getRangeList()) do
					for k = -r,r do
						for l = -r+math.abs(k), r-math.abs(k) do
							if isInMap(i+k, j+l) then
								v = isUnitAt(i+k, j+l)
								if v ~= nil and ((navGrid[i][j].distance <= math.ceil(u.movement * t) and isUnitAt(i,j) == nil) or (navGrid[i][j].distance == 0)) then
									if v.team ~= u.team then
										foundTarget = true
										table.insert(aiGrid[i][j], v)
									end
								end
							end
						end
					end
				end
			end
		end
		t = t + 1
	end
	
	if not foundTarget then
		return nil,nil,nil
	else
-- STEP 2 -- Iterate over grid and return the best target & location
		local rank = -10000
		local bestI, bestJ = -1,-1
		local bestTarget, bestItem = nil, nil
		local originalItem = u.equipped
		
		for i = 1,MAPWIDTH do
			for j = 1,MAPHEIGHT do
				if aiGrid[i][j] ~= {} then
					for _,v in ipairs(aiGrid[i][j]) do
						for n = 1,inventorySize do
							if u.inventory[n] ~= nil then
								local rmin, rmax = getWeaponRange(u.inventory[n])
								if tileDistance(i, j, v.i, v.j) >= rmin and tileDistance(i, j, v.i, v.j) <= rmax  and isWeaponReady(u,n) then
									u.equipped = n
									local r = 20 * computeDamage(u,v) - navGrid[i][j].distance 
									if r > rank then
										bestI = i
										bestJ = j
										bestTarget = v
										rank = r
										bestItem = n
									end
								end
							end
						end	
					end
				end
			end
		end
		
		if bestItem == nil then
			u.equipped = originalItem
		else
			u.equipped = bestItem
		end
		
		return bestI, bestJ, bestTarget
	end
	
	return nil,nil,nil
end