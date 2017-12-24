require "masterFunctions"
require "campaignFunctions"
require "mapFunctions"
require "mapAnimation"
require "ioFunctions"

require "classFunctions"
require "itemFunctions"
require "magicFunctions"
require "tradeFunctions"
require "unitFunctions"
require "goalFunctions"
require "battleFunctions"
require "guiFunctions"
require "aiFunctions"
require "shaderFunctions"
require "editorFunctions"
require "cameraFunctions"
require "navGrid"

require "math2"
require "inputs"
require "listUtil"


function love.load()
	math.randomseed(os.time())
	mainFont = love.graphics.newFont("assets/kenpixel_square.ttf",16)
	largeFont = love.graphics.newFont("assets/kenpixel_square.ttf",16*2)
	megaFont = love.graphics.newFont("assets/kenpixel_square.ttf",16*4)
	
	love.graphics.setDefaultFilter("nearest","nearest",0)
	
	WINDOWWIDTH = love.graphics.getWidth()
	WINDOWHEIGHT = love.graphics.getHeight()
	
	SCALE = 4
	TRUEWIDTH = WINDOWWIDTH / SCALE
	TRUEHEIGHT = WINDOWHEIGHT / SCALE
	
	ROOMCONTROL = 0
	MENU = 0
	
	masterGameInit()
	masterMenuInit()
	deltat = 0
end

function love.update(dt)
	deltat = dt
	inputManager(dt)

	--if input.escapePressed then
	--	ROOMCONTROL = 0
	--	masterMenuInit()
	--end
	
	if ROOMCONTROL == 1 then
		if MENU == 0 then
			masterMapUpdate(dt)
		else
			masterMapMenu(dt, MENU)
		end
	elseif ROOMCONTROL == 2 then
		masterEditorUpdate(dt)
	else
		masterMenuUpdate(dt)
	end
	
	inputManagerClear(dt)
end

function love.draw()	
	love.graphics.setFont(mainFont)

	if ROOMCONTROL == 1 then
		masterMapDraw(deltat)
		if MENU == 0 then
			masterMapMenuDraw(MENU)
		end
	elseif ROOMCONTROL == 2 then
		masterEditorDraw()
	else
		masterMenuDraw()
	end
	
	love.graphics.print(tostring(debugN), 10, 200)
	love.graphics.print(debugText, 10, 220)
--	love.graphics.print(inputText, 10, 240)
end