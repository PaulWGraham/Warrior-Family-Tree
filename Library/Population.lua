-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

local setmetatable = setmetatable

local PACKAGE = {}
if _REQUIREDNAME == nil then
	Population = PACKAGE
else
	_G[_REQUIREDNAME] = PACKAGE
end
setfenv(1,PACKAGE)

function newPopulation()
-- Create and return a new population object.

	local population = { populace = {}, relationships = {} }
	return population
end

function addMemberToPopulation(population, newMember)
-- Add a new member to the populace of population

	population.populace[newMember] = true 
end

return PACKAGE