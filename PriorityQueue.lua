local expect = require "expect"
local Heap = require "Heap"

---@class PriorityQueue: Queue
---@field private _heap Heap
---@operator len: number
local PriorityQueue = {}
PriorityQueue.__mt = {__name = "PriorityQueue", __index = PriorityQueue}

---@class PriorityItem
---@field value any
---@field priority number
local PriorityItem_mt = {__lt = function(a, b) return a.priority < b.priority end}
local function PriorityItem(v, p) return setmetatable({value = v, priority = p}, PriorityItem_mt) end

--- Creates a new priority queue.
---@return PriorityQueue queue A new PriorityQueue
function PriorityQueue:new()
    return setmetatable({_heap = Heap:new(true)}, self.__mt)
end

--- Returns whether the queue is empty.
---@return boolean empty Whether the queue is empty
function PriorityQueue:isEmpty()
    return self._heap:isEmpty()
end

--- Returns the number of items in the queue.
---@return number length The number of items in the queue
function PriorityQueue:length()
    return self._heap:length()
end

--- Returns the item at the front of the queue.
---@return any front The item at the front of the queue, or nil if the queue is empty
function PriorityQueue:front()
    if self._heap:isEmpty() then return nil end
    return self._heap:front().value
end

--- Returns an item near the back of the queue. This is not guaranteed to be the lowest priority item!
---@return any back The item at the "back" of the queue, or nil if the queue is empty
function PriorityQueue:back()
    if self._heap:isEmpty() then return nil end
    return self._heap[#self._heap].value
end

--- Adds an item to the queue. Higher priority items will be pushed further forward than lower priority items.
---@param val any The value to add
---@param priority? number The priority of the item (defaults to `val` if the item is comparable)
function PriorityQueue:push(val, priority)
    if priority == nil then priority = val end
    expect(2, priority, "number", "string", "table")
    return self._heap:insert(PriorityItem(val, priority))
end

--- Removes and returns the item at the front of the queue. Returns nil if the queue is empty.
---@return any|nil top The item removed
---@return number|nil priority The priority of the item
function PriorityQueue:pop()
    local v = self._heap:remove()
    if not v then return nil end
    return v.value, v.priority
end

function PriorityQueue.__mt:__len()
    return self._heap:length()
end

return PriorityQueue
