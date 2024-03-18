---@meta

---@class Map A key-value map.
---@operator len: number
local Map = {}

--- Creates a new map.
---@param tab? table A table of values to prefill the map with
---@return Map map The new map
function Map:new(tab) end

--- Returns whether the map is empty.
---@return boolean empty Whether the map is empty
function Map:isEmpty() end

--- Returns the number of items in the map.
---@return number length The number of items in the map
function Map:length() end

--- Returns the value associated with a given key, or nil if not found.
---@param key any The key to check
---@return any|nil value The value associated with the key
function Map:get(key) end

--- Assigns a key to a value, inserting it if it doesn't exist, or replacing the value if it does.
---@param key any The key to assign to
---@param value any The value to assign
function Map:set(key, value) end

--- Returns whether a given key exists in the map
---@param key any The key to check
---@return boolean found Whether the key exists
function Map:find(key) end

--- Returns a key-value iterator function for a for loop.
---@return fun():any|nil,any|nil iter The iterator function
function Map:enumerate() end

--- Returns a normal table with the contents of the map.
---@return table table A table with the contents of the map
function Map:table() end

--- Returns a list (optionally of a List type) with pairs of key-value entries.
---@param List? ListType The type of list to make (defaults to a normal table)
---@return table<{key:any,value:any}>|List pairs A list of key-value pairs in the table
function Map:pairs(List) end

return Map
