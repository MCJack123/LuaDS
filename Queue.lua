local expect = require "expect"

---@class Queue
---@field private _list List
---@operator len: number
local Queue = {}
Queue.__mt = {__name = "Queue", __index = Queue}

--- Creates a new queue with the specified backing list type. (O(1))
---@param List ListType The type of list to use to store data
---@return Queue queue A new Queue
function Queue:new(List)
    expect(1, List, "table")
    return setmetatable({_list = List:new()}, self.__mt)
end

--- Returns whether the queue is empty. (O(1))
---@return boolean empty Whether the queue is empty
function Queue:isEmpty()
    return self._list:isEmpty()
end

--- Returns the number of items in the queue. (O(1))
---@return number length The number of items in the queue
function Queue:length()
    return self._list:length()
end

--- Returns the item at the front of the queue. (O(1))
---@return any front The item at the front of the queue, or nil if the queue is empty
function Queue:front()
    return self._list:front()
end

--- Returns the item at the back of the queue. (O(1))
---@return any back The item at the back of the queue, or nil if the queue is empty
function Queue:back()
    return self._list:back()
end

--- Adds an item to the back of the queue. (Varies by backing structure)
---@param val any The value to add
function Queue:push(val)
    return self._list:append(val)
end

--- Removes and returns the item at the front of the queue. Returns nil if the queue is empty. (Varies by backing structure)
---@return any|nil front The item removed
function Queue:pop()
    if self._list:isEmpty() then return nil end
    return self._list:remove(1)
end

function Queue.__mt:__len()
    return self._list:length()
end

return Queue
