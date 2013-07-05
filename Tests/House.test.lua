-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

require("simpletest")

local testManager = simpletest.TestManager:new()

-- Name the test batch.
testManager:setNameOfTestBatch("House")

-- Setups
function setup_1()
	if require("House") then
		return true
	end
	return false
end

testManager:addSetup({setup = setup_1, setupMessage = "require House"})

function setup_2()
	keyOne = {}
	keyTwo = {}
	keyThree = {}
	keyFour = {}

	return true
end

testManager:addSetup({setup = setup_2, setupMessage = "setup persistent table keys"})

-- Tests

function test_1()
	local house = House.newHouse()

	if house == nil or house.notables == nil or house.members == nil then
		return false
	end

	return	true
end

testManager:addTest({test = test_1, testMessage = "Test newHouse()"})

function test_2()
	local house = House.newHouseFromFounder(keyOne)

	if house == nil then
		return false
	end

	if not house["founder"] == keyOne then
		return false
	end

	if not house.members[keyOne] then
		return false
	end

	return true
end

testManager:addTest({test = test_2, testMessage = "Test newHouseFromFounder()"})

function test_3()
	local house = House.newHouseFromFounder(keyOne)

	House.addHouseMember(house, keyTwo)
	if not house.members[keyTwo] then
		return false
	end

	return true
end

testManager:addTest({test = test_3, testMessage = "Test addHouseMember()"})

return testManager:runTests()