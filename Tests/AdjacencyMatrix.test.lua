-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

require("simpletest")

local testManager = simpletest.TestManager:new()

-- Name the test batch.
testManager:setNameOfTestBatch("AdjacencyMatrix")

-- Setups
function setup_1()
	if require("AdjacencyMatrix") then
		return true
	end
	return false
end

testManager:addSetup({setup = setup_1, setupMessage = "require AdjacencyMatrix"})

function setup_2()
	testMatrixOne =	{	A = { B = .1, C = .1},
							
							B = { D = .1 },
							C = { D = .1 },
							
							D = { E = .1,  A = .1},
							
							E = { F = .1 , G = .1, H = .1},
							
							F = { G = .1},
							G = { F = .1},
							H = { H = .1},
							
							I = { J = .1},
							J = { I = .1}
					 	}

	return true
end

testManager:addSetup({setup = setup_2, setupMessage = "setup test matrices"})

-- Tests

function test_1()
	if AdjacencyMatrix.newAdjacencyMatrix() then
		return true
	end

	return	false
end

testManager:addTest({test = test_1, testMessage = "Test newAdjacencyMatrix()"})

function test_2()
	if	AdjacencyMatrix.getConnection(testMatrixOne,"A","D") or
		AdjacencyMatrix.getConnection(testMatrixOne,"C","A") then
			return false
	end

	return	AdjacencyMatrix.getConnection(testMatrixOne,"A","B") == .1 and
			AdjacencyMatrix.getConnection(testMatrixOne,"D","A") == .1
end

testManager:addTest({test = test_2, testMessage = "Test getConnection()"})

function test_3()
	local newMatrix = AdjacencyMatrix.newAdjacencyMatrix()
	local keyOne = {}
	local keyTwo = {}
	local count 

	AdjacencyMatrix.setConnection(newMatrix,keyOne,keyTwo, .1)
	if not AdjacencyMatrix.getConnection(newMatrix,keyOne,keyTwo) == .1 then 
		return false
	end

	keyTwo = nil
	collectgarbage("collect")

	if not next(newMatrix[keyOne]) == nil then 
		return false
	end
	
	return true
end

testManager:addTest({test = test_3, testMessage = "Test setConnection()"})

function test_4()
	local count = 0
	local constructedString = ""
	local sortingFunction =	function (firstKeyToBeCompared, secondKeyToBeCompared)
								return firstKeyToBeCompared < secondKeyToBeCompared
							end

	for x, y in AdjacencyMatrix.breadthFirstSearch(testMatrixOne, "A") do
		count = count + 1
	end

	if count ~= 8 then
		return false
	end

	count = 0
	for x, y in AdjacencyMatrix.breadthFirstSearch(testMatrixOne, "A") do
		if y then
			count = count + 1
		end
	end

	if count ~= 5 then
		return false
	end

	count = 0
	for x, y in AdjacencyMatrix.breadthFirstSearch(testMatrixOne, "E") do
		if y then
			count = count + 1
		end
	end

	if count ~= 2 then
		return false
	end

	for x, y in AdjacencyMatrix.breadthFirstSearch(testMatrixOne, "A", sortingFunction) do
		constructedString = constructedString .. x
	end


	return constructedString == "ABCDEFGH" 
end

testManager:addTest({test = test_4, testMessage = "Test breadthFirstSearch()"})

return testManager:runTests()