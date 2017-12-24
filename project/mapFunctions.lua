Tile = {
	subCount = 1,
	name = "",
	path = "tileNull.png",
	cost = 1,
	
	def = 0,
	eva = 0,	
	acc = 0,
	tags = {},
	
	heal = 0,
	
	frames = 1,
	xCount = 1,
}

function loadMapTiles(tileIndex, tilesetPath)
	tileset[tileIndex] = love.graphics.newImage(tilesetPath)
	local tilesetW, tilesetH = tileset[tileIndex]:getWidth(), tileset[tileIndex]:getHeight()
	
	tileXCount = tilesetW / tileW	
	tileYCount = tilesetH / tileH
	tileQuads[tileIndex] = {}
	
	local i,m,n
	m = 1
	n = 1
	for i = 1, tileXCount * tileYCount do
		tileQuads[tileIndex][i] = love.graphics.newQuad((m-1)*tileW, (n-1)*tileH, tileW, tileH, tilesetW, tilesetH)
		m = m + 1
		if m > tileXCount then
			m = 1
			n = n + 1
		end
	end
	
	return tileXCount * tileYCount, tileXCount
end
	
function initMap(a,b)
	tileList = {}
	tileset = {}
	tileQuads = {}
	
	tileTable = {}
	secondaryTable = {}
	unitTable = {}
	
	for i = 1,a do
		tileTable[i] = {}
		secondaryTable[i] = {}
		unitTable[i] = {}
		for j = 1,b do
			tileTable[i][j] = 1
			secondaryTable[i][j] = 1
			unitTable[i][j] = 0
		end
	end
	
	tileFrameCounter = 0
	tileFrame = 0
end

function tileAnimUpdate(dt)
	tileFrameCounter = tileFrameCounter + 2 * dt
	
	if tileFrameCounter >= 24 then
		tileFrameCounter = tileFrameCounter - 24
	end
	
	tileFrame = math.floor(tileFrameCounter)
end

function Tile:newTile(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	o.tags = {}
	return o
end

function drawMap()
	for m = 1,MAPWIDTH do
		for n = 1,MAPHEIGHT do
			local x,y = (m-1)*tileW, (n-1)*tileH			
			local a,b = tileTable[m][n], secondaryTable[m][n]
			
			fm = (tileFrame % tileList[a].frames) * (tileList[a].xCount / tileList[a].frames)		
			b = b + fm
			if b > tileList[a].subCount then
				b = b - tileList[a].subCount
			end
			b = clamp(b, 1, tileList[a].subCount)
			
			love.graphics.draw(tileset[0], tileQuads[0][1], x, y)
			love.graphics.draw(tileset[a], tileQuads[a][b], x, y)
			--love.graphics.print(b, x, y, 0, 0.25, 0.25)
		end
	end	
end

--- TILE FUNCTIONS ---

function Tile:setTileCost(n)
	self.cost = n
end

function Tile:setTileDefense(n)
	self.def = n
end

function Tile:setTileEvade(n)
	self.eva = n
end

function Tile:setTileName(n)
	self.name = n
end

function Tile:setTileHeal(n)
	self.heal = n
end

function getTileCost(i,j)
	local n = tileTable[i][j]
	local t = tileList[n]
	return t.cost
end

function getTileDefense(i,j)
	local n = tileTable[i][j]
	local t = tileList[n]
	return t.def
end

function getTileEvade(i,j)
	local n = tileTable[i][j]
	local t = tileList[n]
	return t.eva
end

function getTileName(i,j)
	local n = tileTable[i][j]
	local t = tileList[n]
	return t.name
end

function getTileHeal(i,j)
	local n = tileTable[i][j]
	local t = tileList[n]
	return t.heal
end

function getTileTags(i,j)
	local n = tileTable[i][j]
	local t = tileList[n]
	return t.tags
end

--- GENERIC UTILITIES ---

function isInMap(x,y)
	if x >= 1 and x <= MAPWIDTH and y >= 1 and y <= MAPHEIGHT then
		return true
	end
	return false
end

function coordToTile(x)
	return math.floor(x / (tileW * SCALE)) + 1 
end

function coordsToGUI(x,y)
	return SCALE * (x - cameraShiftI * tileW), SCALE * (y - cameraShiftJ * tileH)
end

function tileToCoord(x)
	return x * tileW - tileW / 2
end

function tileToIndex(x,y)
	return x + y * (MAPWIDTH + 1)
end

function indexToTileI(x)
	return x % (MAPWIDTH + 1)
end

function indexToTileJ(x)
	return math.floor(x / (MAPWIDTH + 1))
end

function tileDistance(a,b,c,d)
	return math.abs(a-c) + math.abs(b-d)
end	