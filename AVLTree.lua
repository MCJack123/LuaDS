local expect = require "expect"
local BST = require "BST"

---@class AVLTree: BST
---@operator len: number
local AVLTree = setmetatable({}, {__index = BST})
AVLTree.__mt = {__name = "AVLTree", __index = AVLTree}

--- Creates a new AVL tree, optionally from a sorted list of values. (O(1) or O(n))
---@param values? List|table A list of items to insert into the tree - must be sorted!
---@param i? number The index in the list to start at (defaults to 1)
---@param j? number The index in the list to stop at (defaults to #values)
---@return AVLTree tree The new AVL tree
function AVLTree:new(values, i, j)
    local obj = setmetatable(BST.new(self, values, i, j), self.__mt) ---@cast obj AVLTree
    obj:rebalance()
    return obj
end

--- Inserts a new item into the AVL tree. (O(log n))
---@param val Comparable The value to add
function AVLTree:insert(val)
    BST.insert(self, val)
    self:rebalance()
end

--- Removes an item from the AVL tree. (O(log n))
---@param val Comparable The value to remove
function AVLTree:remove(val)
    BST.remove(self, val)
    self:rebalance()
end

---@private
function AVLTree:rotateRight()
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
function AVLTree:rotateLeft()
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
        self.right, self.right.right, self.right.left, self.left = self.right.right, self.right.left, self.left, self.right
        if self.right then
            self.right.parent = self
            if self.right.left then self.right.left.parent = self.right end
        end
    end
end

---@private
function AVLTree:balanceFactor()
    local lh = self.left and self.left:height() or -1
    local rh = self.right and self.right:height() or -1
    return lh - rh
end

--- Rebalances the tree to be a valid AVL tree.
---@protected
function AVLTree:rebalance()
    local bf = self:balanceFactor()
    if bf == -2 then
        if self.right and self.right:balanceFactor() == 1 then
            self.right:rotateRight()
        end
        self:rotateLeft()
    elseif bf == 2 then
        if self.left and self.left:balanceFactor() == 1 then
            self.left:rotateLeft()
        end
        self:rotateRight()
    end
    assert(math.abs(self:balanceFactor()) < 2)
end

function AVLTree.__mt:__len()
    return self:length()
end

function AVLTree.__mt:__pairs()
    return self:enumerate()
end

return AVLTree
