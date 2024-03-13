local expect = require "expect"

---@class ArrayList
---@field length number
local ArrayList = {}
local ArrayList_mt = {__index = ArrayList}

--- Creates a new ArrayList.
---@param arr table|any|nil An array with preset values, or if count is provided, a value to repeat
---@param count number|nil If specified, fill the list with arr repeated this many times
---@return ArrayList The new ArrayList
function ArrayList:new(arr, count)
    if count then
        expect(2, count, "number")
        local a = {}
        for i = 1, count do a[i] = arr end
        arr = a
    end
    expect(1, arr, "table", "nil")
    local obj = setmetatable(arr or {}, ArrayList_mt)
    obj.length = count or #obj
    return obj
end

--- Returns whether the list is empty.
---@return boolean Whether the list is empty
function ArrayList:isEmpty()
    return self.length == 0
end

--- Returns the item at the front of the list, or nil if the list is empty.
---@return any The front item
function ArrayList:front()
    return self[1]
end

--- Returns the item at the back of the list, or nil if the list is empty.
---@return any The back item
function ArrayList:back()
    return self[self.length]
end

--- Appends an item at the back of the list.
---@param val any The value to add
function ArrayList:append(val)
    self.length = self.length + 1
    self[self.length] = val
end

--- Removes the item at the back of the list, returning the value. Returns nil and does nothing if the list is empty.
---@return any|nil The back item which was removed
function ArrayList:pop()
    if self.length == 0 then return nil end
    local v = self[self.length]
    self[self.length] = nil
    self.length = self.length - 1
    return v
end

--- Inserts an item into the list at the specified position.
---@param val any The value to insert
---@param idx number The index to insert to; 1 <= idx <= list.length + 1
function ArrayList:insert(val, idx)
    expect(2, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self.length + 1 then
        error("bad argument #2 (index out of range)", 2)
    end
    for i = self.length, idx, -1 do
        self[i+1] = self[i]
    end
    self[idx] = val
    self.length = self.length + 1
end

--- Removes an item at the specified position.
---@param idx number The index to remove at; 1 <= idx <= list.length
---@return any The value removed
function ArrayList:remove(idx)
    expect(1, idx, "number")
    idx = math.floor(idx)
    if idx < 1 or idx > self.length then
        error("bad argument #1 (index out of range)", 2)
    end
    local v = self[idx]
    for i = self.length, idx, -1 do
        self[i] = self[i + 1]
    end
    self.length = self.length - 1
    return v
end

--- Returns the first index of the specified item, or nil if not present in the list.
---@param val any The value to look for
---@return number|nil The index of the item, or nil if not present
function ArrayList:find(val)
    for i = 1, self.length do
        if self[i] == val then
            return i
        end
    end
    return nil
end

--- Removes a number of instances of the specified item from the list.
---@param val any The value to remove
---@param count number|nil The number of items to remove (defaults to all)
---@return number The number of items removed
function ArrayList:removeItem(val, count)
    expect(2, count, "number", "nil")
    if count then
        count = math.floor(count)
        if count < 1 then return end
    end
    local i = 1
    local n = 0
    while i <= self.length do
        if self[i] == val then
            self:remove(i)
            n = n + 1
            if count and n == count then return n end
        else i = i + 1 end
    end
    return n
end

--- Returns a new ArrayList with only elements that match a predicate function.
---@param fn fun(any):boolean A function to be called on each item; returns whether the item should be included
---@return ArrayList The new filtered list
function ArrayList:filter(fn)
    expect(1, fn, "function")
    local retval = ArrayList:new()
    for i = 1, self.length do
        if fn(self[i]) then
            retval:append(self[i])
        end
    end
    return retval
end

--- Returns a new ArrayList where each item has been transformed by a function.
---@param fn fun(any):any A function to be called on each item; returns a new item
---@return ArrayList The new mapped list
function ArrayList:map(fn)
    expect(1, fn, "function")
    local retval = {}
    for i = 1, self.length do
        retval[i] = fn(self[i])
    end
    return ArrayList:new(retval)
end

--- Returns a new ArrayList where each item has been transformed by a function; if the function returns nil, the item will not be included.
---@param fn fun(any):any|nil A function to be called on each item; returns the new item, or nil to remove
---@return ArrayList The new filtered list
function ArrayList:compactMap(fn)
    expect(1, fn, "function")
    local retval = ArrayList:new()
    for i = 1, self.length do
        local v = fn(self[i])
        if v ~= nil then
            retval:append(self[i])
        end
    end
    return retval
end

return ArrayList