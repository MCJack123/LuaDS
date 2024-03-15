local expect = require "expect"
local RedBlackTree = require "RedBlackTree"

---@class Map A key-value map which maintains key order.
---@field private _tree RedBlackTree
local Map = {}
Map.__mt = {__name = "Map"}

---@class KeyValuePair
---@field key Comparable
---@field value any
local KeyValuePair_mt = {__name = "KeyValuePair"}
local function KeyValuePair(k, v) return setmetatable({key = k, value = v}, KeyValuePair_mt) end
function KeyValuePair_mt.__eq(a, b) return a.key == b.key end
function KeyValuePair_mt.__lt(a, b) return a.key < b.key end
function KeyValuePair_mt.__le(a, b) return a.key <= b.key end

--- Creates a new map.
---@param tab? table A table of values to prefill the map with
---@return Map map The new map
function Map:new(tab)
    expect(1, tab, "table", "nil")
    local obj = setmetatable({_tree = RedBlackTree:new()}, self.__mt)
    if tab then
        for k, v in pairs(tab) do
            obj:set(k, v)
        end
    end
    return obj
end

--- Returns whether the map is empty.
---@return boolean empty Whether the map is empty
function Map:isEmpty()
    return self._tree:isEmpty()
end

--- Returns the number of items in the map.
---@return number length The number of items in the map
function Map:length()
    return self._tree:length()
end

--- Returns the value associated with a given key, or nil if not found.
---@param key Comparable The key to check
---@return any|nil value The value associated with the key
function Map:get(key)
    local v = self._tree:find(KeyValuePair(key, nil))
    if v then return v.value end
end

--- Assigns a key to a value, inserting it if it doesn't exist, or replacing the value if it does.
---@param key Comparable The key to assign to
---@param value any The value to assign
function Map:set(key, value)
    if value == nil then self._tree:remove(KeyValuePair(key, value))
    else self._tree:insert(KeyValuePair(key, value)) end
end

--- Returns whether a given key exists in the map
---@param key Comparable The key to check
---@return boolean found Whether the key exists
function Map:find(key)
    return self._tree:find(KeyValuePair(key, nil)) ~= nil
end

--- Returns a key-value iterator function for a for loop.
---@return fun():Comparable|nil,any|nil iter The iterator function
function Map:enumerate()
    local fn, state, i = self._tree:enumerate()
    return function()
        local v
        i, v = fn(state, i)
        if v then return v.key, v.value end
    end
end

--- Returns a normal table with the contents of the map.
---@return table A table with the contents of the map
function Map:table()
    local t = {}
    for k, v in self:enumerate() do t[k] = v end
    return t
end

function Map.__mt:__index(key)
    if Map[key] then return Map[key] end
    return self:get(key)
end

function Map.__mt:__len()
    return self._tree:length()
end

function Map.__mt:__newindex(key, val)
    return self:set(key, val)
end

function Map.__mt:__pairs()
    return self:enumerate()
end

return Map
