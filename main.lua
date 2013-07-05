-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

require("AdjacencyMatrix")
require("Attribution")
require("House")
require("Node")
require("Population")


function appendTable(firstTable, secondTable)
-- Append the contents of secondTable to firstTable.
--
-- Only the sequence of values in secondTable whose keys are sequential numeric indexes
-- starting at one will be appended to firstTable.

	for index, value in ipairs(secondTable) do
		table.insert(firstTable,value)
	end
end

function createMateNodeProp(warrior, width, height, decks)
-- Create an object that conforms to the Node protocol and the Connectable protocol to represent
-- a warrior's mate.

		local warriorPropNode, newProps, newDecks = createWarriorNodeProp(	warrior, width, 
																			height, decks)
		local backgroundTextureFilename =  "Assets/node/mateNodeBackground.png"
		local backgroundDeck = false

		if not decks[backgroundTextureFilename] then
			backgroundDeck = MOAIGfxQuad2D.new()
			backgroundDeck:setTexture(backgroundTextureFilename)
			backgroundDeck:setRect (-width * .5, -height * .5, width * .5, height * .5)
			table.insert(newDecks, backgroundDeck)
		else
			backgroundDeck = decks[backgroundTextureFilename]
		end
		warriorPropNode:setDeck(backgroundDeck)

	return warriorPropNode, newProps, newDecks
end

function createWarriorNodeProp(warrior, width, height, decks)
-- Create an object that conforms to the Node protocol and the Connectable protocol to represent 
-- a warrior.

	local newDecks = {}
	local backgroundTextureFilename =  "Assets/node/warriorNodeBackground.png"
	local backgroundDeck = false
	local backgroundProp = false

	local imageDeck = false
	local imageProp = false
	
	local escutcheonDeck = false
	local escutcheonProp = false

	local backgroundPropPriority = 10
	local imagePropPriority = 20
	local escutcheonPropPriority = 30


	if not decks[backgroundTextureFilename] then
		backgroundDeck = MOAIGfxQuad2D.new()
		backgroundDeck:setTexture(backgroundTextureFilename)
		backgroundDeck:setRect (-width * .5, -height * .5, width * .5, height * .5)
		table.insert(newDecks, backgroundDeck)
	else
		backgroundDeck = decks[backgroundTextureFilename]
	end

	backgroundProp = MOAIProp2D.new()
	backgroundProp:setDeck(backgroundDeck)
	backgroundProp:setPriority(backgroundPropPriority)

	backgroundProp.incomingConnectionPointsInModelSpace =	{
																offspring =	{
																				{
																					x = 0,
																					y = height * .5
																				}
																			},
																mates = {
																				{
																					x = width * .5,
																					y = 0
																				},
																				{
																					x = -width * .5,
																					y = 0
																				}
																		}
															}

	backgroundProp.outgoingConnectionPointsInModelSpace = 	{
																offspring =	{
																				{
																					x = 0,
																					y = -height * .5
																				}
																			},
																mates = {
																				{
																					x = width * .5,
																					y = 0
																				},
																				{
																					x = -width * .5,
																					y = 0
																				}
																		}
															}


	backgroundProp.getWidth =	function(self)
									return width
								end

	backgroundProp.getHeight =	function(self)
									return height
								end

	backgroundProp.setPosition =	function(self, x, y)
										self:setLoc(x,y)
									end

	backgroundProp.getIncomingConnectionPoints =
	function(self)
		return self:convertConnectionPointsToWorldSpace(self.incomingConnectionPointsInModelSpace)
	end

	backgroundProp.getOutgoingConnectionPoints =
	function(self)
		return self:convertConnectionPointsToWorldSpace(self.outgoingConnectionPointsInModelSpace)
	end

	backgroundProp.convertConnectionPointsToWorldSpace = 
		function (self, connectionPoints)
			local connectionPointsInWorldSpace = {}
			for typeOfConnectionPoints, listOfConnectionPoints in
				pairs(connectionPoints) do
				connectionPointsInWorldSpace[typeOfConnectionPoints] = {}
				for index, connectionPoint in ipairs(listOfConnectionPoints) do
					connectionPointsInWorldSpace[typeOfConnectionPoints][index] = {}

					-- This is probably bad but is needed for the call to modelToWorld() to work
					-- right.
					self:forceUpdate()	

					local x,y = self:modelToWorld(connectionPoint["x"], connectionPoint["y"])
					connectionPointsInWorldSpace[typeOfConnectionPoints][index]["x"] = x
					connectionPointsInWorldSpace[typeOfConnectionPoints][index]["y"] = y
				end
			end
			return connectionPointsInWorldSpace
		end

	-- The Node is actually a composite of several props.

	if not decks[warrior.image] then
		imageDeck = MOAIGfxQuad2D.new()
		imageDeck:setTexture(warrior.image)
		imageDeck:setRect (-width * .40, -height * .3, width * .4, height * .3)

		table.insert(newDecks, imageDeck)
	else
		imageDeck = decks[warrior.image]
	end

	imageProp = MOAIProp2D.new()
	imageProp:setDeck(imageDeck)
	imageProp:setPriority(imagePropPriority)

	if not decks[warrior.escutcheon] then
		escutcheonDeck = MOAIGfxQuad2D.new()
		escutcheonDeck:setTexture(warrior.escutcheon)
		escutcheonDeck:setRect (-width * .05, -height * .05, width * .05, height * .05)

		table.insert(newDecks, escutcheonDeck)
	else
		escutcheonDeck = decks[warrior.escutcheon]
	end

	escutcheonProp = MOAIProp2D.new()
	escutcheonProp:setDeck(escutcheonDeck)
	escutcheonProp:setPriority(escutcheonPropPriority)

	backgroundProp:setLoc(0,0)
	imageProp:setLoc(0,0)
	escutcheonProp:setLoc(0 - width * .4, 0 + height * .4)

	-- setParent() is deprecated but seems to work. This should probably be replaced 
	-- with a setAttr() mechanism.
	imageProp:setParent(backgroundProp)
	escutcheonProp:setParent(backgroundProp)

	return backgroundProp, {backgroundProp, imageProp, escutcheonProp} , newDecks
end

function delay(time)
-- Create a delay in the animation.
	local timer = MOAITimer.new()
	timer:setSpan(time)
	MOAICoroutine.blockOnAction(timer:start())
end

function loadSaveFromJSONFile(filename)
-- Load population, house, and relationship data from a JSON file. NOTE: THIS FUNCTION IS UNSAFE TO
-- USE.

	local file = 0
	local JSONtable = 0
	local untranslatedSave = 0
	local population = Population.newPopulation()
	local houses = {}
	local newHouse = 0
	local relationships = {}
	local newRelationship = 0
	local untranslatedFrom = ""
	local untranslatedTo = ""


	-- UNSAFE: filename should be vetted as being an appropriate file to open.
	file = io.open(filename)
	if file then
		-- UNSAFE: file could be too big to handle.
		JSONtable = file:read("*all")
		untranslatedSave = MOAIJsonParser.decode(JSONtable)


		-- Load houses.

		for index, houseData in ipairs(untranslatedSave["houses"]) do
			newHouse = House.newHouseFromFounder(	untranslatedSave["warriors"]
																	[houseData["founder"]])
			for index, indexOfWarrior in ipairs(houseData["members"]) do
				House.addHouseMember(newHouse,
													 untranslatedSave["warriors"][indexOfWarrior])
			end
			table.insert(houses, newHouse)
		end

		-- Load warriors into population.

		for indexOfwarrior, warrior in ipairs(untranslatedSave["warriors"]) do
			Population.addMemberToPopulation(population, warrior)
		end

		-- Load relationships into population.

		for typeOfRelationship, relationship in pairs(untranslatedSave["relationships"]) do
			newRelationship = AdjacencyMatrix.newAdjacencyMatrix()
			for untranslatedStringFrom, row in pairs(relationship) do
				for untranslatedStringTo, weight in pairs(row) do
					-- This could use some reworking. It's an unfortunate side effect of saving
					-- to/from JSON. In JSON, keys in objects (though not arrays) are required to be
					-- strings. 
					untranslatedFrom = tonumber(untranslatedStringFrom)
					untranslatedTo = tonumber(untranslatedStringTo)
					AdjacencyMatrix.setConnection(
													newRelationship,
													untranslatedSave["warriors"][untranslatedFrom],
													untranslatedSave["warriors"][untranslatedTo],
													weight
												)
				end
			end
			population.relationships[typeOfRelationship] = newRelationship
		end
	end

	return population, houses
end

function createConnections(warriors, connectionsToBeMade, population)
-- Create a table that contains tables that in turn represent the connections between nodes.

	local connections = {}
	for index, connectionType in ipairs(connectionsToBeMade) do
		connections[connectionType] = {}
		if population.relationships[connectionType] then
			for warrior in pairs(warriors) do
				if population.relationships[connectionType][warrior] then
					for currentWarrior in 
					pairs(population.relationships[connectionType][warrior]) do
						if warriors[currentWarrior] then
							table.insert(	connections[connectionType],
									 		{
												from = warriors[warrior],
												to = warriors[currentWarrior],
												typeOfConnection = connectionType
											})
						end
					end
				end
			end
		end
	end
	return connections
end

function createConnectionsProp(connections, color, width, height, decks)
-- Create a prop that can be used to display the connections between nodes.

	local outgoingConnectionPoints = false
	local incomingConnectionPoints = false
	local firstXCoordinateOfShortLine = false
	local firstYCoordinateOfShortLine = false
	local secondXCoordinateOfShortLine = false
	local secondYCoordinateOfShortLine = false
	local shortLengthIndicator = false
	local lengthIndicator = false
	local lines = {}


	for indexOfConnection, connection in ipairs(connections) do
		outgoingConnectionPoints = connection["from"]:getOutgoingConnectionPoints()
		incomingConnectionPoints = connection["to"]:getIncomingConnectionPoints()

		for indexOfOutgoingPoint, outgoingPoint in
		ipairs(outgoingConnectionPoints[connection["typeOfConnection"]]) do
			for indexOfIncomingPoint, incomingPoint in
			ipairs(incomingConnectionPoints[connection["typeOfConnection"]]) do
				-- Initialize for the first iteration.
				firstXCoordinateOfShortLine = firstXCoordinateOfShortLine or outgoingPoint["x"]
				firstYCoordinateOfShortLine = firstYCoordinateOfShortLine or outgoingPoint["y"]
				secondXCoordinateOfShortLine = secondXCoordinateOfShortLine or incomingPoint["x"]
				secondYCoordinateOfShortLine = secondYCoordinateOfShortLine or incomingPoint["y"]

	 			-- No need to find the actual distance between points, this is enough.
	 			lengthIndicator = 	(incomingPoint["x"] - outgoingPoint["x"]) *
	 								(incomingPoint["x"] - outgoingPoint["x"]) +
	 								(incomingPoint["y"] - outgoingPoint["y"]) *
	 								(incomingPoint["y"] - outgoingPoint["y"])

				-- Store the shortest line.
				shortLengthIndicator = shortLengthIndicator or lengthIndicator
				if lengthIndicator < shortLengthIndicator then
					shortLengthIndicator = lengthIndicator
					firstXCoordinateOfShortLine = outgoingPoint["x"]
					firstYCoordinateOfShortLine = outgoingPoint["y"]
					secondXCoordinateOfShortLine = incomingPoint["x"]
					secondYCoordinateOfShortLine = incomingPoint["y"]
				end
			end
		end

		table.insert(lines, {	firstXCoordinateOfShortLine, firstYCoordinateOfShortLine,
								secondXCoordinateOfShortLine, secondYCoordinateOfShortLine})

		firstXCoordinateOfShortLine = false
		firstYCoordinateOfShortLine = false
		secondXCoordinateOfShortLine = false
		secondYCoordinateOfShortLine = false
		shortLengthIndicator = false
		lengthIndicator = false
	end

	local drawFunction = 	function ()
								MOAIGfxDevice.setPenColor(	color["r"], color["g"],
															color["b"], color["a"])
								MOAIGfxDevice.setPenWidth(4)

								for index, line in pairs(lines) do
									MOAIDraw.drawLine(line)
								end
							end

	local newScriptDeck = MOAIScriptDeck:new()
	newScriptDeck:setRect(-width * .5, -height * .5, width * .5, height * .5)
	newScriptDeck:setDrawCallback(drawFunction)

	local connectionProp = MOAIProp2D.new()
	connectionProp:setDeck(newScriptDeck)

	return connectionProp, {connectionProp}, {newScriptDeck}
end

function createSpacerNode(width, height)
-- Create a node that represents empty space.

	local space = {}

	space.getWidth =	function(self)
							return width
						end

	space.getHeight =	function(self)
							return height
						end

	space.setPosition =	function(self, x, y)
						end

	return space
end

function createStandardSpacerNode()
-- Create a node that represents empty space with  a width of 60 and a height of 100.

	return createSpacerNode(60, 100)
end

function main()
-- The main function. Not a loop.

	local population, houses = loadSaveFromJSONFile("Data/data.JSON")
	local offspring = population.relationships["offspring"]
	local mates = population.relationships["mates"]
	local founder = houses[1].notables["founder"] 
	local currentRow = false
	local nodeTable = {}
	local decks = {}
	local props = {}
	local nodesForWarriors = {}
	local connections = {}
	local renderTable = {}
	local viewport = MOAIViewport.new()	
	local backgroundLayer = MOAILayer2D.new()
	local escutcheonLayer = MOAILayer2D.new()
	local warriorLayer = MOAILayer2D.new()
	local currentLayer = false
	local connectionColor = {}
	local connectionLayers = {}
	local currentConnectionProp = false
	local newProps = false
	local newDecks = false
	local newNode = false
	local backgroundProp = false
	local backgroundDeck = false
	local backgroundImage = "Assets/Background/background.png"
	local escutcheonProp = false
	local escutcheonDeck = false
	local escutcheonImage = founder.escutcheon


	viewport:setSize(1024, 768)
	viewport:setScale(1024, 768)
	
	-- Satisfy the MOAI CPAL.
	Attribution.attribution(viewport, 1024, 768, 0, 0, false, false)

	backgroundLayer:setViewport(viewport)
	escutcheonLayer:setViewport(viewport)
	warriorLayer:setViewport(viewport)

	-- Construct nodeTable by finding all offspring and mates starting with founder.
	for warrior, newDepth in AdjacencyMatrix.breadthFirstSearch(offspring, founder) do

		if newDepth then
			if currentRow then
				table.insert(nodeTable, {createStandardSpacerNode()})
			end
			currentRow = {}
			table.insert(nodeTable, currentRow)
		else
			table.insert(currentRow, createStandardSpacerNode())
		end

		newNode, newProps, newDecks = createWarriorNodeProp(warrior, 60, 100, decks)
		appendTable(props, newProps)
		appendTable(decks, newDecks)
		table.insert(currentRow, newNode)

		nodesForWarriors[warrior] = newNode
		if mates[warrior] then
			for currentMate in pairs(mates[warrior]) do
				if not nodesForWarriors[currentMate] then
					newNode, newProps, newDecks = createMateNodeProp(currentMate, 60, 100, decks)
					nodesForWarriors[currentMate] = newNode
					appendTable(props, newProps)
					appendTable(decks, newDecks)
					table.insert(currentRow, createStandardSpacerNode())
					table.insert(currentRow, newNode)
				end
			end
		end

	end

	Node.setPlacementOfNodes(nodeTable, 0, 300)

	for index, prop in pairs(props) do
		warriorLayer:insertProp(prop)
	end

	connections = createConnections(nodesForWarriors, {"offspring", "mates"}, population)

	connectionColor =	{
							offspring =	{
											r = .17,
											g = .6,
											b = .8,
											a = 1
										},
							mates =	{
										r = 1,
										g = 1,
										b = 0,
										a = 1
									}
						}

	-- Create props and layers to draw connections.
	for connectionType, connection in pairs(connections) do		
		currentConnectionProp, newProps, newDecks = createConnectionsProp(connection, 
													connectionColor[connectionType], 1080, 768)

		currentConnectionProp:setLoc(0,0)

		currentLayer = MOAILayer2D.new()
		currentLayer:setViewport(viewport)

		for indexOfProp, propToBeInserted in ipairs(newProps) do
			currentLayer:insertProp(propToBeInserted)
		end
		table.insert(connectionLayers, currentLayer)
		appendTable(props, newProps)
		appendTable(decks, newDecks)
	end

	backgroundProp = MOAIProp2D.new()
	backgroundDeck = MOAIGfxQuad2D.new()
	backgroundDeck:setRect(-512, -384, 512, 384)
	backgroundDeck:setTexture(backgroundImage)
	backgroundProp:setDeck(backgroundDeck)
	backgroundProp:setLoc(0,0)
	table.insert(decks, backgroundDeck)
	backgroundLayer:insertProp(backgroundProp)

	escutcheonProp = MOAIProp2D.new()
	escutcheonDeck = MOAIGfxQuad2D.new()
	escutcheonDeck:setRect(-358.4, -268.8, 358.4, 268.8)
	escutcheonDeck:setTexture(escutcheonImage)
	escutcheonProp:setDeck(escutcheonDeck)
	escutcheonProp:setLoc(0,0)
	table.insert(decks, escutcheonDeck)
	escutcheonLayer:insertProp(escutcheonProp)

	-- Insert the layers into the render table so that warrior props are drawn above connection
	-- props.
	table.insert(renderTable, backgroundLayer)
	table.insert(renderTable, escutcheonLayer)
	for index, layer in ipairs(connectionLayers) do
		table.insert(renderTable, layer)
	end
	table.insert(renderTable, warriorLayer)

	MOAIRenderMgr.setRenderTable(renderTable)

	delay(10)
end

function run()
-- Run main() in it's own coroutine then exit.
	mainCR = MOAICoroutine.new()
	mainCR:run(main)
	MOAICoroutine.blockOnAction(mainCR)
	os.exit()
end

MOAISim.openWindow ("Warrior Family Tree", 1024, 768)
runCR = MOAICoroutine.new()
runCR:run(run)