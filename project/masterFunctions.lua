--- MAP CONTROL ---

function masterGameInit()
	debugText = ""
	debugN = 0

	writePath = "/" --love.filesystem.getSaveDirectory() .. "/"
	readPath = "data/"
	
	tileW, tileH = 16, 16
	unitW, unitH = tileW, tileH
	
	initUnits()
	initGoals()

	initMapAnims()
	initBattle()
	initInputArray()
	initShaders()
	initEditor()
	
	targetI = 0
	targetJ = 0
end

function masterCampaignInit()
	initCampaign()
	loadCampaignFile("data/campaign0.txt")
	
	campaignLevel = 1
end

function masterMapInit()
	loadClassData("data/classes.txt")
	loadWeapons("data/weapons.txt")
	loadItems("data/items.txt")

	loadMapFile(campaignLoadPath .. campaignMapList[campaignLevel] .. ".txt")
--	loadMapFile(readPath .. campaignMapList[campaignLevel] .. ".txt")
	
	initAI()
	initCamera()
	initNavGrid()
	
	initCombatSummary()
	initExperienceBar()
	initLevelUpDisplay()
	
	menuOption = 1
	menuOptionMax = 3
	menuSelect = false
	
	updateAllSumScores()
	for _,u in pairs(unitList) do
		u:updateBuffs()
		u.counter = u:computeCounter()
		u:setCounterMax(u.counter)
	end
end

function masterMapUpdate(dt)
	local animPlaying = controlMapAnims(dt)
	
	if not displayCombatSummary and not displaySoloSummary and not displayExperienceBar and not displayLevelUp and not animPlaying then
		if unitsToMove(activePlayer) <= 0 and turnStartCooldown == 0 then
			switchActivePlayer()
		end
		
		local lock = false
		
		if turnStartCooldown == 0 then 
			updateAllSumScores()
			
			if battleState == "select" then	
				if activePlayer == 1 then
					selectControl(coordToTile(input.mouseX), coordToTile(input.mouseY), input.mouseLeftPressed)			
				else		
					u = nextUnitToMove(activePlayer)
					selectControl(u.i,u.j,true)
				end
			elseif battleState == "navigate" then
				if activePlayer == 1 then
					navigateControl(selectedUnit, coordToTile(input.mouseX), coordToTile(input.mouseY), input.mouseLeftPressed, input.mouseRightPressed, input.action1)
				else			
					selectedTarget = nil
					move,m,n,selectedTarget = aiMoveTarget(selectedUnit)				
					navigateControl(selectedUnit, m, n, move, false, not move)
				end
			elseif battleState == "movement" then	
				moveControl(selectedUnit, dt)
			elseif battleState == "option" then
				optionControl(input.mouseLeftPressed, input.mouseRightPressed, input.scrollUp, input.scrollDown, selectedUnit, dt)
			elseif battleState == "weaponry" then
				weaponryControl(input.mouseLeftPressed, input.mouseRightPressed, input.scrollUp, input.scrollDown, selectedUnit, dt)
				lock = true
			elseif battleState == "items" then
				itemControl(input.mouseLeftPressed, input.mouseRightPressed, input.scrollUp, input.scrollDown, selectedUnit, dt)
				lock = true
			elseif battleState == "tradeSelect" then
				tradeSelect(input.mouseLeftPressed, input.mouseRightPressed, coordToTile(input.mouseX), coordToTile(input.mouseY), selectedUnit, dt)
				lock = true
			elseif battleState == "tradeAction" then
				tradeAction(input.mouseLeftPressed, input.mouseRightPressed, selectedUnit, tradeUnit, input.moveUpPressed, input.moveDownPressed, input.moveLeftPressed, input.moveRightPressed, dt)
				lock = true
			elseif battleState == "action" then
				if activePlayer == 1 then
					actionControl(coordToTile(input.mouseX), coordToTile(input.mouseY), input.mouseLeftPressed, input.mouseRightPressed)
				else
					aiActionControl(selectedUnit,selectedTarget)
				end
			end
		else
			turnStartCooldown = clamp(turnStartCooldown - dt, 0, 1000)
			lock = true
		end
	end
	
	if love.keyboard.isDown("j") then
		--unitSaveAll()
		saveMap(writePath)
	end
	
	local s = goalCheck()
	if s >= goalWinMax then
		campaignNextLevel()
	end
	
	cameraUpdate(dt, lock)
end

function masterMapDraw(dt)
	cameraTransformStack(cameraShiftI, cameraShiftJ)

	tileAnimUpdate(dt)
	drawMap()
	drawUnits()
	
	if displayCombatSummary then
		cameraReset()
		drawMapAnims(dt)
		drawSmallCombatSummary(dt)
	elseif displaySoloSummary then
		cameraReset()
		drawMapAnims(dt)
		drawSmallSoloSummary(dt)
	elseif displayExperienceBar then
		cameraReset()
		drawMapAnims(dt)
		drawExperienceBar(dt)
	elseif displayLevelUp then
		cameraReset()
		drawMapAnims(dt)
		drawLevelUpDisplay(dt)
	elseif activePlayer == 1 then
		if selectedUnit ~= -1 and battleState == "navigate" then
			drawNavGrid(selectedUnit.sumMovement)
			drawAttackGrid(selectedUnit.sumMovement)
			drawPathBack(selectedUnit.sumMovement)
		elseif selectedUnit ~= -1 and battleState == "action" then
			drawAttackGrid(-1)
		elseif selectedUnit ~= -1 and battleState == "tradeSelect" then
			drawInteractGrid(selectedUnit.i, selectedUnit.j, 1)
		end
		
		cameraReset()
		drawMapAnims(dt)	
			
		if selectedUnit ~= -1 then
			if battleState == "option" then
				local dx,dy = coordsToGUI(selectedUnit.x, selectedUnit.y)
				drawOptionSelect(dx, dy, selectedUnit)
			elseif battleState == "items" then
				local dx,dy = coordsToGUI(selectedUnit.x, selectedUnit.y)
				drawItemSelect(dx, dy, selectedUnit)
			elseif battleState == "weaponry" then
				local dx,dy = coordsToGUI(selectedUnit.x, selectedUnit.y)
				drawWeaponSelect(dx, dy, selectedUnit)				
			elseif battleState == "tradeAction" then
				drawTradeInterface(tradeCursorI, tradeCursorJ, selectedUnit, tradeUnit)
			elseif battleState == "action" then
				if targetUnit ~= -1 then
					drawCombatPrediction(selectedUnit, targetUnit)
				end
			end
		end
		
		if input.mouseRight then
			drawFullStatBox()
		else
			drawSmallStatBox()
		end
		drawTerrainInfo()
		drawGoalInfo()
	end
	
	if turnStartCooldown > 0 and not displayCombatSummary then
		cameraReset()
		drawTurnBanner(tostring(teamNames[activePlayer]) .. "'s Turn", turnStartCooldown, turnStartCooldownMax)
	end
end

function masterMapMenu(dt)
	if input.moveDownPressed then
		menuOption = menuOption + 1
		if menuOption > menuOptionMax then
			menuOption = 1
		end
	elseif input.moveUpPressed then
		menuOption = menuOption - 1
		if menuOption < 1 then
			menuOption = menuOptionMax
		end
	end	
end

function masterMapMenuDraw()
	
end

--- EDITOR CONTROL ---

function masterEditorInit()
	masterCampaignInit()
	masterMapInit()
end

function masterEditorUpdate(dt)
	changeEditorLayer(input.scrollUp, input.scrollDown)

	if editorLayer == 1 then
		editorDataUpdate()
	elseif editorLayer == 2 then
		editorTileUpdate(input.mouseLeft, input.mouseRight)
	elseif editorLayer == 3 then
		editorDetailUpdate(input.mouseLeft, input.mouseRight)
	end
	
	local lock = false
	if editorLayer == 1 and editorSelect then
		lock = true
	end
	cameraUpdate(dt, lock, 4)
end

function masterEditorDraw()
	cameraTransformStack(cameraShiftI, cameraShiftJ)
	drawMap()
	
	cameraReset()
	drawEditorGUI(editorLayer)
end

--- MENU CONTROL ---

function masterMenuInit()
	menuSelector = 1
	menuOptions = {"New Campaign", "Continue", "Editor", "Quit"}
	menuCount = #menuOptions
	
	saveSelector = 1
	
end

function masterMenuUpdate(dt)
	if input.moveDownPressed then
		menuSelector = menuSelector + 1
		if menuSelector > menuCount then
			menuSelector = 1
		end
	elseif input.moveUpPressed then
		menuSelector = menuSelector - 1
		if menuSelector < 1 then
			menuSelector = menuCount
		end
	end
	
	if input.moveRightPressed then
		saveSelector = saveSelector + 1
		if saveSelector > saveCount then
			saveSelector = 1
		end
	elseif input.moveLeftPressed then
		saveSelector = saveSelector - 1
		if saveSelector < 1 then
			saveSelector = saveCount
		end
	end
	
	if input.action1Pressed then
		if menuSelector == 4 then
			love.event.quit()
		elseif menuSelector == 1 then
			ROOMCONTROL = 1
			masterCampaignInit()
			masterMapInit()
		elseif menuSelector == 2 then
			masterCampaignInit()
			masterMapInit()
			ROOMCONTROL = 1
		elseif menuSelector == 3 then
			masterEditorInit()
			ROOMCONTROL = 2
		end
	end
end

function masterMenuDraw()
	love.graphics.setColor(0,80,128)
	love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)
	
	love.graphics.setColor(255,255,255)
	love.graphics.printf("T R P G", 200, 300, 600/5, "center", 0, 5, 5)
	for i,s in ipairs(menuOptions) do
		love.graphics.setColor(192,192,192)
		scale = 2
		if menuSelector == i then
			love.graphics.setColor(255,255,255)
			scale = 2.5
		end
		love.graphics.printf(s, 300, 500 + i * 50, 400/scale, "center", 0, scale, scale)
	end
	
	love.graphics.setColor(255,255,255)
end