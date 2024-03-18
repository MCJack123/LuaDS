local expect = require "expect"

---@class ListMap: Map A key-value map which orders entries by insertion order.
---@field private _len number
---@field private _next number
---@field private _order table<any, number>
---@field private _entries table<number, any>
---@field private _keys table<number, any>
---@operator len: number
local ListMap = {}
ListMap.__mt = {__name = "ListMap"}

--- Creates a new list map.
---@param tab? table A table of values to prefill the map with
---@return ListMap map The new map
function ListMap:new(tab)
    expect(1, tab, "table", "nil")
    local obj = setmetatable({_len = 0, _next = 1, _order = {}, _entries = {}, _keys = {}}, self.__mt)
    if tab then
        for k, v in pairs(tab) do
            obj._order[k] = obj._next
            obj._keys[obj._next] = k
            obj._entries[obj._next] = v
            obj._next = obj._next + 1
        end
        obj._len = obj._next - 1
    end
    return obj
end

--- Returns whether the map is empty.
---@return boolean empty Whether the map is empty
function ListMap:isEmpty()
    return self._len == 0
end

--- Returns the number of items in the map.
---@return number length The number of items in the map
function ListMap:length()
    return self._len
end

--- Returns the value associated with a given key, or nil if not found.
---@param key any The key to check
---@return any|nil value The value associated with the key
function ListMap:get(key)
    local i = self._order[key]
    if not i then return nil end
    return self._entries[i]
end

--- Assigns a key to a value, inserting it if it doesn't exist, or replacing the value if it does.
---@param key any The key to assign to
---@param value any The value to assign
function ListMap:set(key, value)
    local i = self._order[key]
    if value == nil then
        if not i then return end
        self._entries[i], self._keys[i], self._order[key] = nil, nil, nil
        self._len = self._len - 1
    else
        if i then
            self._entries[i] = value
        else
            i = self._next
            self._next = self._next + 1
            self._order[key] = i
            self._keys[i] = key
            self._entries[i] = value
            self._len = self._len + 1
        end
    end
end

--- Returns whether a given key exists in the map
---@param key any The key to check
---@return boolean found Whether the key exists
function ListMap:find(key)
    return self._order[key] ~= nil
end

local function LMnext(state, i)
    state.i = state.i + 1
    while state.self._entries[state.i] == nil do
        if state.i >= state.self._next then return nil end
        state.i = state.i + 1
    end
    return state.self._keys[state.i], state.self._entries[state.i]
end

--- Returns a key-value iterator function for a for loop.
---@return fun():any|nil,any|nil iter The iterator function
---@return table state The iterator state
function ListMap:enumerate()
    return LMnext, {self = self, i = 0}
end

--- Returns a normal table with the contents of the map.
---@return table table A table with the contents of the map
function ListMap:table()
    local t = {}
    for k, i in pairs(self._order) do
        t[k] = self._entries[i]
    end
    return t
end

--- Returns a list (optionally of a List type) with pairs of key-value entries.
---@param List? ListType The type of list to make (defaults to a normal table)
---@return table<{key:any,value:any}>|List pairs A list of key-value pairs in the table
function ListMap:pairs(List)
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

function ListMap.__mt:__index(key)
    if ListMap[key] then return ListMap[key] end
    return self:get(key)
end

function ListMap.__mt:__len()
    return self._len
end

function ListMap.__mt:__newindex(key, val)
    return self:set(key, val)
end

function ListMap.__mt:__pairs()
    return self:enumerate()
end

return ListMap
