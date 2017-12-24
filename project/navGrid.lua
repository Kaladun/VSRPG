require 'listUtil'

function initNavGrid()
	navGrid = {}
	checkedList = {}
	for i = 1,MAPWIDTH do
		navGrid[i] = {}
		for j = 1,MAPHEIGHT do
			navGrid[i][j] = {distance = 500, parent = {-1, -1}}
			checkedList[tileToIndex(i,j)] = false
		end
	end
	
	MAXINDEX = tileToIndex(MAPWIDTH, MAPHEIGHT)
	
	neighbors = {
		{1,0},
		{0,1},
		{-1,0},
		{0,-1}
	}
end

function moveRange(i, j)
	initNavGrid()
	toCheckList = Queue
	toCheckList = Queue.new(toCheckList)	
	Queue.push(toCheckList, tileToIndex(i,j))
	
	navGrid[i][j].distance = 0
	navGrid[i][j].parent = {i,j}

	while Queue.length(toCheckList) > 0 do
		currentIndex = Queue.pop(toCheckList)
		
		local i = indexToTileI(currentIndex)
		local j = indexToTileJ(currentIndex)
		for _,n in ipairs(neighbors) do
			local newI = i + n[1]
			local newJ = j + n[2]
			if isInMap(newI, newJ) then
				local newIndex = tileToIndex(newI,newJ)
				local u = isUnitAt(newI, newJ)
		
				local d = navGrid[i][j].distance 
				local gsm = selectedUnit:getSpecialMove(newI,newJ)
				
				if gsm >= 0 then
					d = d + gsm
				else
					d = d + getTileCost(newI, newJ)
				end
				
				
				if u ~= nil then
					if u.team ~= activePlayer then
						d = d + 100
					end
				end
				
				if d < navGrid[newI][newJ].distance then  --and u == nil then
					navGrid[newI][newJ].distance = d

					navGrid[newI][newJ].parent[1] = i
					navGrid[newI][newJ].parent[2] = j
					if not checkedList.newIndex then
						Queue.push(toCheckList, tileToIndex(newI,newJ))
					end
				end
			end
		end
		
		checkedList.currentIndex = true
	end		
end

function initAttackGrid()
	attackGrid = {}
	for i = 1,MAPWIDTH do
		attackGrid[i] = {}
		for j = 1,MAPHEIGHT do
			attackGrid[i][j] = false
		end
	end	
end

function localAttackRange(i,j,rangeList)
	initAttackGrid()
	for _,r in ipairs(rangeList) do
		for k = -r,r do
			for l = -r,r do
				if isInMap(i+k, j+l) then
					if tileDistance(0,0,k,l) == r then
						attackGrid[i+k][j+l] = true
					end
				end
			end
		end
	end
end	
	
function attackRange(move, rangeList)
	initAttackGrid()
	for _,r in ipairs(rangeList) do
		for i = 1,MAPWIDTH do
			for j = 1,MAPHEIGHT do
				if navGrid[i][j].distance <= move then
					for k = -r,r do
						for l = -r,r do
							if isInMap(i+k, j+l) then
								if tileDistance(0,0,k,l) == r then
									attackGrid[i+k][j+l] = true
								end
							end
						end
					end
				end
			end
		end	
	end
end
	
function drawNavGrid(radius)
	love.graphics.setColor(0,0,255,96)
	for m = 1,MAPWIDTH do
		for n = 1,MAPHEIGHT do
			if navGrid[m][n].distance <= radius then	--and isUnitAt(m,n) == nil then
				local x,y = (m-1)*tileW, (n-1)*tileH
				love.graphics.rectangle("fill",x+1,y+1,tileW-2,tileH-2,2,2,3)
			end
		end
	end	
	love.graphics.setColor(255,255,255,255)
end

function drawAttackGrid(radius)
	love.graphics.setColor(255,0,0,96)
	for m = 1,MAPWIDTH do
		for n = 1,MAPHEIGHT do
			if attackGrid[m][n] and navGrid[m][n].distance > radius then
				local x,y = (m-1)*tileW, (n-1)*tileH
				love.graphics.rectangle("fill",x+1,y+1,tileW-2,tileH-2,2,2,3)
			end
		end
	end	
	love.graphics.setColor(255,255,255,255)
end

function drawPathBack(radius)
	w = clamp(coordToTile(input.mouseX), 1, MAPWIDTH)
	v = clamp(coordToTile(input.mouseY), 1, MAPHEIGHT)

	if navGrid[w][v].distance <= radius then
		while (navGrid[w][v].distance > 0) do
			ww = w
			vv = v
			w = navGrid[ww][vv].parent[1]
			v = navGrid[ww][vv].parent[2]
			love.graphics.line(tileToCoord(ww),tileToCoord(vv),tileToCoord(w),tileToCoord(v))
		end
	end
end

function clearRangeGrid()
	for _,u in pairs(unitList) do
		u.inRangeGrid = false
	end
end

function initRangeGrid()
	rangeGrid = {}
	for i = 1,MAPWIDTH do
		rangeGrid[i] = {}
		for j = 1,MAPHEIGHT do
			rangeGrid[i][j] = false
		end
	end	
end