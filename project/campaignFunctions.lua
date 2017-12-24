function initCampaign()
	campaignMapList = {}
	
	campaignName = ""
	campaignLore = ""
	campaignDifficulty = 1
	campaignLength = 1
	
	campaignLoadPath = nil
	campaignSavePath = nil
end

function campaignNextLevel()
	campaignLevel = campaignLevel + 1
	
	initUnits()
	initGoals()
	
	masterMapInit()
end

function loadCampaignFile(path)
	if not love.filesystem.exists(path) then
		return false
	else
		local campaignStrings = {}
		local line
		for line in love.filesystem.lines(path) do
			table.insert(campaignStrings, line)
		end
		
		for _,s in ipairs(campaignStrings) do
			if s:sub(1,4) == "NAME" then
				campaignName = s:sub(6)
			elseif s:sub(1,4) == "LORE" then
				campaignLore = s:sub(6)
			elseif s:sub(1,4) == "DIFF" then
				campaignDiff = tonumber(s:sub(6))
			elseif s:sub(1,6) == "LENGTH" then
				campaignLength = tonumber(s:sub(8))
			elseif s:sub(1,3) == "MAP" then
				table.insert(campaignMapList, s:sub(5))
			end
		end
		
		if campaignName ~= "" then
			campaignSavePath = writePath .. campaignName .. "/"
			campaignSavePath = campaignSavePath:gsub(" ","_")
			if not love.filesystem.isDirectory(campaignSavePath) then
				love.filesystem.createDirectory(campaignSavePath)
			end
			
			campaignLoadPath = readPath .. campaignName .. "/"
			campaignLoadPath = campaignLoadPath:gsub(" ","_")
		end
	end
end
