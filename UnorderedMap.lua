local expect = require "expect"

---@class UnorderedMap: Map A key-value map with no specific order.
---@field private _table table
---@field private _len number
---@operator len: number
local UnorderedMap = {}
UnorderedMap.__mt = {__name = "UnorderedMap"}

--- Creates a new unordered map.
---@param tab? table A table of values to prefill the map with
---@return UnorderedMap map The new map
function UnorderedMap:new(tab)
    return setmetatable({_table = {}, _len = 0}, self.__mt)
end

--- Returns whether the map is empty.
---@return boolean empty Whether the map is empty
function UnorderedMap:isEmpty()
    return self._len == 0
end

--- Returns the number of items in the map.
---@return number length The number of items in the map
function UnorderedMap:length()
    return self._len
end

--- Returns the Lua-style length of the map.
---@return number length The number of integer-keyed items in the map
function UnorderedMap:ilen()
    return #self._table
end

--- Returns the value associated with a given key, or nil if not found.
---@param key any The key to check
---@return any|nil value The value associated with the key
function UnorderedMap:get(key)
    return self._table[key]
end

--- Assigns a key to a value, inserting it if it doesn't exist, or replacing the value if it does.
---@param key any The key to assign to
---@param value any The value to assign
function UnorderedMap:set(key, value)
    if value == nil and self._table[key] ~= nil then
        self._len = self._len - 1
    elseif value ~= nil and self._table[key] == nil then
        self._len = self._len + 1
    end
    self._table[key] = value
end

--- Returns whether a given key exists in the map
---@param key any The key to check
---@return boolean found Whether the key exists
function UnorderedMap:find(key)
    return self._table[key] ~= nil
end

--- Returns a key-value iterator function for a for loop.
---@return fun():any|nil,any|nil iter The iterator function
---@return table iter The iterator invariant
function UnorderedMap:enumerate()
    return next, self._table
end

--- Returns a normal table with the contents of the map.
---@return table table A table with the contents of the map
function UnorderedMap:table()
    local t = {}
    for k, v in pairs(self._table) do t[k] = v end
    return t
end

--- Returns a list (optionally of a List type) with pairs of key-value entries.
---@param List? ListType The type of list to make (defaults to a normal table)
---@return table<{key:any,value:any}>|List pairs A list of key-value pairs in the table
function UnorderedMap:pairs(List)
    if List then
        expect(1, List, "table")
        local retval = List:new()
        for k, v in self:enumerate() do retval:append({key = k, value = v}) end
        return retval
    else
        local retval = {}
        for k, v in self:enumerate() do retval[#retval+1] = {key = k, value = v} end
        return retval
    end
end

function UnorderedMap.__mt:__index(key)
    if UnorderedMap[key] then return UnorderedMap[key] end
    return self._table[key]
end

function UnorderedMap.__mt:__len()
    return self._len
end

function UnorderedMap.__mt:__newindex(key, val)
    return self:set(key, val)
end

function UnorderedMap.__mt:__pairs()
    return next, self._table
end

return UnorderedMap
