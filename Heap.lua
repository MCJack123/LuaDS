local expect = require "expect"

---@class Heap A min- or max-heap which efficiently adds and removes items in order.
---@operator len:number
local Heap = {}
Heap.__mt = {__name = "Heap", __index = Heap}

--- Creates a new min- or max-heap.
---@param max boolean Whether to create a min (false) or max (true) heap
---@return Heap heap A new Heap
function Heap:new(max)
    expect(1, max, "boolean")
    return setmetatable({max = max}, self.__mt)
end

--- Returns whether the heap is empty.
---@return boolean empty Whether the heap is empty
function Heap:isEmpty()
    return #self == 0
end

--- Returns the length of the heap.
---@return number length The length of the heap
function Heap:length()
    return #self
end

--- Returns the item at the top of the heap.
---@return Comparable|nil top The top of the heap, or nil if the heap is empty
function Heap:front()
    return self[1]
end

--- Inserts an item into the heap.
---@param val Comparable The value to insert
function Heap:insert(val)
    expect(1, val, "number", "string", "table")
    local idx = #self+1
    self[idx] = val
    while idx > 1 do
        local parent = math.floor(idx / 2)
        if (self.max and self[idx] <= self[parent]) or (not self.max and self[idx] >= self[parent]) then
            return
        else
            self[idx], self[parent] = self[parent], self[idx]
            idx = parent
        end
    end
end

--- Removes the top item from the heap, and returns it.
---@return Comparable|nil top The item previously at the top, or nil if the heap is empty
function Heap:remove()
    local retval = self[1]
    local idx = #self
    self[1], self[idx] = self[idx], nil
    idx = 1
    local child = 2
    local value = self[1]
    while idx <= #self do
        local max, midx = value, -1
        if (self.max and self[child] > max) or (not self.max and self[child] < max) then
            max, midx = self[child], child
        end
        if child + 1 <= #self and ((self.max and self[child+1] > max) or (not self.max and self[child+1] < max)) then
            max, midx = self[child+1], child+1
        end
        if max == value then
            return retval
        else
            self[midx], self[idx] = self[idx], self[midx]
            idx = midx
            child = 2 * idx
        end
    end
    return retval
end

return Heap
