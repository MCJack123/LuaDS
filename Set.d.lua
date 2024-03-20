---@meta

---@class Set A set of values.
---@operator len: number
---@operator add(Set): Set
---@operator sub(Set): Set
local Set = {}

--- Creates a new set.
---@param tab? table A list of values to prefill the set with
---@return Set set The new set
function Set:new(tab) end

--- Returns whether the set is empty.
---@return boolean empty Whether the set is empty
function Set:isEmpty() end

--- Returns the number of items in the set.
---@return number length The number of items in the set
function Set:length() end

--- Inserts a value into the set.
---@param value any The value to insert
function Set:insert(value) end

--- Removes a value from the set.
---@param value any The value to remove
function Set:remove(value) end

--- Returns whether a given value exists in the set.
---@param value any The value to check
---@return boolean found Whether the value exists
function Set:find(value) end

--- Returns a new set which only contains items in both sets.
---@param other Set The other set to operate on
---@return Set intersection The intersection of the two sets
function Set:intersection(other) end

--- Returns a new set which contains items in either set.
---@param other Set The other set to operate on
---@return Set union The union of the two sets
function Set:union(other) end

--- Returns a new set which contains all items in this set, except for ones in the other set.
---@param other Set The other set to operate on
---@return Set difference The difference of the two sets
function Set:difference(other) end

--- Returns an index-value iterator function for a for loop.
---@return fun():number|nil,any|nil iter The iterator function
function Set:enumerate() end

--- Returns an array table or List type with the contents of the set.
---@param List? ListType If provided, use this type of list as output
---@return table|List table A table with the contents of the set
function Set:array(List) end
