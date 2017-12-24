require 'listUtil'


--[[ FUNCTION POPUPS ]] --


function initMapAnims()
	unitFlashing = nil
	flashTimer = 0
	flashSpeed = 0.3

	popupList = {}
end

function controlMapAnims(dt)
	local animPlaying = false	
	
	if unitFlashing ~= nil then
		animPlaying = true
		flashTimer = flashTimer - 1/flashSpeed * dt
		if flashTimer <= 0 then
			flashTimer = 0
			unitFlashing = nil
		end
	end
	
	for i,p in pairs(popupList) do
		animPlaying = true
		p[4] = p[4] + dt
		if p[4] > 1 then
			popupList[i] = nil
		end
	end
end

function callPopup(n, x, y, t, c)
	i,j = coordsToGUI(x,y)

	if c ~= nil then
		love.graphics.setColor(c[0],c[1],c[2])
	end
	
	if n == nil then
		table.insert(popupList, {t, i, j, 0}) --x - SCALE * unitW / 2,y,0})
	else
		table.insert(popupList, {tostring(n), i, j, 0}) --x - SCALE * unitW / 2,y,0})
	end
	
	love.graphics.setColor(255,255,255,255)
end

function drawMapAnims(dt)
	local f = love.graphics.getFont()
	love.graphics.setFont(largeFont)
	
	for i,p in pairs(popupList) do
		r = math.sqrt(clamp(p[4], 0, 1))
		love.graphics.printf(p[1], p[2], p[3] - 2*tileH * r, SCALE * unitW, "center")
	end
	
	love.graphics.setFont(f)
end
	
	
--[[ COMBAT DISPLAYS ]]--	
	
	
function initCombatSummary()
	displayCombatSummary = false
	displaySoloSummary = false
	
	summaryTimer = 0	
	summarySpeed = 0.05
	summaryExtra = 0.5
	
	summaryQueue = Queue
	summaryQueue = Queue.new(summaryQueue)
	
	currentSummary = nil
	summaryLeftUnit = nil
	summaryRightUnit = nil
end

function callCombatSummary(lUnit, rUnit)
	summaryLeftUnit = lUnit
	summaryRightUnit = rUnit
	
	summaryLeftHP = lUnit.health
	summaryRightHP = rUnit.health
	
	summaryLeftHPMax = lUnit.health
	summaryRightHPMax = rUnit.health
end

function queueCombatSummary(hitL, damage, special)
	local l = {}
	
	l.hitL = hitL
	l.damage = damage
	l.special = special
	
	Queue.push(summaryQueue, l)
	
	displayCombatSummary = true	
end

function callSoloSummary(unit, n, special)
	summarySoloUnit = unit
	summarySoloHealth = unit.health
	summarySoloChange = n
	summarySoloSpecial = special
	
	displaySoloSummary = true
	
	
	summaryTimerMax = 2 * summaryExtra + summarySpeed * math.abs(summarySoloChange)
		
	if summarySoloSpecial ~= "" then
		summaryTimerMax = summaryTimerMax + summaryExtra
	end
		
	summaryTimer = summaryTimerMax
end
	
function drawSmallCombatSummary(dt)
	if currentSummary == nil and Queue.length(summaryQueue) > 0 then
		currentSummary = Queue.pop(summaryQueue)
		summaryTimerMax = summaryExtra + summarySpeed * currentSummary.damage
		
		if currentSummary.special ~= "" then
			summaryTimerMax = summaryTimerMax + summaryExtra
		end
		
		summaryTimer = summaryTimerMax
	end

	if currentSummary ~= nil then
		love.graphics.setColor(0,0,0,64)
		love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)
		local x = WINDOWWIDTH / 2
		local y = WINDOWHEIGHT / 2 - 24
		local tx = 180
		
		local c = teamColors[summaryLeftUnit.team]
		love.graphics.setColor(c[1],c[2],c[3],255)
		love.graphics.rectangle("fill", x - tx - 12, y, tx, 48, 8, 4)
			
		c = teamColors[summaryRightUnit.team]
		love.graphics.setColor(c[1],c[2],c[3],255)
		love.graphics.rectangle("fill", x + 12, y, tx, 48, 8, 4)
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(" " .. summaryLeftUnit.name, x - tx - 12, y, tx, "left")
		love.graphics.printf(" " .. summaryRightUnit.name, x + 12, y, tx, "left")
		
		local t = clamp((summaryTimerMax - summaryTimer) / (summaryTimerMax - summaryExtra), 0, 1)
		
		if currentSummary.hitL then
			summaryLeftHP = clamp(summaryLeftHPMax - lerp(0, currentSummary.damage, t), 0, 99)
		
			drawHealthBar(x - tx/2 - 12, y, summaryLeftHP, summaryLeftUnit.healthMax)
			drawHealthBar(x + tx/2 + 12, y, summaryRightHP, summaryRightUnit.healthMax)
			
			if currentSummary.special ~= "" then
				love.graphics.printf(currentSummary.special, x - tx - 12, y + 24, tx, "center")
			end	
		else
			summaryRightHP = clamp(summaryRightHPMax - lerp(0, currentSummary.damage, t), 0, 99)
		
			drawHealthBar(x - tx/2 - 12, y, summaryLeftHP, summaryLeftUnit.healthMax)
			drawHealthBar(x + tx/2 + 12, y, summaryRightHP, summaryRightUnit.healthMax)	
			
			if currentSummary.special ~= "" then
				love.graphics.printf(currentSummary.special, x + 12, y + 24, tx, "center")
			end	
		end
		
		love.graphics.printf(tostring(round(summaryLeftHP)) .. "/" .. tostring(summaryLeftUnit.healthMax) .. " ", x - tx - 12, y, tx, "right")
		love.graphics.printf(tostring(round(summaryRightHP)) .. "/" .. tostring(summaryRightUnit.healthMax) .. " ", x + 12, y, tx, "right")
		
		summaryTimer = summaryTimer - dt
		if summaryTimer <= 0 then
			currentSummary = nil
		end
	end	
	
	if currentSummary == nil and Queue.length(summaryQueue) <= 0 then
		displayCombatSummary = false
		
		summaryLeftUnit = nil
		summaryRightUnit = nil
	end
end

function drawSmallSoloSummary(dt)
	if summaryTimer > 0 then
		love.graphics.setColor(0,0,0,64)
		love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)
		local x = WINDOWWIDTH / 2
		local y = WINDOWHEIGHT / 2 - 24
		local tx = 180
		
		local c = teamColors[summarySoloUnit.team]
		love.graphics.setColor(c[1],c[2],c[3],255)
		love.graphics.rectangle("fill", x - tx/2, y, tx, 48, 8, 4)
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(" " .. summarySoloUnit.name, x - tx/2 - 6, y, tx, "left")
		
		local t = clamp((summaryTimerMax - summaryTimer) / (summaryTimerMax - summaryExtra), 0, 1)
		local summarySoloHP = clamp(summarySoloHealth + lerp(0, summarySoloChange, t), 0, summarySoloUnit.healthMax)		
		
		drawHealthBar(x, y, summarySoloHP, summarySoloUnit.healthMax)
			
		if summarySoloSpecial ~= "" then
			love.graphics.printf(summarySoloSpecial, x + 12, y + 24, tx, "center")
		end	
		
		love.graphics.printf(tostring(round(summarySoloHP)) .. "/" .. tostring(summarySoloUnit.healthMax) .. " ", x - tx/2, y, tx, "right")
		
		summaryTimer = summaryTimer - dt
	else
		displaySoloSummary = false		
		summarySoloUnit = nil
	end
end

function drawHealthBar(x,y,hp,hpmax)
	love.graphics.setColor(0,0,0,192)
	love.graphics.rectangle("fill", x - 3*hpmax - 2, y + 26, 6*hpmax + 4, 20)
	
	if hp > 0 then	
		love.graphics.setColor(0,192,0,255)
		for i = 0,hp-1 do
			love.graphics.rectangle("fill", x - 3*hpmax + 6*i, y + 28, 5, 16)
		end
	end
	
	love.graphics.setColor(255,255,255,255)
end


--[[ XP Gain ]]--

function initExperienceBar()
	displayExperienceBar = false
	
	experienceTimer = 0	
	experienceSpeed = 0.01
	experienceExtra = 0.5
end

function callExperienceBar(unit, n)
	experienceBarUnit = unit
	experienceBarXP = unit.experience
	experienceBarChange = n
	
	displayExperienceBar = true
	summaryLevelUp = false
		
	experienceTimerMax = 2 * experienceExtra + experienceSpeed * math.abs(experienceBarChange)
	experienceTimer = experienceTimerMax
end

function drawExperienceBar(dt)
	if experienceTimer > 0 then
		love.graphics.setColor(0,0,0,64)
		love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)
		local x = WINDOWWIDTH / 2
		local y = WINDOWHEIGHT / 2 - 24
		local tx = 180
		
		local c = teamColors[experienceBarUnit.team]
		love.graphics.setColor(c[1],c[2],c[3],255)
		love.graphics.rectangle("fill", x - tx/2, y, tx, 48, 8, 4)
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(" " .. experienceBarUnit.name, x - tx/2 - 6, y, tx, "left")
		
		local t = clamp((experienceTimerMax - experienceTimer) / (experienceTimerMax - summaryExtra), 0, 1)
		
		local summaryXP = experienceBarXP + lerp(0, experienceBarChange, t)		
		
		if summaryXP >= 100 then
			summaryXP = summaryXP % 100
			summaryLevelUp = true
		end		
		
		love.graphics.setColor(0,0,0,192)
		love.graphics.rectangle("fill", x - 80 - 2, y + 26, 160 + 4, 20)
		
		love.graphics.setColor(255, 215, 0, 255)
		love.graphics.rectangle("fill", x - 80, y + 28, round(160 * summaryXP / 100), 16)
		love.graphics.setColor(255,255,255,255)
		
		love.graphics.printf(tostring(round(summaryXP)) .. "/ 100 ", x - tx/2, y, tx, "right")
		
		experienceTimer = experienceTimer - dt
	else
		displayExperienceBar = false		
		
		if summaryLevelUp then
			callLevelUpDisplay(experienceBarUnit)
		end
		
		experienceBarUnit = nil
	end
end


--[[ LEVEL  UP ]]--

function initLevelUpDisplay()
	displayLevelUp = false
	
	levelUpTimer = 0	
	levelUpExtraTime = 0.5
	levelUpBonusTime = 0.5
	
	levelUpAbilityTags = {"Health", "Strength", "Defense", "Skill", "Speed"}
end

function callLevelUpDisplay(unit)
	levelUpUnit = unit
	levelUpBase = {unit.healthMax, unit.strength, unit.defense, unit.skill, unit.speed}
	levelUpBonus = unit:levelUp()
	
	displayLevelUp = true
		
	local n = 0
	for _,v in ipairs(levelUpBonus) do
		if v > 0 then
			n = n + 1
		end
	end
		
	levelUpBonusCount = n	
	levelUpTimerMax = 2 * levelUpExtraTime + levelUpBonusTime * n
	levelUpTimer = levelUpTimerMax
end

function drawLevelUpDisplay(dt)
	if levelUpTimer > 0 then
		love.graphics.setColor(0,0,0,64)
		love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)
		local x = WINDOWWIDTH / 2
		local y = WINDOWHEIGHT / 2 - 24
		local tx = 200
		
		local c = teamColors[levelUpUnit.team]
		love.graphics.setColor(c[1],c[2],c[3],255)
		love.graphics.rectangle("fill", x - tx/2, y, tx, 24*7, 8, 4)
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(" " .. levelUpUnit.name, x - tx/2 - 6, y, tx, "left")
		
		local t = (levelUpTimerMax - levelUpTimer - levelUpExtraTime) / (levelUpBonusTime)
		
		love.graphics.line(x-tx/2+4,y+36,x+tx/2-4,y+36)
		
		local dy = 48
		local n = 0
		
		for i = 1,#levelUpBonus do
			if levelUpBonus[i] > 0 and t >= n then
				n = n + 1
				love.graphics.setColor(255,215,0,255)
				love.graphics.printf("  " .. levelUpAbilityTags[i] .. " " .. tostring(levelUpBase[i]) .. "+" .. tostring(levelUpBonus[i]), x - tx/2 - 6, y + dy, tx, "left")
			else
				love.graphics.setColor(255,255,255,255)
				love.graphics.printf("  " .. levelUpAbilityTags[i] .. " " .. tostring(levelUpBase[i]), x - tx/2 - 6, y + dy, tx, "left")
			end
			dy = dy + 24
		end

		love.graphics.setColor(255,255,255,255)
		love.graphics.printf("Level " .. tostring(levelUpUnit.level) .. "!", x - tx/2, y, tx, "right")
		
		levelUpTimer = levelUpTimer - dt
	else
		displayLevelUp = false
	end
end