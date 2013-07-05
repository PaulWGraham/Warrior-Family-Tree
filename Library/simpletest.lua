-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

local setmetatable = setmetatable
local type = type
local error = error
local io = io
local ipairs = ipairs
local pcall = pcall

local PACKAGE = {}
if _REQUIREDNAME == nil then
	simpletest = PACKAGE
else
	_G[_REQUIREDNAME] = PACKAGE
end
setfenv(1,PACKAGE)

VERSION = 0.1

TestManager = {}
function TestManager.new(self, object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self

	object._tests = {}
	object._setups = {}
	object._teardowns = {}
	
	object._numberOfTests = 0
	object._numberOfSetups = 0
	object._numberOfTeardowns = 0 

	return object
end

function TestManager.addSetup(testManager, setup, successMessage, failureMessage, setupMessage)

	local newSetup = false
	if type(setup) == "table" then
		if successMessage or failureMessage or setupMessage then
			error("Parameter setup is a table therefor successMessage, failureMessage, and setupMessage should not be specified as parameters.", 2)
			return false
		end

		newSetup = testManager:_createCallbackTableFromTable(setup, "setup", "setupMessage")
	else
		newSetup = testManager:_createCallbackTableFromTable({setup, successMessage, failureMessage, setupMessage}, "setup", "setupMessage")
	end

	if not newSetup then
		error("Invalid setup function.",2)
		return false
	end

	testManager._numberOfSetups = testManager._numberOfSetups + 1
	testManager._setups[testManager._numberOfSetups] = newSetup

	return true
end

function TestManager.addTeardown(testManager, teardown, successMessage, failureMessage, teardownMessage)

	local newTeardown = false
	if type(teardown) == "table" then
		if successMessage or failureMessage or teardownMessage then
			error("Parameter teardown is a table therefor successMessage, failureMessage, and teardownMessage should not be specified as parameters.", 2)
			return false
		end

		newTeardown = testManager:_createCallbackTableFromTable(teardown, "teardown", "teardownMessage")
	else
		newTeardown = testManager:_createCallbackTableFromTable({teardown, successMessage, failureMessage, teardownMessage}, "teardown", "teardownMessage")
	end

	if not newTeardown then
		error("Invalid teardown function.",2)
		return false
	end

	testManager._numberOfTeardowns = testManager._numberOfTeardowns + 1
	testManager._teardowns[testManager._numberOfTeardowns] = newTeardown

	return true
end

function TestManager.addTest(testManager, test, successMessage, failureMessage, testMessage)

	local newTest = false
	if type(test) == "table" then
		if successMessage or failureMessage or testMessage then
			error("Parameter test is a table therefore successMessage, failureMessage, or testMessage should not be specified as parameters.", 2)
			return false
		end

		newTest = testManager:_createCallbackTableFromTable(test, "test", "testMessage")
	else
		newTest = testManager:_createCallbackTableFromTable({test, successMessage, failureMessage, testMessage}, "test", "testMessage")
	end

	if not newTest then
		error("Invalid test function.", 2)
		return false
	end

	testManager._numberOfTests = testManager._numberOfTests + 1
	testManager._tests[testManager._numberOfTests] = newTest

	return true
end

function TestManager.runTests(testManager)
	local allSetupsSuccessful, passedAllTests, allTeardownsSuccessful
	local setupSummary, testingSummary, teardownSummary
	local lastSetupCompleted

	if testManager._nameOfTestBatch then
		io.write("Name of test batch: ", testManager._nameOfTestBatch, "\n")
	end

	allSetupsSuccessful, lastSetupCompleted, setupSummary = testManager:_runSetups()
	io.write("Setup result: ",setupSummary,"\n")

	if allSetupsSuccessful then
		passedAllTests, testingSummary = testManager:_runTests()
		io.write("Testing result: ",testingSummary,"\n")
		allTeardownsSuccessful, teardownSummary = testManager:_runTeardowns()
		io.write("Teardown result: ",teardownSummary,"\n")
	else
		io.write("\n","CANCELING TESTS.","\n")
		passedAllTests = false
		testingSummary = "TESTS WERE CANCELED"
		if testManager._numberOfTeardowns > lastSetupCompleted then
			io.write("RUNNING LIMITED TEARDOWN.","\n")
			allTeardownsSuccessful, teardownSummary = testManager:_runTeardowns(lastSetupCompleted)
		else
			allTeardownsSuccessful, teardownSummary = testManager:_runTeardowns()
		end
		io.write("Teardown result: ",teardownSummary,"\n")
	end

	testManager:_outputSummary(setupSummary, testingSummary, teardownSummary)

	return allSetupsSuccessful and passedAllTests and allTeardownsSuccessful
end

function TestManager.setNameOfTestBatch(testManager, name)
	testManager._nameOfTestBatch = name
end

function TestManager._createCallbackTableFromTable(testManager, parameterTable, callbackKey, messageKey)
	local newCallbackTable = {}

	if parameterTable[callbackKey] then
		newCallbackTable["callback"] = parameterTable[callbackKey]
		newCallbackTable["successMessage"] = parameterTable["successMessage"]
		newCallbackTable["failureMessage"] = parameterTable["failureMessage"]
		newCallbackTable["message"] = parameterTable[messageKey]
	else
		newCallbackTable["callback"] = parameterTable[1]
		newCallbackTable["successMessage"] = parameterTable[2]
		newCallbackTable["failureMessage"] = parameterTable[3]
		newCallbackTable["message"] = parameterTable[4]
	end

	if type(newCallbackTable["callback"]) ~= "function" then
		return nil
	end

	return newCallbackTable
end

function TestManager._checkForDuplicateCallbacks(testManager, callbackTable)
	local allCallbacksByCallback = {}
	local duplicateCallbacksByIndex, indexOfDuplicateCallback, n, x, duplicateCallbackIndexList
	if callbackTable then
		for indexInCallbackTable, value in ipairs(callbackTable) do
			if not allCallbacksByCallback[value["callback"]] then
				allCallbacksByCallback[value["callback"]] = {[1] = indexInCallbackTable, ["n"] = 1}
			else
				duplicateCallbacksByIndex = duplicateCallbacksByIndex or {}
				duplicateCallbacksByIndex[indexInCallbackTable] = duplicateCallbacksByIndex[indexInCallbackTable] or {}
				n = allCallbacksByCallback[value["callback"]]["n"]
				x = 1 
				for x = 1, n do
					indexOfDuplicateCallback = allCallbacksByCallback[value["callback"]][x]
					duplicateCallbacksByIndex[indexOfDuplicateCallback] = duplicateCallbacksByIndex[indexOfDuplicateCallback] or {}
					duplicateCallbackIndexList = duplicateCallbacksByIndex[indexOfDuplicateCallback]
					duplicateCallbackIndexList[n] = indexInCallbackTable
					duplicateCallbackIndexList = duplicateCallbacksByIndex[indexInCallbackTable]
					duplicateCallbackIndexList[x] = indexOfDuplicateCallback
				end
				allCallbacksByCallback[value["callback"]]["n"] = n + 1 
				allCallbacksByCallback[value["callback"]][allCallbacksByCallback[value["callback"]]["n"]] = indexInCallbackTable
			end
		end
	end
	return duplicateCallbacksByIndex
end


function TestManager._outputSummary(testManager, setupSummary, testingSummary, teardownSummary)
	io.write("\n","\n","Testing Summary:","\n")
	if testManager._nameOfTestBatch then
		io.write("Name of test batch: ", testManager._nameOfTestBatch, "\n")
	end
	io.write("Setup result: ", setupSummary, "\n")
	io.write("Testing result: ", testingSummary, "\n")
	io.write("Teardown result: ", teardownSummary, "\n")
end

function TestManager._runSetups(testManager)
	local allSetupsSuccessful = true
	local lastSetupCompleted = 0
	local setupSummary = "Success"
	local duplicateSetupWarning = "WARNING: The same function is used for more than one setup."
	local completedWithoutUncaughtException, completedSuccessfully

	local dupicateSetups = testManager:_checkForDuplicateCallbacks(testManager._setups)
	if testManager._numberOfSetups > 0 then
		io.write("\n","Setting up:","\n","\n")
		if dupicateSetups then
			io.write("\n",duplicateSetupWarning,"\n","\n")
		end

		for index, callbackTable in ipairs(testManager._setups) do
			io.write("Setup ", index, "\n")
			if dupicateSetups and dupicateSetups[index] then
				io.write("WARNING: The same function that is used for this setup is also used for the following ")
				if dupicateSetups[index][2] then
					io.write("setups: ")
				else
					io.write("setup: ")
				end

				local firstIndexOutput = true
				for indexOfIndex, indexDuplicateSetup in ipairs(dupicateSetups[index]) do
					if not firstIndexOutput then
						io.write(", ")
					else
						firstIndexOutput = false
					end
					io.write(indexDuplicateSetup)
				end
				io.write("\n")
			end
			if callbackTable["message"] then
				io.write(callbackTable["message"], "\n")
			end
			io.write("Running setup.. ")
			completedWithoutUncaughtException, completedSuccessfully = pcall(callbackTable["callback"])
			if completedWithoutUncaughtException and completedSuccessfully then
				io.write("Success","\n")
				if callbackTable["successMessage"] then
					io.write(callbackTable["successMessage"], "\n")
				end
			else
				io.write("FAILURE","\n")
				if callbackTable["failureMessage"] then
					io.write(callbackTable["failureMessage"], "\n")
				end
				setupSummary = "FAILURE"
				allSetupsSuccessful = false
				break
			end
			lastSetupCompleted = index
		end
	else
		setupSummary = "NO SETUP WAS DONE"
	end

	io.write("\n")

	if dupicateSetups then
		setupSummary = setupSummary .. " " .. duplicateSetupWarning
	end

	return allSetupsSuccessful, lastSetupCompleted, setupSummary
end

function TestManager._runTeardowns(testManager, numberOfTeardownsToRun)
	local allTeardownsSuccessful = true
	local teardownSummary = "Success"
	local duplicateTeardownWarning = "WARNING: The same function is used for more than one teardown."
	local indexOfLastIndexToRun
	local completedWithoutUncaughtException, completedSuccessfully

	local dupicateTeardowns = testManager:_checkForDuplicateCallbacks(testManager._teardowns)

	indexOfLastIndexToRun = testManager._numberOfTeardowns
	if numberOfTeardownsToRun and numberOfTeardownsToRun < testManager._numberOfTeardowns then
		indexOfLastIndexToRun = numberOfTeardownsToRun
	end

	if testManager._numberOfTeardowns > 0 then
		io.write("\n","Running teardowns:","\n","\n")
		if dupicateTeardowns then
			io.write("\n",duplicateTeardownWarning,"\n","\n")
		end

		for index = 1, indexOfLastIndexToRun do
			callbackTable = testManager._teardowns[index]
			io.write("Teardown ", index, "\n")
			if dupicateTeardowns and dupicateTeardowns[index] then
				io.write("WARNING: The same function that is used for this teardown is also used for the following ")
				if dupicateTeardowns[index][2] then
					io.write("teardowns: ")
				else
					io.write("teardown: ")
				end

				local firstIndexOutput = true
				for indexOfIndex, indexDuplicateTeardown in ipairs(dupicateTeardowns[index]) do
					if not firstIndexOutput then
						io.write(", ")
					else
						firstIndexOutput = false
					end
					io.write(indexDuplicateTeardown)
				end
				io.write("\n")
			end
			if callbackTable["message"] then
				io.write(callbackTable["message"], "\n")
			end
			io.write("Running teardown.. ")
			completedWithoutUncaughtException, completedSuccessfully = pcall(callbackTable["callback"])
			if completedWithoutUncaughtException and completedSuccessfully then
				io.write("Passed","\n")
				if callbackTable["successMessage"] then
					io.write(callbackTable["successMessage"], "\n")
				end
			else
				io.write("FAILED","\n")
				if callbackTable["failureMessage"] then
					io.write(callbackTable["failureMessage"], "\n")
				end
				teardownSummary = "FAILED"
				allTeardownsSuccessful = false
			end
		end
		if indexOfLastIndexToRun < testManager._numberOfTeardowns then
			teardownSummary = "NOT EVERY TEARDOWN WAS RUN"
			allTeardownsSuccessful = false
		end
	else
		teardownSummary = "NO TEARDOWN WAS DONE"
	end
	
	io.write("\n")

	if dupicateTeardowns then
		teardownSummary = teardownSummary .. " " .. duplicateTeardownWarning
	end
	return allTeardownsSuccessful, teardownSummary
end

function TestManager._runTests(testManager)
	local passedAllTests = true
	local testingSummary = "Passed"
	local duplicateTestWarning = "WARNING: The same function is used for more than one test."
	local completedWithoutUncaughtException, completedSuccessfully

	local dupicateTests = testManager:_checkForDuplicateCallbacks(testManager._tests)
	if testManager._numberOfTests > 0 then
		io.write("\n","Running tests:","\n","\n")
		if dupicateTests then
			io.write("\n",duplicateTestWarning,"\n","\n")
		end

		for index, callbackTable in ipairs(testManager._tests) do
			io.write("Test ", index, "\n")
			if dupicateTests and dupicateTests[index] then
				io.write("WARNING: The same function that is used for this test is also used for the following ")
				if dupicateTests[index][2] then
					io.write("tests: ")
				else
					io.write("test: ")
				end

				local firstIndexOutput = true
				for indexOfIndex, indexDuplicateTest in ipairs(dupicateTests[index]) do
					if not firstIndexOutput then
						io.write(", ")
					else
						firstIndexOutput = false
					end
					io.write(indexDuplicateTest)
				end
				io.write("\n")
			end
			if callbackTable["message"] then
				io.write(callbackTable["message"], "\n")
			end
			io.write("Running test.. ")
			completedWithoutUncaughtException, completedSuccessfully = pcall(callbackTable["callback"])
			if completedWithoutUncaughtException and completedSuccessfully then
				io.write("Passed","\n")
				if callbackTable["successMessage"] then
					io.write(callbackTable["successMessage"], "\n")
				end
			else
				io.write("FAILED","\n")
				if callbackTable["failureMessage"] then
					io.write(callbackTable["failureMessage"], "\n")
				end
				testingSummary = "FAILED"
				passedAllTests = false
			end
		end
	else
		testingSummary = "NO TESTS WERE DONE"
	end

	io.write("\n")

	if dupicateTests then
		testingSummary = testingSummary .. " " .. duplicateTestWarning
	end

	return passedAllTests, testingSummary
end


return PACKAGE