function initEditor()
	editorLayer = 1
	editorLayerName = {"Data", "Tile", "Secondary"}
	editorLayerMod = #editorLayerName
	editorI = 1
	editorJ = 1
	
	editorData = 1
	editorDataMax = 4
	editorSelect = false
	editorPrimary = 0
	editorSecondary = 1
	
	mapFile = 'map0'
end

function changeEditorLayer(layerUp, layerDown)
	if layerUp then
		editorLayer = editorLayer + 1
		if editorLayer > editorLayerMod then
			editorLayer = 1
		end
		editorSelect = false
	elseif layerDown then
		editorLayer = editorLayer - 1
		if editorLayer < 1 then
			editorLayer = editorLayerMod
		end
		editorSelect = false
	end
end


function editorDataUpdate()
	if input.moveUpPressed and not editorSelect then
		editorData = editorData - 1
		if editorData < 1 then
			editorData = editorDataMax
		end
	elseif input.moveDownPressed and not editorSelect then
		editorData = editorData + 1
		if editorData > editorDataMax then
			editorData = 1
		end
	end
	
	if input.action2Pressed then	
		if editorSelect then
			editorSelect = false
		else
			editorSelect = true
			if editorData == 1 then
				clearTextInput()
			elseif editorData == 4 then
				saveMap(mapFile .. ".txt")
			end
		end
	end
	
	if editorSelect and editorData == 1 then
		mapFile = inputText
	elseif editorSelect and editorData == 2 then
		if input.moveLeftPressed then
			MAPWIDTH = MAPWIDTH - 1
		elseif input.moveRightPressed then
			MAPWIDTH = MAPWIDTH + 1
		end
		
		MAPWIDTH = clamp(MAPWIDTH, 4, 99)
		initCameraBounds()
	elseif editorSelect and editorData == 3 then
		if input.moveLeftPressed then
			MAPHEIGHT = MAPHEIGHT - 1
		elseif input.moveRightPressed then
			MAPHEIGHT = MAPHEIGHT + 1
		end
		
		MAPHEIGHT = clamp(MAPHEIGHT, 4, 99)	
		initCameraBounds()
	end
end

function editorTileUpdate(leftClick, rightClick)
	local i,j = coordToTile(input.mouseX), coordToTile(input.mouseY)
	if isInMap(i,j) then
		if leftClick then
			tileTable[i][j] = editorPrimary
		elseif rightClick then
			tileTable[i][j] = 0
		end
	end
	
	if input.actionQPressed or input.actionEPressed then
		local kList,kCount,kIndex = {}, 0, 1
		for i,_ in pairs(tileList) do
			table.insert(kList, i)
			kCount = kCount + 1
			if i == editorPrimary then
				kIndex = kCount
			end
		end
		
		if input.actionQPressed and kIndex > 1 then
			editorPrimary = kList[kIndex - 1]
		elseif input.actionEPressed and kIndex < #kList then
			editorPrimary = kList[kIndex + 1]
		end
	end
end

function editorDetailUpdate(leftClick, rightClick)
	editorSecondary = clamp(editorSecondary, 1, tileList[editorPrimary].subCount)

	local i,j = coordToTile(input.mouseX), coordToTile(input.mouseY)
	if isInMap(i,j) and tileTable[i][j] == editorPrimary then
		if leftClick then
			secondaryTable[i][j] = editorSecondary
		elseif rightClick then
			secondaryTable[i][j] = 1
		end
	end
	
	if input.actionEPressed and editorSecondary < tileList[editorPrimary].subCount then	
		editorSecondary = editorSecondary + 1
	elseif input.actionQPressed and editorSecondary > 1 then	
		editorSecondary = editorSecondary - 1
	end
end

function drawEditorGUI(layer)
--	love.graphics.print(tostring(coordToTile(input.mouseX))..","..tostring(coordToTile(input.mouseY)),50,50)
--	love.graphics.print(tostring(editorLayer),50,20)

	local ww = 4 * SCALE * tileW
	local wx = WINDOWWIDTH - ww

	love.graphics.setColor(0,160,255,255)
	love.graphics.rectangle("fill",wx,0,ww,WINDOWHEIGHT)
	love.graphics.setColor(255,255,255,255)
	
	if layer == 1 then
		local W = wx+tileW/4*SCALE
		local D = ww - 2*tileW/4*SCALE
		local H = tileH/4*SCALE
	
		love.graphics.setColor(32,32,32,255)
		love.graphics.rectangle("fill",W,H+2,D,20)
		love.graphics.rectangle("fill",W+24,H+26,48,20)
		love.graphics.rectangle("fill",W+24,H+50,48,20)
		
		love.graphics.setColor(0,128,224,255)
		love.graphics.rectangle("fill",W+D/4,H+74,D/2,20)
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(mapFile .. ".txt",W,H)
		love.graphics.print("W:",W,H+24)
		love.graphics.print(tostring(MAPWIDTH),W+24,H+24)
		love.graphics.print("H:",W,H+48)
		love.graphics.print(tostring(MAPHEIGHT),W+24,H+48)
		love.graphics.printf("Save Map",W+D/4,H+72,D/2,"center")
		
		love.graphics.rectangle("line", W-2,H+24*(editorData-1),D+2,24)
		
		if editorData == 1 and editorSelect then
			love.graphics.line(W,H+1,W,H+15)
		elseif editorData == 2 and editorSelect then
			love.graphics.line(W,H+21,W,H+35)
		elseif editorData == 3 and editorSelect then
			love.graphics.line(W,H+41,W,H+55)
		end
	elseif layer == 2 then
		local ti,tj = 0,0
		local tw,th = tileW * SCALE, tileH * SCALE
		local tp,tq = tw/4, th/4
		local a,b = 0,0
		
		for i,t in pairs(tileList) do
			love.graphics.draw(tileset[i], tileQuads[i][1], wx + tp + ti * (tw + tp), tq + tj * (th + tq), 0, SCALE, SCALE)
			if i == editorPrimary then
				love.graphics.rectangle("line", wx + tp + ti * (tw + tp) - 4, tq + tj * (th + tq) - 4, tw + 8, th + 8)
 			end
			ti = ti + 1
			if ti >= 3 then
				ti = 0
				tj = tj + 1
			end
		end
	elseif layer == 3 then
		local ti,tj = 0,0
		local tw,th = tileW * SCALE, tileH * SCALE
		local tp,tq = tw/4, th/4
		local a,b = 0,0
		
		for i = 1,tileList[editorPrimary].subCount do
			love.graphics.draw(tileset[editorPrimary], tileQuads[editorPrimary][i], wx + tp + ti * (tw + tp), tq + tj * (th + tq), 0, SCALE, SCALE)
			if i == editorSecondary then
				love.graphics.rectangle("line", wx + tp + ti * (tw + tp) - 4, tq + tj * (th + tq) - 4, tw + 8, th + 8)
 			end
			ti = ti + 1
			if ti >= 3 then
				ti = 0
				tj = tj + 1
			end
		end
	end
end