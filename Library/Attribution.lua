-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

local MOAILayer2D = MOAILayer2D
local MOAIGfxQuad2D = MOAIGfxQuad2D
local MOAIProp2D = MOAIProp2D
local MOAIRenderMgr = MOAIRenderMgr
local MOAITimer = MOAITimer
local MOAICoroutine = MOAICoroutine
local MOAIEaseType = MOAIEaseType
local math = math

local PACKAGE =	{}
if _REQUIREDNAME == nil then
	Attribution = PACKAGE
else
	_G[_REQUIREDNAME] = PACKAGE
end
setfenv(1,PACKAGE)

function attribution(viewport, xScale, yScale, centerX, centerY, white, resetRenderStack, transitionTime, transitionType)
	local attributionLayer = MOAILayer2D.new ()
	local attributionQuad = MOAIGfxQuad2D.new ()
	local attributionProp = MOAIProp2D.new ()

	if math.abs(xScale/yScale) == 4/3 then
		if white then
			attributionPath = "Attribution/moaiattribution_horiz_white.png"
		else
			attributionPath = "Attribution/moaiattribution_horiz_black.png"
		end
	else
		if white then
			attributionPath = "Attribution/moaiattribution_vert_white.png"
		else
			attributionPath = "Attribution/moaiattribution_vert_black.png"
		end
	end

	local deltaX = .5 * xScale
	local deltaY = .5 * yScale

	attributionQuad:setTexture(attributionPath)
	attributionQuad:setRect(-deltaX, -deltaY, deltaX, deltaY)
	attributionProp:setDeck(attributionQuad)
	attributionProp:setLoc(centerX, centerY)
	attributionProp:setPriority(20)
	attributionLayer:insertProp(attributionProp)

	attributionLayer:setViewport(viewport)

	local oldRenderTable = MOAIRenderMgr.getRenderTable()

	if resetRenderStack == nil then
		 resetRenderStack = true
	end

	if resetRenderStack then
		MOAIRenderMgr.setRenderTable({attributionLayer})
	else
		if oldRenderTable then
			oldRenderTable[#oldRenderTable + 1] = attributionLayer
			MOAIRenderMgr.setRenderTable(oldRenderTable)
		else
			MOAIRenderMgr.setRenderTable({attributionLayer})
		end
	end

	local timer = MOAITimer.new()
	timer:setSpan(3)
	MOAICoroutine.blockOnAction(timer:start())

	transitionTime = transitionTime or 2	 
	transitionType = transitionType or MOAIEaseType.EASE_IN
	MOAICoroutine.blockOnAction(attributionProp:seekColor(0,0,0,0,transitionTime,transitionType))

	if resetRenderStack then
		MOAIRenderMgr.setRenderTable(oldRenderTable)
	end
end

return PACKAGE