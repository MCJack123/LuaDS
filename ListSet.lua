local expect = require "expect"

---@class ListSet: Set A set of values ordered by insertion time.
---@field private _len number
---@field private _next number
---@field private _order table<any, number>
---@field private _keys table<number, any>
---@operator len: number
---@operator add(Set): ListSet
---@operator sub(Set): ListSet
local ListSet = {}
ListSet.__mt = {__name = "ListSet", __index = ListSet}

--- Creates a new set. (O(1) or O(n))
---@param tab? table A list of values to prefill the set with
---@return ListSet set The new set
function ListSet:new(tab)
    expect(1, tab, "table", "nil")
    local obj = setmetatable({_len = 0, _next = 1, _order = {}, _keys = {}}, self.__mt)
    if tab then
        for _, k in pairs(tab) do
            obj._order[k] = obj._next
            obj._keys[obj._next] = k
            obj._next = obj._next + 1
        end
        obj._len = obj._next - 1
    end
    return obj
end

--- Returns whether the set is empty. (O(1))
---@return boolean empty Whether the set is empty
function ListSet:isEmpty()
    return self._len == 0
end

--- Returns the number of items in the set. (O(1))
---@return number length The number of items in the set
function ListSet:length()
    return self._len
end

--- Inserts a value into the set. (O(1))
---@param value any The value to insert
function ListSet:insert(value)
    if not self._order[value] then
        self._order[value] = self._next
        self._keys[self._next] = value
        self._next = self._next + 1
    end
end

--- Removes a value from the set. (O(1))
---@param value any The value to remove
function ListSet:remove(value)
    if self._order[value] then
        self._keys[self._order[value]] = nil
        self._order[value] = nil
    end
end

--- Returns whether a given value exists in the set. (O(1))
---@param value any The value to check
---@return boolean found Whether the value exists
function ListSet:find(value)
    return self._order[value] ~= nil
end

--- Returns a new set which only contains items in both sets. (O(n log m))
---@param other Set The other set to operate on
---@return ListSet intersection The intersection of the two sets
function ListSet:intersection(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if other:find(v) then s:insert(v) end
    end
    return s
end

--- Returns a new set which contains items in either set. (O(n*m) amortized, O(n*m log n log m) worst)
---@param other Set The other set to operate on
---@return ListSet union The union of the two sets
function ListSet:union(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do s:insert(v) end
    for _, v in other:enumerate() do s:insert(v) end
    return s
end

--- Returns a new set which contains all items in this set, except for ones in the other set. (O(n log m))
---@param other Set The other set to operate on
---@return ListSet difference The difference of the two sets
function ListSet:difference(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if not other:find(v) then s:insert(v) end
    end
    return s
end

local function LSnext(state, i)
    state.i = state.i + 1
    while state.self._keys[state.i] == nil do
        if state.i >= state.self._next then return nil end
        state.i = state.i + 1
    end
    return i + 1, state.self._keys[state.i]
end

--- Returns a key-value iterator function for a for loop. (O(1))
---@return fun():any|nil,any|nil iter The iterator function
---@return table state The iterator state
---@return number i The iterator variant
function ListSet:enumerate()
    return LSnext, {self = self, i = 0}, 0
end

--- Returns an array table or List type with the contents of the set.
---@param List? ListType If provided, use this type of list as output
---@return table|List table A table with the contents of the set
function ListSet:array(List)
    if List then
        local t = List:new()
        for _, v in self:enumerate() do t:append(v) end
        return t
    else
        local t = {}
        for i, v in self:enumerate() do t[i] = v end
        return t
    end
end

function ListSet.__mt:__len()
    return self:length()
end

function ListSet.__mt:__pairs()
    return self:enumerate()
end

function ListSet.__mt:__add(other)
    return self:union(other)
end

function ListSet.__mt:__sub(other)
    return self:difference(other)
end

return ListSet
