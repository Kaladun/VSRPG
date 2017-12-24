function drawInteractGrid(i,j,radius)
	love.graphics.setColor(0,255,64,96)
	for m = math.max(1,i-radius),math.min(MAPWIDTH,i+radius) do
		for n = math.max(1,j-radius),math.max(MAPWIDTH,j+radius) do
			local d = tileDistance(i,j,m,n)
			if d <= radius and d > 0 then
				local x,y = (m-1)*tileW, (n-1)*tileH
				love.graphics.rectangle("fill",x+1,y+1,tileW-2,tileH-2,2,2,3)
			end
		end
	end	
	love.graphics.setColor(255,255,255,255)
end

function startNewTrade(u, tu)
	tempInvLeft = {u.inventory[1], u.inventory[2], u.inventory[3], u.inventory[4]}
	tempItemLeft = {u.items[1], u.items[2], u.items[3], u.items[4]}
	tempCoolLeft = {u.cooldown[1], u.cooldown[2], u.cooldown[3], u.cooldown[4]}
	tempUseLeft = {u.uses[1], u.uses[2], u.uses[3], u.uses[4]}
	
	tempInvRight = {tu.inventory[1], tu.inventory[2], tu.inventory[3], tu.inventory[4]}
	tempItemRight = {tu.items[1], tu.items[2], tu.items[3], tu.items[4]}
	tempCoolRight = {tu.cooldown[1], tu.cooldown[2], tu.cooldown[3], tu.cooldown[4]}
	tempUseRight = {tu.uses[1], tu.uses[2], tu.uses[3], tu.uses[4]}

	tradeCursorI = 1
	tradeCursorJ = 1
	
	tradeLeftSelect = nil
	tradeRightSelect = nil
end

function tradeExchange(tradeLeftSelect, tradeRightSelect)
	local holdObj = ""
	local holdVal = 0
	
	if tradeLeftSelect <= 4 and tradeRightSelect <= 4 then
		holdObj = tempInvLeft[tradeLeftSelect]
		holdVal = tempCoolLeft[tradeLeftSelect]
		
		tempInvLeft[tradeLeftSelect] = tempInvRight[tradeRightSelect]
		tempCoolLeft[tradeLeftSelect] = tempCoolLeft[tradeRightSelect]
		
		tempInvRight[tradeRightSelect] = holdObj
		tempCoolRight[tradeRightSelect] = holdVal
	else
		holdObj = tempItemLeft[tradeLeftSelect - 4]
		holdVal = tempUseLeft[tradeLeftSelect - 4]
		
		tempItemLeft[tradeLeftSelect - 4] = tempItemRight[tradeRightSelect - 4]
		tempUseLeft[tradeLeftSelect - 4] = tempUseLeft[tradeRightSelect - 4]
		
		tempItemRight[tradeRightSelect - 4] = holdObj
		tempUseRight[tradeRightSelect - 4] = holdVal	
	end
end

function finishTrade(uLeft, uRight)
	if uLeft ~= nil and uRight ~= nil then
		for i = 1,inventorySize do
			uLeft.inventory[i] = tempInvLeft[i]
			uLeft.cooldown[i] = tempCoolLeft[i]
			
			uRight.inventory[i] = tempInvRight[i]
			uRight.cooldown[i] = tempCoolRight[i]		
		end
		
		for i = 1,itemSize do
			uLeft.items[i] = tempItemLeft[i]
			uLeft.uses[i] = tempUseLeft[i]
			
			uRight.items[i] = tempItemRight[i]
			uRight.uses[i] = tempUseRight[i]			
		end
	end
end

function drawTradeInterface(i, j, uLeft, uRight)
	local w,tw = 200,140	
	local x, xl, xr = WINDOWWIDTH / 2 - w / 2, WINDOWWIDTH / 2 - 200 - 6, WINDOWWIDTH / 2 + 6
	local fh = 24 * 11
	local y = WINDOWHEIGHT / 2 - fh / 2
		
	local c = teamColors[1]
	love.graphics.setColor(c[1],c[2],c[3],192)
	
	love.graphics.rectangle("fill",xl,y,w,fh,8,8,4)
	love.graphics.rectangle("fill",xr,y,w,fh,8,8,4)	
	love.graphics.rectangle("fill",x, y+fh+12, w, 24, 8,8,4)
	
	love.graphics.setColor(255,255,255,255)
	
	love.graphics.printf(uLeft.name, xl, y, w, "center")
	love.graphics.printf(uRight.name, xr, y, w, "center")
	love.graphics.printf("Confirm", x, y+fh+12, w, "center")
	
	love.graphics.line(xl+4, y+12 + 24*1, xl+w-4, y+12+ 24*1)
	love.graphics.line(xl+4, y+12 + 24*6, xl+w-4, y+12+ 24*6)
	love.graphics.line(xr+4, y+12 + 24*1, xr+w-4, y+12+ 24*1)
	love.graphics.line(xr+4, y+12 + 24*6, xr+w-4, y+12+ 24*6)	
				
	for i = 1,4 do
		if tempInvLeft[i] ~= nil then
			love.graphics.print(tempInvLeft[i], xl+8, y + 24 + 24 * i)
			love.graphics.print(tempCoolLeft[i], xl+tw, y + 24 + 24 * i)	
		end
		
		if tempInvRight[i] ~= nil then
			love.graphics.print(tempInvRight[i], xr+8, y + 24 + 24 * i)
			love.graphics.print(tempCoolRight[i], xr+tw, y + 24 + 24 * i)	
		end		
		
		if tempItemLeft[i] ~= nil then
			love.graphics.print(tempItemLeft[i], xl+8, y + 144 + 24 * i)
			love.graphics.print(tempUseLeft[i], xl+tw, y + 144 + 24 * i)	
		end
		
		if tempItemRight[i] ~= nil then
			love.graphics.print(tempItemRight[i], xr+8, y + 144 + 24 * i)
			love.graphics.print(tempUseRight[i], xr+tw, y + 144 + 24 * i)	
		end		
	end

	if tradeLeftSelect ~= nil then
		love.graphics.setColor(255,215,0,255)		
		if tradeLeftSelect <= 4 then
			love.graphics.print(tempInvLeft[tradeLeftSelect], xl+8, y + 24 + 24 * tradeLeftSelect)
			love.graphics.print(tempCoolLeft[tradeLeftSelect], xl+tw, y + 24 + 24 * tradeLeftSelect)	
		else
			love.graphics.print(tempItemLeft[tradeLeftSelect-4], xl+8, y + 48 + 24 * tradeLeftSelect)
			love.graphics.print(tempUseLeft[tradeLeftSelect-4], xl+tw, y + 48 + 24 * tradeLeftSelect)				
		end	
		love.graphics.setColor(255,255,255,255)
	end
	
	if tradeRightSelect ~= nil then
		love.graphics.setColor(255,215,0,255)		
		if tradeRightSelect <= 4 then
			love.graphics.print(tempInvRight[tradeRightSelect], xr+8, y + 24 + 24 * tradeRightSelect)
			love.graphics.print(tempCoolRight[tradeRightSelect], xr+tw, y + 24 + 24 * tradeRightSelect)	
		else
			love.graphics.print(tempItemRight[tradeRightSelect-4], xr+8, y + 48 + 24 * tradeRightSelect)
			love.graphics.print(tempUseRight[tradeRightSelect-4], xr+tw, y + 48 + 24 * tradeRightSelect)				
		end	
		love.graphics.setColor(255,255,255,255)
	end
		
	if tradeCursorJ == 9 then
		love.graphics.rectangle("line",x, y+fh+12, w, 24, 8, 8, 4)
	else
		local tj = tradeCursorJ
		if tj >= 5 then
			tj = tj + 1
		end
		love.graphics.rectangle("line",xl + 212 * (tradeCursorI - 1), y + 24 + 24 * tj, w, 24, 8, 8, 4)
	end
	
	love.graphics.setColor(255,255,255,255)
end