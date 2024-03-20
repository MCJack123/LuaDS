local expect = require "expect"

---@class UnorderedSet: Set A set of values with no order.
---@field private _len number
---@field private _set table<any, boolean>
---@operator len: number
---@operator add(Set): UnorderedSet
---@operator sub(Set): UnorderedSet
local UnorderedSet = {}
UnorderedSet.__mt = {__name = "UnorderedSet", __index = UnorderedSet}

--- Creates a new set.
---@param tab? table A list of values to prefill the set with
---@return UnorderedSet set The new set
function UnorderedSet:new(tab)
    expect(1, tab, "table", "nil")
    local obj = setmetatable({_set = {}, _len = 0}, self.__mt)
    if tab then
        for _, v in pairs(tab) do
            obj._set[v] = true
            obj._len = obj._len + 1
        end
    end
    return obj
end

--- Returns whether the set is empty.
---@return boolean empty Whether the set is empty
function UnorderedSet:isEmpty()
    return self._len == 0
end

--- Returns the number of items in the set.
---@return number length The number of items in the set
function UnorderedSet:length()
    return self._len
end

--- Inserts a value into the set.
---@param value any The value to insert
function UnorderedSet:insert(value)
    if not self._set[value] then
        self._set[value] = true
        self._len = self._len + 1
    end
end

--- Removes a value from the set.
---@param value any The value to remove
function UnorderedSet:remove(value)
    if self._set[value] then
        self._set[value] = nil
        self._len = self._len - 1
    end
end

--- Returns whether a given value exists in the set.
---@param value any The value to check
---@return boolean found Whether the value exists
function UnorderedSet:find(value)
    return self._set[value] or false
end

--- Returns a new set which only contains items in both sets. (O(n log m))
---@param other Set The other set to operate on
---@return UnorderedSet intersection The intersection of the two sets
function UnorderedSet:intersection(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if other:find(v) then s:insert(v) end
    end
    return s
end

--- Returns a new set which contains items in either set. (O(n*m) amortized, O(n*m log n log m) worst)
---@param other Set The other set to operate on
---@return UnorderedSet union The union of the two sets
function UnorderedSet:union(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do s:insert(v) end
    for _, v in other:enumerate() do s:insert(v) end
    return s
end

--- Returns a new set which contains all items in this set, except for ones in the other set. (O(n log m))
---@param other Set The other set to operate on
---@return UnorderedSet difference The difference of the two sets
function UnorderedSet:difference(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if not other:find(v) then s:insert(v) end
    end
    return s
end

local function USnext(state, i)
    state.k = next(state.set, state.k)
    if state.k ~= nil then return i + 1, state.k end
end

--- Returns an index-value iterator function for a for loop.
---@return fun():number|nil,any|nil iter The iterator function
---@return table state The iterator state
---@return number i The iterator variant
function UnorderedSet:enumerate()
    return USnext, {set = self._set, k = nil}, 0
end

--- Returns an array table or List type with the contents of the set.
---@param List? ListType If provided, use this type of list as output
---@return table|List table A table with the contents of the set
function UnorderedSet:array(List)
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

function UnorderedSet.__mt:__len()
    return self:length()
end

function UnorderedSet.__mt:__pairs()
    return self:enumerate()
end

function UnorderedSet.__mt:__add(other)
    return self:union(other)
end

function UnorderedSet.__mt:__sub(other)
    return self:difference(other)
end

return UnorderedSet
