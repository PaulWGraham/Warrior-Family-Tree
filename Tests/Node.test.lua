-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

require("simpletest")

local testManager = simpletest.TestManager:new()

-- Name the test batch.
testManager:setNameOfTestBatch("Node")

-- Setups
function setup_1()
	if require("Node") then
		return true
	end
	return false
end

testManager:addSetup({setup = setup_1, setupMessage = "require Node"})

-- Tests

function test_1()
	local node = Node.createTestNode(1,14)

	if not node then
		return false
	end

	if node.getWidth() ~= 1 then
		return false
	end

	if node.getHeight() ~= 14 then
		return false
	end

	node:setPosition(5,10)

	if node.x ~= 5 then
		return false
	end

	if node.y ~= 10 then
		return false
	end

	return	true
end

testManager:addTest({test = test_1, testMessage = "Test createTestNode()"})

function test_2()
	local nodeTable = {}

	nodeTable[1] = { Node.createTestNode(1,3), Node.createTestNode(2,4), Node.createTestNode(1,5) }
	nodeTable[2] = { Node.createTestNode(5,5), Node.createTestNode(5,5), Node.createTestNode(5,5), Node.createTestNode(5,5) }
	nodeTable[3] = { Node.createTestNode(3,3) }



	Node.setPlacementOfNodes(nodeTable, 3, 2)

	if nodeTable[1][1].x ~= 1.5 or nodeTable[1][1].y ~= -2 then 
		return false
	end

	if nodeTable[1][2].x ~= 3 or nodeTable[1][2].y ~= -2.5 then 
		return false
	end

	if nodeTable[1][3].x ~= 4.5  or nodeTable[1][3].y ~= -3 then 
		return false
	end


	if nodeTable[2][1].x ~= -4.5  or nodeTable[2][1].y ~= -8 then 
		return false
	end

	if nodeTable[2][2].x ~= .5 or nodeTable[2][2].y ~= -8 then 
		return false
	end

	if nodeTable[2][3].x ~= 5.5  or nodeTable[2][3].y ~= -8 then 
		return false
	end

	if nodeTable[2][4].x ~= 10.5  or nodeTable[2][4].y ~= -8 then 
		return false
	end


	if nodeTable[3][1].x ~= 3 or nodeTable[3][1].y ~= -12 then
		return false
	end

	return true

end

testManager:addTest({test = test_2, testMessage = "Test setPlacementOfNodes()"})

return testManager:runTests()