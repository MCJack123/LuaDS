local expect = require "expect"

---@class ArrayList: List
---@field private _n number
---@operator concat(ArrayList):ArrayList
---@operator len:number
local ArrayList = {}
ArrayList.__mt = {__name = "ArrayList", __index = ArrayList}

--- Creates a new ArrayList. (O(1) or O(n))
---@overload fun(): ArrayList
---@overload fun(arr: table): ArrayList
---@overload fun(val: any, count: number): ArrayList
---@param arr? table|any An array with preset values, or if count is provided, a value to repeat
---@param count? number If specified, fill the list with arr repeated this many times
---@return ArrayList list The new ArrayList
function ArrayList:new(arr, count)
    if count then
        expect(2, count, "number")
        local a = {}
        for i = 1, count do a[i] = arr end
        arr = a
    end
    expect(1, arr, "table", "nil")
    local obj = setmetatable(arr or {}, self.__mt)
    rawset(obj, "_n", count or (arr and #arr or 0))
    return obj
end

--- Returns whether the list is empty. (O(1))
---@return boolean empty Whether the list is empty
function ArrayList:isEmpty()
    return self._n == 0
end

--- Returns the number of items in the list. (O(1))
---@return number length The number of items in the list
function ArrayList:length()
    return self._n
end

--- Returns the item at the front of the list, or nil if the list is empty. (O(1))
---@return any front The front item
function ArrayList:front()
    return self[1]
end

--- Returns the item at the back of the list, or nil if the list is empty. (O(1))
---@return any back The back item
function ArrayList:back()
    return self[self._n]
end

--- Appends an item at the back of the list. (O(1))
---@param val any The value to add
function ArrayList:append(val)
    self._n = self._n + 1
    rawset(self, self._n, val)
end

--- Removes the item at the back of the list, returning the value. Returns nil and does nothing if the list is empty. (O(1))
---@return any|nil back The back item which was removed
function ArrayList:pop()
    if self._n == 0 then return nil end
    local v = self[self._n]
    self[self._n] = nil
    self._n = self._n - 1
    return v
end

--- Inserts an item into the list at the specified position. (O(n))
---@param val any The value to insert
---@param idx number The index to insert to; 1 <= idx <= list.n + 1
function ArrayList:insert(val, idx)
    expect(2, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n + 1 then
        error("bad argument #2 (index out of range)", 2)
    end
    for i = self._n, idx, -1 do
        rawset(self, i+1, self[i])
    end
    rawset(self, idx, val)
    self._n = self._n + 1
end

--- Removes an item at the specified position. (O(n))
---@param idx number The index to remove at; 1 <= idx <= list.n
---@return any item The value removed
function ArrayList:remove(idx)
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n then
        error("bad argument #1 (index out of range)", 2)
    end
    local v = self[idx]
    for i = self._n, idx, -1 do
        self[i] = self[i + 1]
    end
    self._n = self._n - 1
    return v
end

--- Returns the first index of the specified item, or nil if not present in the list. (O(n))
---@param val any The value to look for
---@return number|nil index The index of the item, or nil if not present
function ArrayList:find(val)
    for i = 1, self._n do
        if self[i] == val then
            return i
        end
    end
    return nil
end

--- Removes a number of instances of the specified item from the list. (O(n))
---@param val any The value to remove
---@param count? number The number of items to remove (defaults to all)
---@return number itemsRemoved The number of items removed
function ArrayList:removeItem(val, count)
    expect(2, count, "number", "nil")
    if count then
        count = math.floor(count)
        if count < 1 then return 0 end
    end
    local i = 1
    local n = 0
    while i <= self._n do
        if self[i] == val then
            self:remove(i)
            n = n + 1
            if count and n == count then return n end
        else i = i + 1 end
    end
    return n
end

--- Returns a new ArrayList with only elements that match a predicate function. (O(n))
---@param fn fun(any):boolean A function to be called on each item; returns whether the item should be included
---@return ArrayList filteredList The new filtered list
function ArrayList:filter(fn)
    expect(1, fn, "function")
    local retval = ArrayList:new()
    for i = 1, self._n do
        if fn(self[i]) then
            retval:append(self[i])
        end
    end
    return retval
end

--- Returns a new ArrayList where each item has been transformed by a function. (O(n))
---@param fn fun(any):any A function to be called on each item; returns a new item
---@return ArrayList mappedList The new mapped list
function ArrayList:map(fn)
    expect(1, fn, "function")
    local retval = {}
    for i = 1, self._n do
        retval[i] = fn(self[i])
    end
    return ArrayList:new(retval)
end

--- Returns a new ArrayList where each item has been transformed by a function; if the function returns nil, the item will not be included. (O(n))
---@param fn fun(any):any|nil A function to be called on each item; returns the new item, or nil to remove
---@return ArrayList mappedList The new mapped list
function ArrayList:compactMap(fn)
    expect(1, fn, "function")
    local retval = ArrayList:new()
    for i = 1, self._n do
        local v = fn(self[i])
        if v ~= nil then
            retval:append(self[i])
        end
    end
    return retval
end

local function ALnext(self, i)
    i = i + 1
    if i <= self._n then
        return i, self[i]
    end
end

--- Returns an iterator function for a for loop. (O(1))
---@return fun(ArrayList,number):number|nil,any _ The iterator function
---@return ArrayList self
---@return number 0
function ArrayList:enumerate()
    return ALnext, self, 0
end

--- Returns an array with the elements in the list. (O(n))
---@return any[] items The items in the list as an array
function ArrayList:array()
    local t = {}
    for i, v in self:enumerate() do t[i] = v end
    return t
end

function ArrayList.__mt.__concat(a, b)
    expect(1, a, "table")
    expect(2, b, "table")
    local retval = ArrayList:new()
    for _, v in a:enumerate() do retval:append(v) end
    for _, v in b:enumerate() do retval:append(v) end
    return retval
end

function ArrayList.__mt:__eq(other)
    if self._n ~= other._n then return false end
    for i = 1, self._n do
        if self[i] ~= other[i] then return false end
    end
    return true
end

function ArrayList.__mt:__len()
    return self._n
end

function ArrayList.__mt:__newindex(idx, val)
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self._n then error("index out of range", 2) end
    return rawset(self, idx, val)
end

function ArrayList.__mt:__pairs()
    return self:enumerate()
end

return ArrayList