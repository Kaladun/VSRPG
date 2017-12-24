Goal = {
	goalType = "",	--Rout, Kill, Save, Capture, Defend, Survive
	goalU = nil,
	goalI = nil,
	goalJ = nil,
}

function Goal:newGoal(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
--table.insert(goalList, o)
	return o
end	

function initGoals()
	goalList = {}
	
	goalWinMax = 0
end

function goalCheck()
	local success = 0
	for _,g in ipairs(goalList) do
		if g.goalType == "ROUT" then
			if countTeamSize(2) <= 0 then
				success = 1
			end
		elseif g.goalType == "KILL" then
			if unitList[g.goalU] ~= nil then
				if unitList[g.goalU].health <= 0 then
					success = 1
				end
			end
		elseif g.goalType == "SAVE" then
			if unitList[g.goalU] ~= nil then
				if unitList[g.goalU].health <= 0 then
					success = -1
					break
				end
			end
		end
		
		if success < 0 then
			break
		end
	end
	
	return success
end

function drawGoalInfo()
	x = 12
	y = WINDOWHEIGHT - 12 - 24 * (#goalList)
	for _,g in ipairs(goalList) do
		local gt = g.goalType
		if gt == "ROUT" then
			love.graphics.print("Defeat all the enemies!", x, y)
		elseif gt == "KILL" then
			love.graphics.print("Kill " .. tostring(unitList[g.goalU].name), x, y)
		elseif gt == "SURVIVE" then
			love.graphics.print("Survive for " .. tostring(g.goalN) .. " turns", x, y)
		elseif gt == "CAPTURE" then
			love.graphics.print("Capture the whatever", x, y)
		elseif gt == "SAVE" then
			love.graphics.print(tostring(unitList[g.goalU].name) .. " must survive!", x, y)
		elseif gt == "LIMIT" then
			love.graphics.print("Complete within " .. tostring(g.goalN) .. " turns", x, y)
		elseif gt == "DEFEND" then
			love.graphics.print("Defend the whatever", x, y)
		end
		y = y + 24
	end
end