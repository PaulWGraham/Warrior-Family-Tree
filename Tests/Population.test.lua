-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

require("simpletest")

local testManager = simpletest.TestManager:new()

-- Name the test batch.
testManager:setNameOfTestBatch("Population")

-- Setups
function setup_1()
	if require("Population") then
		return true
	end
	return false
end

testManager:addSetup({setup = setup_1, setupMessage = "require Population"})

function setup_2()
	keyOne = {}

	return true
end

testManager:addSetup({setup = setup_2, setupMessage = "setup persistent table keys"})

-- Tests

function test_1()
	local population = Population.newPopulation()

	if not population then
		return false
	end

	return	true
end

testManager:addTest({test = test_1, testMessage = "Test newPopulation()"})

function test_2()
	local population = Population.newPopulation()
	Population.addMemberToPopulation(population, keyOne)

	if not population.populace[keyOne] then
		return false
	end

	return true
end

testManager:addTest({test = test_2, testMessage = "Test addMemberToPopulation()"})

return testManager:runTests()