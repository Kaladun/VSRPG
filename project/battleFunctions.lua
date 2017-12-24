function initBattle()
	activePlayer = 1
	teams = 2
	battleState = "select"	--select, movement, action, banner
	optionStateList = {"Attack", "Items", "Trade", "Wait"}  
	optionState = 0
	optionItem = 1
	
	turnStartCooldown = 0
	turnStartCooldownMax = 2
	
	totalTurns = 0
end

function unitsToMove(team)
	count = 0
	for _,u in pairs(unitList) do
		if u.team == team and u.health > 0 and not u.acted then
			count = count + 1
		end
	end
	return count
end

function nextUnitToMove(team)
	for _,u in pairs(unitList) do
		if u.team == team and u.health > 0 and not u.acted then
			return u
		end
	end
end

function countTeamSize(team)
	count = 0
	for _,u in pairs(unitList) do
		if u.team == team and u.health > 0 then
			count = count + 1
		end
	end
	return count
end

function resetActed(n)
	for _,u in pairs(unitList) do
		u.acted = false
	end
end

function switchActivePlayer()
	resetActed(activePlayer)
	local n = activePlayer
	
	for i = 1,teams do
		n = n + 1
		if n > teams then
			n = 1
		end
		
		if unitsToMove(n) > 0 then
			activePlayer = n
			break
		end
	end
	
	clearRangeGrid()
	unitStartTurn(activePlayer)
end

-------

function selectControl(m,n,confirm,cancel)
	if confirm and isInMap(m,n) then
	--Check for new selected unit		
		local foundUnit = false
		for _,u in pairs(unitList) do
			if u.i == m and u.j == n and u.health > 0 and u.team == activePlayer and not u.acted then
				selectedUnit = u
				moveRange(m,n)
				attackRange(u.sumMovement, u:getRangeList())
				foundUnit = true
				originalI = u.i
				originalJ = u.j
				
				battleState = "navigate"
			elseif u.i == m and u.j == n and u.health > 0 and activePlayer == 1 and not u.team ~= 1 then
				if not u.inRangeGrid then
					u.inRangeGrid = true
				else
					u.inRangeGrid = false
				end
			end
		end
	elseif cancel then
		clearRangeGrid()
	end
end

function navigateControl(u,m,n,confirm,cancel,stay)
	if confirm and not (u.i == m and u.j == n) then
		if isInMap(m,n) then
			if ((navGrid[m][n].distance <= u.sumMovement and isUnitAt(m,n) == nil) or activePlayer ~= 1) then
				u.targetI = m
				u.targetJ = n
			
				if navGrid[m][n].distance > u.sumMovement or isUnitAt(u.targetI,u.targetJ) ~= nil then
					while navGrid[u.targetI][u.targetJ].distance > u.sumMovement or isUnitAt(u.targetI,u.targetJ) ~= nil do
						u.targetI = navGrid[u.targetI][u.targetJ].parent[1]
						u.targetJ = navGrid[u.targetI][u.targetJ].parent[2]
					end
				end
				
				u.unitMoveTimer = 0
				u.unitMoveDone = false
				battleState = "movement"

				
				if u.targetI == u.i and u.targetJ == u.j then
					u:setPosition(originalI, originalJ)
					battleState = "select"	
				end
			end
		end
	elseif cancel then
		u:setPosition(originalI, originalJ)
		battleState = "select"
	elseif stay or (u.i == m and u.j == n and confirm) then
		battleState = "option"
		optionState = 1
		if activePlayer ~= 1 then
			battleState = "action"
		end
		
		localAttackRange(u.i, u.j, u:getRangeList())				
	end
end

function moveControl(u,dt)
	if not u.unitMoveDone then	
		if u.unitMoveTimer > 1 then
			u.unitMoveTimer = 0
			u:setPosition(u.nextI, u.nextJ)
		end
		
		if u.unitMoveTimer <= 0 then
			u.nextI, u.nextJ = pathNext(u.i, u.j, u.targetI, u.targetJ)
		end
	
		u.unitMoveTimer = u.unitMoveTimer + 6*dt
		u:move(u.nextI, u.nextJ, u.unitMoveTimer)	
			
		if u.i == u.targetI and u.j == u.targetJ then
			u.unitMoveDone = true
		end
	else
		battleState = "action"
	
		if u.team == 1 then
			battleState = "option"
			optionState = 1
		end	
	
		localAttackRange(u.i, u.j, u:getRangeList())
		u.nextI = nil
		u.nextJ = nil
	end
end

function optionControl(confirm, cancel, right, left, u, dt)
	local d = 0
	if right then
		d = -1
	elseif left then
		d = 1
	end
	
	optionState = optionState + d
	if optionState > #optionStateList then
		optionState = 1
	elseif optionState < 1 then
		optionState = #optionStateList
	end
	
	if confirm then
		if optionState == 1 then
			battleState = "weaponry"
		elseif optionState == 2 then
			battleState = "items"
			optionItem = 1
		elseif optionState == 3 then
			battleState = "tradeSelect"
		elseif optionState == 4 then
			selectedUnit:unitEndTurn()
			battleState = "select"
			selectedUnit = -1
		end
	end
	
	if cancel then		
		battleState = "navigate"
		selectedUnit:setPosition(originalI, originalJ)
		attackRange(selectedUnit.sumMovement, selectedUnit:getRangeList())
	end
end

function weaponryControl(confirm, cancel, right, left, u, dt)
	local n = u.equipped
	local k = n
	
	local d = 0
	if right then
		d = 1
	elseif left then
		d = -1
	end
	
	if d ~= 0 and n ~= nil then
		u:cycleWeapon(d)
	end	
		
	if confirm then
		if countReadyWeapons(u) <= 0 then
			u:unitEndTurn()
			battleState = "select"
			selectedUnit = -1
		else
			battleState = "action"
		
			if countReadyWeapons(u) == 0 then
				localAttackRange(u.i, u.j, {})
			else
				localAttackRange(u.i, u.j, getWeaponRangeList(u.inventory[u.equipped]))
			end
				
			u.nextI = nil
			u.nextJ = nil		
		end
	end
	
	if cancel then		
		battleState = "option"
		optionState = 1
	end
end

function itemControl(confirm, cancel, right, left, u, dt)
	local c = countReadyItems(u)
	
	if c > 0 then
		local i
		local n = 0
		local iCur = 1
		local iList = {}
		for i = 1,itemSize do
			if u.items[i] ~= nil and u.uses[i] > 0 then
				table.insert(iList, i)
				n = n + 1
				if i == optionItem then
					iCur = n
				end
			end
		end
	
		local d = 0
		if right then
			d = -1
		elseif left then
			d = 1
		end
		
		if d ~= 0 then
			iCur = clamp(iCur + d, 1, #iList)
			optionItem = iList[iCur]
		end
		
		if confirm and u.items[optionItem] ~= nil and u.uses[optionItem] > 0 then
			local used = false
			local hpval = getItemHeal(u.items[optionItem])
			local b = getItemBuffs(u.items[optionItem])
			
			if hpval ~= 0 then
				callSoloHealth(u, hpval)
				used = true
			end
			
			if b ~= {} then
				for i,v in pairs(b) do
					useBuffItem(u, v)
				end
				
				used = true
			end	
			
			if used then
				u.uses[optionItem] = u.uses[optionItem] - 1
				if u.uses[optionItem] <= 0 then
					u:removeItem(optionItem)
				end	
			end
			
			u:unitEndTurn()
			battleState = "select"
			selectedUnit = -1
		end
	end
	
	if cancel then		
		battleState = "option"
		optionState = 2
	end
end

function tradeSelect(confirm, cancel, m, n, u, dt)
	if confirm and isInMap(m,n) then
		tu = isUnitAt(m,n)
		if tu ~= nil then
			if tu.team == 1 and tileDistance(u.i,u.j,tu.i,tu.j) == 1 then
				tradeUnit = tu
				
				startNewTrade(u, tu)
				battleState = "tradeAction"
			end
		end
	end
	
	if cancel then
		battleState = "option"
		optionState = 3
	end
end

function tradeAction(confirm, cancel, uL, uR, up, down, left, right, dt)
	local traded = false

	if up then
		tradeCursorJ = clamp(tradeCursorJ - 1, 1, itemSize + inventorySize + 1)
	elseif down then
		tradeCursorJ = clamp(tradeCursorJ + 1, 1, itemSize + inventorySize + 1)
	end
	
	if left then
		tradeCursorI = clamp(tradeCursorI - 1, 1, 2)
	elseif right then
		tradeCursorI = clamp(tradeCursorJ + 1, 1, 2)
	end	
	
	if confirm then
		if tradeCursorJ == 9 then
			finishTrade(uL, uR)
			
			uL:unitEndTurn()
			battleState = "select"
			selectedUnit = -1				
		else
			if tradeCursorI <= 1 then
				if tradeRightSelect ~= nil then
					if (tradeRightSelect <= 4 and tradeCursorJ <= 4) or (tradeRightSelect >= 5 and tradeCursorJ >= 5) then 
						tradeExchange(tradeCursorJ, tradeRightSelect)
						traded = true
					end
				else
					if tradeCursorJ <= 4 then
						if tempInvLeft[tradeCursorJ] ~= nil then
							tradeLeftSelect = tradeCursorJ
						end
					else
						if tempItemLeft[tradeCursorJ - 4] ~= nil then
							tradeLeftSelect = tradeCursorJ
						end
					end	
				end
			elseif tradeCursorI >= 2 then
				if tradeLeftSelect ~= nil then
					if (tradeLeftSelect <= 4 and tradeCursorJ <= 4) or (tradeLeftSelect >= 5 and tradeCursorJ >= 5) then
						tradeExchange(tradeLeftSelect, tradeCursorJ)
						traded = true
					end
				else	
					if tradeCursorJ <= 4 then
						if tempInvRight[tradeCursorJ] ~= nil then
							tradeRightSelect = tradeCursorJ
						end
					else
						if tempItemRight[tradeCursorJ - 4] ~= nil then
							tradeRightSelect = tradeCursorJ
						end
					end	
				end
			end
		end
	end	
	
	if traded then
		tradeLeftSelect = nil
		tradeRightSelect = nil	
	end
	
	if cancel then
		battleState = "tradeSelect"
	end
end

function actionControl(m,n,confirm,cancel)
	u = isUnitAt(m,n)
	targetUnit = -1
	if u ~= nil then
		if u.team ~= activePlayer and u.health > 0 then
			targetUnit = u
		end
	end

	if confirm then
		if isInMap(m,n) then
			u = isUnitAt(m,n)
			if u ~= nil and attackGrid[m][n] and (m ~= selectedUnit.i or n ~= selectedUnit.j) then
				if u.team ~= activePlayer then
					unitFight(selectedUnit, u)
					selectedUnit:unitEndTurn()
					battleState = "select"
					selectedUnit = -1
					targetUnit = -1
				end
			end
		end
	elseif cancel then		
		battleState = "weaponry"
	end
end

function aiActionControl(u,v)
	if v ~= nil then 
		local inRange = false
		for _,r in ipairs(u:getRangeList()) do
			if tileDistance(u.i,u.j,v.i,v.j) == r then
				inRange = true
			end
		end
		if inRange then
			unitFight(u,v)
		end
	end
	
	u:unitEndTurn()
	battleState = "select"
	selectedUnit = -1
end