-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

local ipairs = ipairs

local PACKAGE = {}
if _REQUIREDNAME == nil then
	Node = PACKAGE
else
	_G[_REQUIREDNAME] = PACKAGE
end
setfenv(1,PACKAGE)


-- The Node Protocol 
--
-- For an object to conform to the Node protocol it must have the following:
--
-- Functions:
--      getHeight() - Returns the height of the object in world units.
--      getWidth() - Returns the width of the object in world units.
--      setPosition(x,y) - Set the position of the object to point x,y. x,y are specified in world
--                         units.


function createTestNode(width, height)
-- Create a test node that conforms to the Node Protocol.
--
-- When getWidth() is called on the test object the value of the parameter width is returned. When
-- getHeight() is called on the test object the value of the parameter height is returned. When
-- setPosition() is called on the test object the x,y coordinates are stored in the respective x and
-- y member variables of the test object.

	local testNode = {}
	testNode.getWidth =	function (self)
								return width
							end

	testNode.getHeight =	function (self)
								return height
							end

	testNode.setPosition =	function(self, x, y)
								self.x = x
								self.y = y
							end
	return testNode
end

function setPlacementOfNodes(nodes, centerOfFirstRowX, centerOfFirstRowY)	
-- Set the position of each node in nodes so that the first row of nodes is centered at the
-- specified point and each subsequent row of nodes is centered under the previous one.
--
-- After the the desired position of a node is calculated, setPosition() is called on that node with
-- that position.
--
-- Parameters:
--             nodes - A two dimensional table of objects the conform to the Node protocol.
--             centerOfFirstRowX - The x coordinate of the point that the first row of nodes is
--                                 centered at.
--             centerOfFirstRowY - The y coordinate of the point that the first row of nodes is
--                                 centered at.

	local dimensionsOfRows = {}
	local currentMaxHeightOfNodesInRow = 0
	local currentWidthOfRow = 0
	local currentNodeHeight = 0
	local currentXOffset = 0
	local currentYOffset = 0
	local nodeWidth = 0

	-- Find the width and height of each row for use when calculating the individual node position.
	for indexOfRow, row in ipairs(nodes) do
		currentMaxHeightOfNodeInRow = 0
		currentWidthOfRow = 0
		for indexOfNode, node in ipairs(row) do
			currentWidthOfRow = currentWidthOfRow + node:getWidth()
			currentNodeHeight = node:getHeight()
			if currentNodeHeight > currentMaxHeightOfNodesInRow then
				currentMaxHeightOfNodesInRow = currentNodeHeight
			end
		end
		dimensionsOfRows[indexOfRow] = { width = currentWidthOfRow,
		                                 height = currentMaxHeightOfNodesInRow }
	end

	-- The first row is a special case as its position is determined the parameters 
	-- centerOfFirstRowX, centerOfFirstRowY not by the position of the previous row. This is
	-- accounted for by faking a previous row by setting currentYOffset accordingly.
	currentYOffset = centerOfFirstRowY - .5 * dimensionsOfRows[1]["height"]

	-- Set the position of the individual nodes.
	for indexOfRow, row in ipairs(nodes) do
		currentXOffset = centerOfFirstRowX - .5 * dimensionsOfRows[indexOfRow]["width"]
		for indexOfNode, node in ipairs(row) do
			nodeWidth = node:getWidth()
			node:setPosition(currentXOffset + .5 * nodeWidth, currentYOffset - .5 * node:getHeight())
			currentXOffset = currentXOffset + nodeWidth
		end
		currentYOffset = currentYOffset - dimensionsOfRows[indexOfRow]["height"]
	end
end

return PACKAGE