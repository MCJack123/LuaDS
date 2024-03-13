---@meta

---@class List: ListType
---@operator concat(List):List
---@operator len():number
local List = {}

--- Creates a new List.
---@param arr table|any|nil An array with preset values, or if count is provided, a value to repeat
---@param count number|nil If specified, fill the list with arr repeated this many times
---@return List list The new List
function List:new(arr, count) end

--- Returns whether the list is empty.
---@return boolean _ Whether the list is empty
function List:isEmpty() end

--- Returns the number of items in the list.
---@return number length The number of items in the list
function List:length() end

--- Returns the item at the front of the list, or nil if the list is empty.
---@return any front The front item
function List:front() end

--- Returns the item at the back of the list, or nil if the list is empty.
---@return any back The back item
function List:back() end

--- Appends an item at the back of the list.
---@param val any The value to add
function List:append(val) end

--- Removes the item at the back of the list, returning the value. Returns nil and does nothing if the list is empty.
---@return any|nil back The back item which was removed
function List:pop() end

--- Inserts an item into the list at the specified position.
---@param val any The value to insert
---@param idx number The index to insert to; 1 <= idx <= list.n + 1
function List:insert(val, idx) end

--- Removes an item at the specified position.
---@param idx number The index to remove at; 1 <= idx <= list.n
---@return any item The value removed
function List:remove(idx) end

--- Returns the first index of the specified item, or nil if not present in the list.
---@param val any The value to look for
---@return number|nil index The index of the item, or nil if not present
function List:find(val) end

--- Removes a number of instances of the specified item from the list.
---@param val any The value to remove
---@param count number|nil The number of items to remove (defaults to all)
---@return number itemsRemoved The number of items removed
function List:removeItem(val, count) end

--- Returns a new List with only elements that match a predicate function.
---@param fn fun(any):boolean A function to be called on each item; returns whether the item should be included
---@return List filteredList The new filtered list
function List:filter(fn) end

--- Returns a new List where each item has been transformed by a function.
---@param fn fun(any):any A function to be called on each item; returns a new item
---@return List mappedList The new mapped list
function List:map(fn) end

--- Returns a new List where each item has been transformed by a function; if the function returns nil, the item will not be included.
---@param fn fun(any):any|nil A function to be called on each item; returns the new item, or nil to remove
---@return List mappedList The new mapped list
function List:compactMap(fn) end

--- Returns an iterator function for a for loop.
---@return fun(List,number):number|nil,any _ The iterator function
---@return List self
---@return number 0
function List:enumerate() end

---@class ListType
local ListType = {}

--- Creates a new List.
---@param arr table|any|nil An array with preset values, or if count is provided, a value to repeat
---@param count number|nil If specified, fill the list with arr repeated this many times
---@return List list The new List
function ListType:new(arr, count) end
