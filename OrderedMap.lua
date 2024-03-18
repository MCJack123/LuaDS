local expect = require "expect"
local RedBlackTree = require "RedBlackTree"

---@class OrderedMap: Map A key-value map which maintains key order.
---@field private _tree RedBlackTree
---@operator len: number
local OrderedMap = {}
OrderedMap.__mt = {__name = "OrderedMap"}

---@class KeyValuePair
---@field key Comparable
---@field value any
local KeyValuePair_mt = {__name = "KeyValuePair"}
local function KeyValuePair(k, v) return setmetatable({key = k, value = v}, KeyValuePair_mt) end
function KeyValuePair_mt.__eq(a, b) return a.key == b.key end
function KeyValuePair_mt.__lt(a, b) return a.key < b.key end
function KeyValuePair_mt.__le(a, b) return a.key <= b.key end

--- Creates a new map. (O(1), or O(n) amortized)
---@param tab? table A table of values to prefill the map with
---@return OrderedMap map The new map
function OrderedMap:new(tab)
    expect(1, tab, "table", "nil")
    local obj = setmetatable({_tree = RedBlackTree:new()}, self.__mt)
    if tab then
        for k, v in pairs(tab) do
            obj:set(k, v)
        end
    end
    return obj
end

--- Returns whether the map is empty. (O(1))
---@return boolean empty Whether the map is empty
function OrderedMap:isEmpty()
    return self._tree:isEmpty()
end

--- Returns the number of items in the map. (O(1))
---@return number length The number of items in the map
function OrderedMap:length()
    return self._tree:length()
end

--- Returns the value associated with a given key, or nil if not found. (O(log n))
---@param key Comparable The key to check
---@return any|nil value The value associated with the key
function OrderedMap:get(key)
    local v = self._tree:find(KeyValuePair(key, nil))
    if v then return v.value end
end

--- Assigns a key to a value, inserting it if it doesn't exist, or replacing the value if it does. (O(1) amortized, O(log n) worst)
---@param key Comparable The key to assign to
---@param value any The value to assign
function OrderedMap:set(key, value)
    if value == nil then self._tree:remove(KeyValuePair(key, value))
    else self._tree:insert(KeyValuePair(key, value)) end
end

--- Returns whether a given key exists in the map. (O(log n))
---@param key Comparable The key to check
---@return boolean found Whether the key exists
function OrderedMap:find(key)
    return self._tree:find(KeyValuePair(key, nil)) ~= nil
end

--- Returns a key-value iterator function for a for loop. (O(1))
---@return fun():Comparable|nil,any|nil iter The iterator function
function OrderedMap:enumerate()
    local fn, state, i = self._tree:enumerate()
    return function()
        local v
        i, v = fn(state, i)
        if v then return v.key, v.value end
    end
end

--- Returns a normal table with the contents of the map. (O(n))
---@return table table A table with the contents of the map
function OrderedMap:table()
    local t = {}
    for k, v in self:enumerate() do t[k] = v end
    return t
end

--- Returns a list (optionally of a List type) with pairs of key-value entries. (O(n))
---@param List? ListType The type of list to make (defaults to a normal table)
---@return table<{key:any,value:any}>|List pairs A list of key-value pairs in the table
function OrderedMap:pairs(List)
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

function OrderedMap.__mt:__index(key)
    if OrderedMap[key] then return OrderedMap[key] end
    return self:get(key)
end

function OrderedMap.__mt:__len()
    return self._tree:length()
end

function OrderedMap.__mt:__newindex(key, val)
    return self:set(key, val)
end

function OrderedMap.__mt:__pairs()
    return self:enumerate()
end

return OrderedMap
