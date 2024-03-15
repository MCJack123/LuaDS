local expect = require "expect"

---@alias Comparable number|string|table A type that can be compared with < or `__lt`

---@class BST A binary search tree.
---@field value Comparable|nil The value of the current node.
---@field left BST|nil The left subtree.
---@field right BST|nil The right subtree.
---@field parent BST|nil The parent tree.
local BST = {}
BST.__mt = {__name = "BST", __index = BST}

--- Creates a new binary search tree, optionally from a sorted list of values.
---@param values? List|table A list of items to insert into the tree - must be sorted!
---@param i? number The index in the list to start at (defaults to 1)
---@param j? number The index in the list to stop at (defaults to #values)
---@return BST tree The new binary search tree
function BST:new(values, i, j)
    expect(1, values, "table", "nil")
    local obj = setmetatable({}, self.__mt)
    if values then
        i = expect(2, i, "number", "nil") or 1
        j = expect(3, j, "number", "nil") or #values
        for n = i, j - 1 do if values[n] > values[n+1] then error("bad argument #1 (table must be sorted)", 2) end end
        if j >= i then
            local center = math.floor((j - i) / 2) + i
            obj.value = values[center]
            if center - 1 >= i then
                obj.left = self:new(values, i, center - 1)
                obj.left.parent = obj
            end
            if center + 1 <= j then
                obj.right = self:new(values, center + 1, j)
                obj.right.parent = obj
            end
        end
    end
    return obj
end

--- Returns whether the tree is empty.
---@return boolean empty Whether the tree is empty
function BST:isEmpty()
    return self.value == nil
end

--- Returns the number of items in the tree.
---@return number length The number of items in the tree
function BST:length()
    if self.value == nil then return 0 end
    return (self.left and self.left:length() or 0) + (self.right and self.right:length() or 0) + 1
end

--- Searches for the specified value in the tree.
---@param val Comparable The value to look for
---@return any|nil item The item that was found, or nil otherwise
function BST:find(val)
    if self.value == nil then return nil end
    if val == self.value then return self.value
    elseif val < self.value and self.left then return self.left:find(val)
    elseif val > self.value and self.right then return self.right:find(val)
    else return nil end
end

--- Inserts a new item into the binary search tree.
---@param val Comparable The value to add
function BST:insert(val)
    if self.value == nil then
        self.value = val
    elseif val < self.value then
        if self.left then return self.left:insert(val)
        else
            self.left = self:new{val}
            self.left.parent = self
        end
    elseif val > self.value then
        if self.right then return self.right:insert(val)
        else
            self.right = self:new{val}
            self.right.parent = self
        end
    else self.value = val end
end

--- Removes an item from the binary search tree.
---@param val Comparable The value to remove
function BST:remove(val)
    if self.value == nil then return
    elseif val == self.value then
        self.value = nil
        local rep = nil
        if self.left and self.right then
            rep = self.right
            ---@diagnostic disable: need-check-nil
            while rep.left do rep = rep.left end
            self.value = rep.value
            return self.right:remove(rep.value)
            ---@diagnostic enable: need-check-nil
        elseif self.left then rep = self.left
        elseif self.right then rep = self.right end
        if self.parent then
            if self == self.parent.left then self.parent.left = rep
            else self.parent.right = rep end
        end
    elseif val < self.value and self.left then return self.left:remove(val)
    elseif val > self.value and self.right then return self.right:remove(val) end
end

--- Returns the height of the tree.
---@return number height The height of the tree
function BST:height()
    return math.max(self.left and self.left:height() + 1 or 0, self.right and self.right:height() + 1 or 0)
end

local function BSTiter(tree, n)
    if not tree then return n end
    n = BSTiter(tree.left, n)
    coroutine.yield(n + 1, tree.value)
    return BSTiter(tree.right, n + 1)
end

--- Iterates through the tree in order.
---@return fun(table,number):number,Comparable iter The iterator
function BST:enumerate()
    return coroutine.wrap(function() BSTiter(self, 0) return nil end)
end

--- Returns an array with the elements in the tree.
---@return any[] items The items in the tree as an array
function BST:array()
    local t = {}
    for i, v in self:enumerate() do t[i] = v end
    return t
end

function BST.__mt:__len()
    return self:length()
end

function BST.__mt:__pairs()
    return self:enumerate()
end

return BST
