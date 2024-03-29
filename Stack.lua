local expect = require "expect"

---@class Stack
---@field private _list List
---@operator len: number
local Stack = {}
Stack.__mt = {__name = "Stack", __index = Stack}

--- Creates a new stack with the specified backing list type. (O(1))
---@param List ListType The type of list to use to store data
---@return Stack stack A new Stack
function Stack:new(List)
    expect(1, List, "table")
    return setmetatable({_list = List:new()}, self.__mt)
end

--- Returns whether the stack is empty. (O(1))
---@return boolean empty Whether the stack is empty
function Stack:isEmpty()
    return self._list:isEmpty()
end

--- Returns the number of items in the stack. (O(1))
---@return number length The number of items in the stack
function Stack:length()
    return self._list:length()
end

--- Returns the item at the top of the stack. (O(1))
---@return any top The item at the top of the stack, or nil if the stack is empty
function Stack:top()
    return self._list:back()
end

--- Adds an item to the top of the stack. (O(1))
---@param val any The value to add
function Stack:push(val)
    return self._list:append(val)
end

--- Removes and returns the item at the top of the stack. Returns nil if the stack is empty. (O(1))
---@return any|nil top The item removed
function Stack:pop()
    return self._list:pop()
end

function Stack.__mt:__len()
    return self._list:length()
end

return Stack
