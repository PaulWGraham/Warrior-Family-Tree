-- Copyright (c) 2013 Paul Graham 
-- See LICENSE for details.

local setmetatable = setmetatable
local table = table
local pairs = pairs
local coroutine = coroutine

local PACKAGE = {}
if _REQUIREDNAME == nil then
	AdjacencyMatrix = PACKAGE
else
	_G[_REQUIREDNAME] = PACKAGE
end
setfenv(1,PACKAGE)

function newWeakKeyTable()
-- Create and return a table with a metatable that has __mode == "k".  

	local weakKeyMetatable = {__mode = "k"}
	local weakKeyTable = {}
	
	setmetatable(weakKeyTable, weakKeyMetatable)

	return weakKeyTable
end

function newAdjacencyMatrix()
-- Create and return an empty adjacency matrix.  

	return newWeakKeyTable()
end

function getConnection(adjacencyMatrix, from, to)
-- Get the weight of the edge from the vertex indicated in the parameter "from" to the vertex
-- indicated but the parameter "to", if one exits.
--
-- Parameters:
--             adjacencyMatrix - An adjacency matrix for a weighted digraph.  
--             from - The vertex the edge goes from.
--             to - The vertex the edge goes to.

	if adjacencyMatrix[from] then
		return adjacencyMatrix[from][to]
	end

	return nil
end

function setConnection(adjacencyMatrix, from, to, weight)
-- Create of modify an edge in adjacencyMatrix from the vertex indicated in the parameter "from" to
-- the vertex indicated by the parameter "to" and set its weight.
--
-- Parameters:
--             adjacencyMatrix - An adjacency matrix for a weighted digraph.  
--             from - The vertex the edge goes from.
--             to - The vertex the edge goes to.
--             weight - The weight associated with the edge

	if not adjacencyMatrix[from] then
		 adjacencyMatrix[from] = newWeakKeyTable()
	end

	adjacencyMatrix[from][to] = weight
end

function breadthFirstSearch(adjacencyMatrix, startingVertex, sortingFunctionForAdjacentVerticies)
-- Return an iterator that performs a breadth first search of adjacencyMatrix starting at
-- startingVertex.
--
-- The order in which the vertices found are returned is not stable across successive calls. If
-- adjacencyMatrixSuccessive and startingVertex are unchanged then successive calls will return the
-- same set of vertices but possibly not in the same order. This behavior can be changed by
-- specifying a sorting function in sortingFunctionForAdjacentVerticies. The sorting function sorts
-- the list of adjacent vertices for a given vertex before adding them to the search queue.
--
-- Parameters:
--             adjacencyMatrix - An adjacency matrix for a weighted digraph.  
--             startingVertex - The vertex the breadth first search starts from.
--             sortingFunctionForAdjacentVerticies -  A sorting function sorts that sorts the list
--                                                    of adjacent vertices for a given vertex before
--                                                    adding them to the search queue.

	-- Iterator
	local searchRoutine = 	function ()
								local currentQueue = {}
								local sortQueue = {}
								local nextQueue = {}
								local seen = {}
								local currentVertex = false
								local startOfNewDepth = false

								if not adjacencyMatrix[startingVertex] then
									return nil
								end

								-- By initializing nextQueue with startingVertex instead of
								-- currentQueue ensures that a change in depth is reported.
								table.insert(nextQueue, startingVertex)
								seen[startingVertex] = true

								while(true) do
									if not (#currentQueue > 0) then
										if #nextQueue > 0 then
											local tempQueue = currentQueue
											currentQueue = nextQueue
											nextQueue = tempQueue
											startOfNewDepth = true
										else
											return nil
										end
									else
										startOfNewDepth = false
									end

									currentVertex = table.remove(currentQueue, 1)
									-- It's this call to pairs() that causes the order in which
									-- vertices are returned to not be stable between calls.
									if adjacencyMatrix[currentVertex] then
										for vertex, weight in
										pairs(adjacencyMatrix[currentVertex]) do
											if not seen[vertex] then
												table.insert(sortQueue, vertex)
												seen[vertex] = true
											end
										end
									end

									if sortingFunctionForAdjacentVerticies then
										table.sort(sortQueue, sortingFunctionForAdjacentVerticies)
									end

									while #sortQueue > 0 do
										table.insert(nextQueue, table.remove(sortQueue, 1))
									end

									coroutine.yield(currentVertex, startOfNewDepth)
								end
							end
	return coroutine.wrap(searchRoutine)
end

return PACKAGE