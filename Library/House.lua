-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

local setmetatable = setmetatable

local PACKAGE = {}
if _REQUIREDNAME == nil then
	House = PACKAGE
else
	_G[_REQUIREDNAME] = PACKAGE
end
setfenv(1,PACKAGE)

function newHouse()
-- Create and return a new house object.

	local weakKeyMetatable = {__mode = "k"}
	local house = {}

	house.notables = {}
	house.members = {}

	setmetatable(house.notables, weakValueMetatable)
	setmetatable(house.members, weakValueMetatable)

	return house
end

function newHouseFromFounder(founder)
-- Create and return a new house object that incorporates founder.
--
-- In the new object, object.notables["founder"] is set to founder and object.members[founder] is
-- set to true.

	house = newHouse()

	house.notables["founder"] = founder
	house.members[founder] = true

	return house
end

function addHouseMember(house, member)
-- Add a member to the house.

	house.members[member] = true
end

return PACKAGE
