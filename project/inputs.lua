function initInputArray()
	activeInputText = false
	inputText = ""
	
	input = {
		action1 = false,
		action2 = false,
		actionQ = false,
		actionE = false,
		escape = false,	
		
		moveLeft = false,
		moveRight = false,
		moveUp = false,
		moveDown = false,

		mouseLeft = false,
		mouseRight = false,	
		
		
		action1Pressed = false,
		action2Pressed = false,
		actionQPressed = false,
		actionEPressed = false,
		escapePressed = false,
		
		moveDownPressed = false,
		moveUpPressed = false,
		moveLeftPressed = false,
		moveRightPressed = false,
		
		mouseLeftPressed = false,
		mouseRightPressed = false,
			
			
		oldAction1 = false,
		oldAction2 = false,	
		oldActionQ = false,
		oldActionE = false,
		oldEscape = false,
		
		oldMoveDown = false,
		oldMoveUp = false,
		oldMoveLeft = false,
		oldMoveRight = false,
		
		oldMouseLeft = false,
		oldMouseRight = false,
		
		scrollUp = false,
		scrollDown = false,
		scrollCool = 0,
		
		mouseX = 0,
		mouseY = 0,	
	}	
end

function love.textinput(t)
	inputText = inputText .. t
end

function clearTextInput()
	inputText = ''
end

function love.keypressed(key)
	if key == 'backspace' then
		inputText = inputText:sub(1,-2)
	end
	
	
-- SPECIAL INPUTS
	if key == 'space' then
		input.action1 = true
	elseif key == 'return' then
		input.action2 = true
	elseif key == 'q' then
		input.actionQ = true
	elseif key == 'e' then
		input.actionE = true
	elseif key == 'd' then
		input.moveRight = true
	elseif key == 'a' then
		input.moveLeft = true
	elseif key == 'w' then
		input.moveUp = true
	elseif key == 's' then
		input.moveDown = true
	elseif key == 'escape' then
		input.escape = true
	end
end
function love.keyreleased(key)
	if key == 'space' then
		input.action1 = false
	elseif key == 'return' then
		input.action2 = false
	elseif key == 'q' then
		input.actionQ = false
	elseif key == 'e' then
		input.actionE = false
	elseif key == 'd' then
		input.moveRight = false
	elseif key == 'a' then
		input.moveLeft = false
	elseif key == 'w' then
		input.moveUp = false
	elseif key == 's' then
		input.moveDown = false
	elseif key == 'escape' then
		input.escape = false
	end
end


function love.mousepressed(x,y,button,isTouch)
	if button == 1 then
		input.mouseLeft = true
	elseif button == 2 then
		input.mouseRight = true
	elseif button == 3 then
		input.mouseMiddle = true
	end
end
function love.mousereleased(x,y,button,isTouch)
	if button == 1 then
		input.mouseLeft = false
	elseif button == 2 then
		input.mouseRight = false
	elseif button == 3 then
		input.mouseMiddle = false
	end
end
function love.wheelmoved(x,y)
	if y > 0 and input.scrollCool <= 0 then	
		input.scrollUp = true
		input.scrollCool = 0.1
	elseif y < 0 and input.scrollCool <= 0 then
		input.scrollDown = true
		input.scrollCool = 0.1
	end
end



function inputManager(dt)

-- TRIGGER ALL PRESSED INPUTS --
	if not input.oldAction1 and input.action1 then
		input.action1Pressed = true
	else
		input.action1Pressed = false
	end
	
	if not input.oldAction2 and input.action2 then
		input.action2Pressed = true
	else
		input.action2Pressed = false
	end	

	if not input.oldActionQ and input.actionQ then
		input.actionQPressed = true
	else
		input.actionQPressed = false
	end	
	
	if not input.oldActionE and input.actionE then
		input.actionEPressed = true
	else
		input.actionEPressed = false
	end		
	
	if not input.oldEscape and input.escape then
		input.escapePressed = true
	else
		input.escapePressed = false
	end
	
	if not input.oldMoveUp and input.moveUp then
		input.moveUpPressed = true
	else
		input.moveUpPressed = false
	end
	
	if not input.oldMoveDown and input.moveDown then
		input.moveDownPressed = true
	else
		input.moveDownPressed = false
	end
	
	if not input.oldMoveLeft and input.moveLeft then
		input.moveLeftPressed = true
	else
		input.moveLeftPressed = false
	end

	if not input.oldMoveRight and input.moveRight then
		input.moveRightPressed = true
	else
		input.moveRightPressed = false
	end	
	
	if not input.oldMouseLeft and input.mouseLeft then
		input.mouseLeftPressed = true
	else
		input.mouseLeftPressed = false
	end
	
	if not input.oldMouseRight and input.mouseRight then
		input.mouseRightPressed = true
	else
		input.mouseRightPressed = false
	end

-- SET OLD VALUES --	
	input.oldAction1 = input.action1
	input.oldAction2 = input.action2
	input.oldActionQ = input.actionQ
	input.oldActionE = input.actionE
	input.oldEscape = input.escaoe
	
	input.oldMoveUp = input.moveUp
	input.oldMoveDown = input.moveDown
	input.oldMoveLeft = input.moveLeft
	input.oldMoveRight = input.moveRight
	
	input.oldMouseLeft = input.mouseLeft
	input.oldMouseRight = input.mouseRight

-- UPDATE IN-GAME MOUSE COORDINATES --	
	input.rawMouseX = love.mouse.getX()
	input.rawMouseY = love.mouse.getY()
	if cameraShiftI ~= nil and cameraShiftJ ~= nil then
		input.mouseX = clamp(love.mouse.getX(), 0, WINDOWWIDTH) + cameraShiftI * tileW * SCALE
		input.mouseY = clamp(love.mouse.getY(), 0, WINDOWHEIGHT) + cameraShiftJ * tileH * SCALE
	else
		input.mouseX = clamp(love.mouse.getX(), 0, 0)
		input.mouseY = clamp(love.mouse.getY(), 0, 0)
	end
	
	if input.scrollCool > 0 then
		input.scrollCool = input.scrollCool - dt
	end
end

function inputManagerClear(dt)
	input.scrollUp = false
	input.scrollDown = false
end