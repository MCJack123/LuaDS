local expect = require "expect"
local BST = require "BST"

---@class RedBlackTree: BST
---@field left RedBlackTree|nil
---@field right RedBlackTree|nil
---@field parent RedBlackTree|nil
---@field red boolean
---@operator len: number
local RedBlackTree = setmetatable({}, {__index = BST})
RedBlackTree.__mt = {__name = "RedBlackTree", __index = RedBlackTree}

--- Creates a new red-black tree, optionally from a list of values.
---@param values? List|table A list of items to insert into the tree
---@param i? number The index in the list to start at (defaults to 1)
---@param j? number The index in the list to stop at (defaults to #values)
---@return RedBlackTree tree The new red-black tree
function RedBlackTree:new(values, i, j)
    expect(1, values, "table", "nil")
    local obj = setmetatable({red = false}, self.__mt)
    if values then
        i = expect(2, i, "number", "nil") or 1
        j = expect(3, j, "number", "nil") or #values
        obj.value = values[i]
        for n = i + 1, j do obj:insert(values[n]) end
    end
    return obj
end

--- Inserts a new item into the red-black tree.
---@param val Comparable The value to add
function RedBlackTree:insert(val)
    if self.value == nil then
        self.value = val
        self.red = false
    elseif val < self.value then
        if self.left then return self.left:insert(val)
        else
            self.left = self:new{val}
            self.left.parent = self
            self.left.red = true
            self.left:balance()
        end
    elseif val > self.value then
        if self.right then return self.right:insert(val)
        else
            self.right = self:new{val}
            self.right.parent = self
            self.right.red = true
            self.right:balance()
        end
    else self.value = val end
end

---@private
function RedBlackTree:prepareRemove()
    if self.red or not self.parent then return end
    local sibling
    if self.parent.left == self then sibling = self.parent.right
    else sibling = self.parent.left end
    if sibling and sibling.red then
        self.parent.red = true
        sibling.red = false
        if self.parent.left == self then self.parent:rotateLeft()
        else self.parent:rotateRight() end
        if self.parent.left == self then sibling = self.parent.right
        else sibling = self.parent.left end
    end
    if sibling and not (sibling.left and sibling.left.red) and not (sibling.right and sibling.right.red) then
        sibling.red = true
        if self.parent.red then
            self.parent.red = false
            return
        else
            return self.parent:prepareRemove()
        end
    end
    if sibling and sibling.left and sibling.left.red and not (sibling.right and sibling.right.red) and self.parent.left == self then
        sibling.red = true
        sibling.left.red = false
        sibling:rotateRight()
        if self.parent.left == self then sibling = self.parent.right
        else sibling = self.parent.left end
    end
    if sibling and not (sibling.left and sibling.left.red) and sibling.right and sibling.right.red and self.parent.right == self then
        sibling.red = true
        sibling.right.red = false
        sibling:rotateLeft()
        if self.parent.left == self then sibling = self.parent.right
        else sibling = self.parent.left end
    end
    if sibling then sibling.red = self.parent.red end
    self.parent.red = false
    if self == self.parent.left then
        if sibling and sibling.right then sibling.right.red = false end
        self.parent:rotateLeft()
    else
        if sibling and sibling.left then sibling.left.red = false end
        self.parent:rotateRight()
    end
end

--- Removes an item from the red-black tree.
---@param val Comparable The value to remove
function RedBlackTree:remove(val)
    if self.value == nil then return
    elseif val == self.value then
        if self.left and self.right then
            local rep = self.right
            ---@diagnostic disable: need-check-nil
            while rep.left do rep = rep.left end
            self.value = rep.value
            return self.right:remove(rep.value)
            ---@diagnostic enable: need-check-nil
        end
        if not self.red then self:prepareRemove() end
        self.value = nil
        local rep = nil
        if self.left then rep = self.left
        elseif self.right then rep = self.right end
        if self.parent then
            if self == self.parent.left then self.parent.left = rep
            else self.parent.right = rep end
        end
    elseif val < self.value and self.left then return self.left:remove(val)
    elseif val > self.value and self.right then return self.right:remove(val) end
end

---@private
function RedBlackTree:rotateRight()
    if self.parent then
        local lrc = self.left.right
        if self.parent.left == self then self.parent.left = self.left
        else self.parent.right = self.left end
        self.left.parent = self.parent
        self.left.right = self
        self.parent = self.left
        self.left = lrc
        if lrc then lrc.parent = self end
    else
        self.value, self.left.value = self.left.value, self.value
        self.left, self.left.left, self.left.right, self.right = self.left.left, self.left.right, self.right, self.left
        if self.left then
            self.left.parent = self
            if self.left.right then self.left.right.parent = self.left end
        end
    end
end

---@private
function RedBlackTree:rotateLeft()
    if self.parent then
        local rlc = self.right.left
        if self.parent.right == self then self.parent.right = self.right
        else self.parent.left = self.right end
        self.right.parent = self.parent
        self.right.left = self
        self.parent = self.right
        self.right = rlc
        if rlc then rlc.parent = self end
    else
        self.value, self.right.value = self.right.value, self.value
        self.red, self.right.red = self.right.red, self.red
        self.right, self.right.right, self.right.left, self.left = self.right.right, self.right.left, self.left, self.right
        if self.right then
            self.right.parent = self
            if self.right.left then self.right.left.parent = self.right end
        end
    end
end

--- Balances the subtree to be a valid red-black tree.
---@protected
function RedBlackTree:balance()
    local parent = self.parent
    local grandparent = self.parent and self.parent.parent
    local uncle
    if grandparent then
        if grandparent.left == parent then uncle = grandparent.right
        else uncle = grandparent.left end
    end
    if not parent then
        self.red = false
        return
    end
    if not parent.red then
        return
    end
    if parent.red and uncle and uncle.red then
        parent.red = false
        uncle.red = false
        grandparent.red = true
        grandparent:balance() ---@diagnostic disable-line: need-check-nil
        return
    end
    if self == parent.right and grandparent and parent == grandparent.left then
        parent:rotateLeft()
        self = parent
        parent = self.parent ---@cast parent RedBlackTree
    elseif self == parent.left and grandparent and parent == grandparent.right then
        parent:rotateRight()
        self = parent
        parent = self.parent ---@cast parent RedBlackTree
    end
    parent.red = false
    if grandparent then
        grandparent.red = true
        if self == parent.left then grandparent:rotateRight()
        else grandparent:rotateLeft() end
    end
end

---@private
function RedBlackTree:blackNodes()
    local lbn = self.left and self.left:blackNodes() or 1
    local rbn = self.right and self.right:blackNodes() or 1
    if lbn ~= rbn then error("Unbalanced black nodes") end
    return lbn
end

---@private
function RedBlackTree:validate()
    if not self.parent and self.red then error("Root is red") end
    if self.red and ((self.left and self.left.red) or (self.right and self.right.red)) then error("Child of red node is red") end
    if self.left then self.left:validate() end
    if self.right then self.right:validate() end
    self:blackNodes()
end

function RedBlackTree.__mt:__len()
    return self:length()
end

function RedBlackTree.__mt:__pairs()
    return self:enumerate()
end

return RedBlackTree
