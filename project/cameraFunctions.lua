function initCamera()
	cameraShiftI = 0
	cameraShiftJ = 0
	
	cameraCooldown = 0
	cameraCooldownMax = 1
	cameraSpeed = 2
	cameraEdge = SCALE
	
	cameraMinI = 0
	cameraMaxI = 0
	cameraMinJ = 0
	cameraMaxJ = 0
	
	initCameraBounds()
end

function initCameraBounds()
	if MAPWIDTH > TRUEWIDTH / tileW then
		cameraMaxI = MAPWIDTH - TRUEWIDTH / tileW
	elseif MAPWIDTH < TRUEWIDTH / tileW then
		cameraMinI = (MAPWIDTH - TRUEWIDTH / tileW) / 2
		cameraMaxI = (MAPWIDTH - TRUEWIDTH / tileW) / 2
	end
	
	if MAPHEIGHT > TRUEHEIGHT / tileH then
		cameraMaxJ = MAPHEIGHT - TRUEHEIGHT / tileH
	elseif MAPHEIGHT < TRUEHEIGHT / tileH then
		cameraMinJ = (MAPHEIGHT - TRUEHEIGHT / tileH) / 2
		cameraMaxJ = (MAPHEIGHT - TRUEHEIGHT / tileH) / 2		
	end
end

function cameraTransformStack(i,j)
	love.graphics.translate(-i*SCALE*tileW, -j*SCALE*tileH)
	love.graphics.scale(SCALE)
end

function cameraReset()
	love.graphics.origin()
end

function cameraUpdate(dt, lock, gui)
	if gui == nil then
		gui = 0
	end

	if not lock then
		if input.moveLeftPressed then
			cameraShiftI = cameraShiftI - 1
		elseif input.moveRightPressed then
			cameraShiftI = cameraShiftI + 1
		end
		
		if input.moveUpPressed then
			cameraShiftJ = cameraShiftJ - 1
		elseif input.moveDownPressed then
			cameraShiftJ = cameraShiftJ + 1
		end

		if cameraCooldown <= 0 then
			if input.rawMouseX < cameraEdge*tileW then
				cameraShiftI = cameraShiftI - 1
				cameraCooldown = cameraCooldownMax
			elseif input.rawMouseX > WINDOWWIDTH - (cameraEdge + gui*SCALE) *tileW then
				cameraShiftI = cameraShiftI + 1
				cameraCooldown = cameraCooldownMax
			end
			
			if input.rawMouseY < cameraEdge*tileW then
				cameraShiftJ = cameraShiftJ - 1
				cameraCooldown = cameraCooldownMax
			elseif input.rawMouseY > WINDOWHEIGHT - cameraEdge*tileH then
				cameraShiftJ = cameraShiftJ + 1
				cameraCooldown = cameraCooldownMax
			end
		else
			cameraCooldown = cameraCooldown - cameraSpeed * dt
		end
	end
		
	cameraShiftI = clamp(cameraShiftI, cameraMinI, cameraMaxI + gui)
	cameraShiftJ = clamp(cameraShiftJ, cameraMinJ, cameraMaxJ)
end