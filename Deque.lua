local expect = require "expect"

---@class Deque: List
---@field private _n number
---@field private _start number
---@operator concat(Deque):Deque
---@operator len():number
local Deque = {}
local Deque_mt = {__index = Deque}

--- Creates a new Deque.
---@param arr table|any|nil An array with preset values, or if count is provided, a value to repeat
---@param count number|nil If specified, fill the list with arr repeated this many times
---@return Deque list The new Deque
function Deque:new(arr, count)
    if count then
        expect(2, count, "number")
        local a = {}
        for i = 1, count do a[i] = arr end
        arr = a
    end
    expect(1, arr, "table", "nil")
    local obj = setmetatable(arr or {}, Deque_mt)
    obj._n = count or #obj
    obj._start = 0
    return obj
end

--- Returns whether the list is empty.
---@return boolean empty Whether the list is empty
function Deque:isEmpty()
    return self._n == 0
end

--- Returns the number of items in the list.
---@return number length The number of items in the list
function Deque:length()
    return self._n
end

--- Returns the item at the front of the list, or nil if the list is empty.
---@return any front The front item
function Deque:front()
    return self[self._start+1]
end

--- Returns the item at the back of the list, or nil if the list is empty.
---@return any back The back item
function Deque:back()
    return self[self._start+self._n]
end

--- Appends an item at the back of the list.
---@param val any The value to add
function Deque:append(val)
    self._n = self._n + 1
    rawset(self, self._start+self._n, val)
end

--- Removes the item at the back of the list, returning the value. Returns nil and does nothing if the list is empty.
---@return any|nil back The back item which was removed
function Deque:pop()
    if self._n == 0 then return nil end
    local v = self[self._start+self._n]
    self[self._start+self._n] = nil
    self._n = self._n - 1
    return v
end

--- Inserts an item into the list at the specified position.
---@param val any The value to insert
---@param idx number The index to insert to; 1 <= idx <= list.n + 1
function Deque:insert(val, idx)
    expect(2, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n + 1 then
        error("bad argument #2 (index out of range)", 2)
    end
    if idx == 1 then
        rawset(self, self._start, val)
        self._start = self._start - 1
    else
        for i = self._start+self._n, self._start+idx, -1 do
            rawset(self, i+1, self[i])
        end
        rawset(self, self._start+idx, val)
    end
    self._n = self._n + 1
end

--- Removes an item at the specified position.
---@param idx number The index to remove at; 1 <= idx <= list.n
---@return any item The value removed
function Deque:remove(idx)
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n then
        error("bad argument #1 (index out of range)", 2)
    end
    local v = self[self._start+idx]
    for i = self._start+self._n, self._start+idx, -1 do
        self[i] = self[i + 1]
    end
    self._n = self._n - 1
    return v
end

--- Returns the first index of the specified item, or nil if not present in the list.
---@param val any The value to look for
---@return number|nil index The index of the item, or nil if not present
function Deque:find(val)
    for i = self._start+1, self._start+self._n do
        if self[i] == val then
            return i
        end
    end
    return nil
end

--- Removes a number of instances of the specified item from the list.
---@param val any The value to remove
---@param count number|nil The number of items to remove (defaults to all)
---@return number itemsRemoved The number of items removed
function Deque:removeItem(val, count)
    expect(2, count, "number", "nil")
    if count then
        count = math.floor(count)
        if count < 1 then return 0 end
    end
    local i = 1
    local n = 0
    while i <= self._n do
        if self[self._start+i] == val then
            self:remove(i)
            n = n + 1
            if count and n == count then return n end
        else i = i + 1 end
    end
    return n
end

--- Returns a new Deque with only elements that match a predicate function.
---@param fn fun(any):boolean A function to be called on each item; returns whether the item should be included
---@return Deque filteredList The new filtered list
function Deque:filter(fn)
    expect(1, fn, "function")
    local retval = Deque:new()
    for i = self._start+1, self._start+self._n do
        if fn(self[i]) then
            retval:append(self[i])
        end
    end
    return retval
end

--- Returns a new Deque where each item has been transformed by a function.
---@param fn fun(any):any A function to be called on each item; returns a new item
---@return Deque mappedList The new mapped list
function Deque:map(fn)
    expect(1, fn, "function")
    local retval = {}
    for i = self._start+1, self._start+self._n do
        retval[i] = fn(self[i])
    end
    return Deque:new(retval)
end

--- Returns a new Deque where each item has been transformed by a function; if the function returns nil, the item will not be included.
---@param fn fun(any):any|nil A function to be called on each item; returns the new item, or nil to remove
---@return Deque mappedList The new mapped list
function Deque:compactMap(fn)
    expect(1, fn, "function")
    local retval = Deque:new()
    for i = self._start+1, self._start+self._n do
        local v = fn(self[i])
        if v ~= nil then
            retval:append(self[i])
        end
    end
    return retval
end

local function DQnext(self, i)
    i = i + 1
    if i <= self._n then
        return i, self[self._start+i]
    end
end

--- Returns an iterator function for a for loop.
---@return fun(Deque,number):number|nil,any _ The iterator function
---@return Deque self
---@return number 0
function Deque:enumerate()
    return DQnext, self, 0
end

function Deque_mt.__concat(a, b)
    expect(1, a, "table")
    expect(2, b, "table")
    local retval = Deque:new()
    for _, v in a:enumerate() do retval:append(v) end
    for _, v in b:enumerate() do retval:append(v) end
    return retval
end

function Deque_mt:__len()
    return self._n
end

function Deque_mt:__newindex(idx, val)
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n then error("index out of range", 2) end
    return rawset(self, idx, val)
end

return Deque