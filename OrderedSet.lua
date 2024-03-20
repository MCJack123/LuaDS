local expect = require "expect"
local RedBlackTree = require "RedBlackTree"

---@class OrderedSet: RedBlackTree, Set A set of values ordered by value.
---@field private _tree RedBlackTree
---@operator len: number
---@operator add(Set): OrderedSet
---@operator sub(Set): OrderedSet
local OrderedSet = setmetatable({}, {__index = RedBlackTree})
OrderedSet.__mt = {__name = "OrderedSet", __index = OrderedSet}

--- Creates a new set. (O(1) or O(n))
---@param tab? table A list of values to prefill the set with
---@return OrderedSet set The new set
function OrderedSet:new(tab)
    local obj = RedBlackTree.new(self, tab) ---@cast obj OrderedSet
    return obj
end

--- Returns a new set which only contains items in both sets. (O(n log m))
---@param other Set The other set to operate on
---@return OrderedSet intersection The intersection of the two sets
function OrderedSet:intersection(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if other:find(v) then s:insert(v) end
    end
    return s
end

--- Returns a new set which contains items in either set. (O(n*m) amortized, O(n*m log n log m) worst)
---@param other Set The other set to operate on
---@return OrderedSet union The union of the two sets
function OrderedSet:union(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do s:insert(v) end
    for _, v in other:enumerate() do s:insert(v) end
    return s
end

--- Returns a new set which contains all items in this set, except for ones in the other set. (O(n log m))
---@param other Set The other set to operate on
---@return OrderedSet difference The difference of the two sets
function OrderedSet:difference(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if not other:find(v) then s:insert(v) end
    end
    return s
end

function OrderedSet.__mt:__len()
    return self:length()
end

function OrderedSet.__mt:__pairs()
    return self:enumerate()
end

function OrderedSet.__mt:__add(other)
    return self:union(other)
end

function OrderedSet.__mt:__sub(other)
    return self:difference(other)
end

return OrderedSet
