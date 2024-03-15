local expect = require "expect"

---@class LLNode
---@field value any
---@field next LLNode|nil
---@field prev LLNode|nil

---@class LinkedList: List
---@field private _n number
---@field private _head LLNode
---@field private _tail LLNode
---@operator concat(LinkedList):LinkedList
---@operator len():number
local LinkedList = {}
LinkedList.__mt = {__name = "LinkedList"}

--- Creates a new LinkedList.
---@overload fun(): LinkedList
---@overload fun(arr: table): LinkedList
---@overload fun(val: any, count: number): LinkedList
---@param arr? table|any An array with preset values, or if count is provided, a value to repeat
---@param count? number If specified, fill the list with arr repeated this many times
---@return LinkedList list The new LinkedList
function LinkedList:new(arr, count)
    local obj = setmetatable({_n = 0}, self.__mt)
    if count then
        expect(2, count, "number")
        if count < 0 then return obj end
        local node = {value = arr}
        obj._head = node
        for _ = 2, count do
            local next = {value = arr, prev = node}
            node.next = next
            node = next
        end
        obj._tail = node
        obj._n = count
    elseif expect(1, arr, "table", "nil") then
        for _, v in ipairs(arr) do
            obj:append(v)
        end
    end
    return obj
end

--- Returns whether the list is empty.
---@return boolean empty Whether the list is empty
function LinkedList:isEmpty()
    return self.head == nil
end

--- Returns the number of items in the list.
---@return number length The number of items in the list
function LinkedList:length()
    return self._n
end

--- Returns the item at the front of the list, or nil if the list is empty.
---@return any front The front item
function LinkedList:front()
    return self._head and self._head.value
end

--- Returns the item at the back of the list, or nil if the list is empty.
---@return any back The back item
function LinkedList:back()
    return self._tail and self._tail.value
end

--- Appends an item at the back of the list.
---@param val any The value to add
function LinkedList:append(val)
    self._n = self._n + 1
    local node = {value = val, prev = self._tail}
    if self._tail then self._tail.next = node
    else self._head = node end
    self._tail = node
end

--- Removes the item at the back of the list, returning the value. Returns nil and does nothing if the list is empty.
---@return any|nil back The back item which was removed
function LinkedList:pop()
    if not self._tail then return nil end
    local node = self._tail
    self._tail = node.prev
    if self._tail then self._tail.next = nil
    else self._head = nil end
    self._n = self._n - 1
    return node.value
end

--- Inserts an item into the list at the specified position.
---@param val any The value to insert
---@param idx number The index to insert to; 1 <= idx <= list:length() + 1
function LinkedList:insert(val, idx)
    expect(2, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n + 1 then
        error("bad argument #2 (index out of range)", 2)
    end
    if idx == 1 then
        self._head = {value = val, next = self._head}
        if self._head.next then self._head.next.prev = self._head
        else self._tail = self._head end
        self._n = self._n + 1
        return
    end
    local node = self._head
    for _ = 3, idx do
        node = node.next
    end
    node.next = {value = val, prev = node, next = node.next}
    if node.next.next then node.next.next.prev = node.next
    else self._tail = node.next end
    self._n = self._n + 1
end

--- Removes an item at the specified position.
---@param idx number The index to remove at; 1 <= idx <= list:length()
---@return any item The value removed
function LinkedList:remove(idx)
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n then
        error("bad argument #1 (index out of range)", 2)
    end
    if idx == 1 then
        local node = self._head
        self._head = node.next
        if self._head then self._head.prev = nil
        else self._tail = nil end
        self._n = self._n - 1
        return node.value
    end
    local node = self._head
    for _ = 3, idx do
        node = node.next
        if not node then error("bad argument #1 (index out of range)", 2) end
    end
    local v = node.next.value
    node.next = node.next.next
    if node.next then node.next.prev = node
    else self._tail = node end
    self._n = self._n - 1
    return v
end

--- Returns the first index of the specified item, or nil if not present in the list.
---@param val any The value to look for
---@return number|nil index The index of the item, or nil if not present
function LinkedList:find(val)
    local node = self._head
    local i = 1
    while node ~= nil do
        if node.value == val then
            return i
        end
        node, i = node.next, i + 1
    end
    return nil
end

--- Removes a number of instances of the specified item from the list.
---@param val any The value to remove
---@param count? number The number of items to remove (defaults to all)
---@return number itemsRemoved The number of items removed
function LinkedList:removeItem(val, count)
    expect(2, count, "number", "nil")
    if count then
        count = math.floor(count)
        if count < 1 then return 0 end
    end
    local node = self._head
    local n = 0
    while node and node.value == val do
        self._head = self._head.next
        self._n = self._n - 1
        n = n + 1
        if count and n == count then return n end
        node = self._head
    end
    if not node then return n end
    while node and node.next do
        if node.next.value == val then
            node.next = node.next.next
            if node.next then node.next.prev = node
            else self._tail = node end
            self._n = self._n - 1
            n = n + 1
            if count and n == count then return n end
        else node = node.next end
    end
    return n
end

--- Returns a new LinkedList with only elements that match a predicate function.
---@param fn fun(any):boolean A function to be called on each item; returns whether the item should be included
---@return LinkedList filteredList The new filtered list
function LinkedList:filter(fn)
    expect(1, fn, "function")
    local retval = LinkedList:new()
    local node = self._head
    while node ~= nil do
        if fn(node.value) then
            retval:append(node.value)
        end
        node = node.next
    end
    return retval
end

--- Returns a new LinkedList where each item has been transformed by a function.
---@param fn fun(any):any A function to be called on each item; returns a new item
---@return LinkedList mappedList The new mapped list
function LinkedList:map(fn)
    expect(1, fn, "function")
    local retval = LinkedList:new()
    local node = self._head
    while node ~= nil do
        retval:append(fn(node.value))
        node = node.next
    end
    return retval
end

--- Returns a new LinkedList where each item has been transformed by a function; if the function returns nil, the item will not be included.
---@param fn fun(any):any|nil A function to be called on each item; returns the new item, or nil to remove
---@return LinkedList mappedList The new mapped list
function LinkedList:compactMap(fn)
    expect(1, fn, "function")
    local retval = LinkedList:new()
    local node = self._head
    while node ~= nil do
        local v = fn(node.value)
        if v ~= nil then
            retval:append(v)
        end
        node = node.next
    end
    return retval
end

local function LLnext(state, i)
    if state.node ~= nil then
        local node = state.node
        state.node = node.next
        return i + 1, node.value
    end
end

--- Returns an iterator function for a for loop.
---@return fun(LinkedList,number):number|nil,any _ The iterator function
---@return LinkedList self
---@return number 0
function LinkedList:enumerate()
    return LLnext, {node = self._head}, 0
end

--- Returns an array with the elements in thelist.
---@return any[] items The items in the list as an array
function LinkedList:array()
    local t = {}
    for i, v in self:enumerate() do t[i] = v end
    return t
end

function LinkedList.__mt.__concat(a, b)
    expect(1, a, "table")
    expect(2, b, "table")
    local retval = LinkedList:new()
    for _, v in a:enumerate() do retval:append(v) end
    for _, v in b:enumerate() do retval:append(v) end
    return retval
end

function LinkedList.__mt:__eq(other)
    if self._n ~= other._n then return false end
    local an, bn = self.head, other.head
    while an ~= nil do
        if an.value ~= bn.value then return false end
        an, bn = an.next, bn.next
    end
    return true
end

function LinkedList.__mt:__len()
    return self._n
end

function LinkedList.__mt:__index(idx)
    if LinkedList[idx] then return LinkedList[idx] end
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n then return nil end
    local node = self._head
    for _ = 2, idx do node = node.next end
    return node.value
end

function LinkedList.__mt:__newindex(idx, val)
    if idx == "_head" or idx == "_tail" then return rawset(self, idx, val) end
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n then error("index out of range", 2) end
    local node = self._head
    for _ = 2, idx do node = node.next end
    node.value = val
end

function LinkedList.__mt:__pairs()
    return self:enumerate()
end

return LinkedList