local expect = require "expect"
local Trie = require "Trie"

---@class TrieMap: Map A key-value map backed by a trie.
---@field private _tree Trie
---@operator len: number
local TrieMap = {}
TrieMap.__mt = {__name = "TrieMap"}

--- Creates a new trie map.
---@param tab? table A table of values to prefill the map with
---@return TrieMap map The new map
function TrieMap:new(tab)
    expect(1, tab, "table", "nil")
    local obj = setmetatable({_tree = Trie:new()}, self.__mt)
    if tab then
        for k, v in pairs(tab) do
            obj:set(k, v)
        end
    end
    return obj
end

--- Returns whether the map is empty. (O(1))
---@return boolean empty Whether the map is empty
function TrieMap:isEmpty()
    return #self._tree.children == 0
end

--- Returns the number of items in the map. (O(n))
---@return number length The number of items in the map
function TrieMap:length()
    return #self._tree:complete()
end

--- Returns the value associated with a given key, or nil if not found. (O(#key))
---@param key string The key to check
---@return any|nil value The value associated with the key
function TrieMap:get(key)
    expect(1, key, "string")
    local ok, v = self._tree:find(key)
    if ok then return v else return nil end
end

--- Assigns a key to a value, inserting it if it doesn't exist, or replacing the value if it does. (O(#key))
---@param key string The key to assign to
---@param value any The value to assign
function TrieMap:set(key, value)
    expect(1, key, "string")
    self._tree:insert(key, value)
end

--- Returns whether a given key exists in the map. (O(#key))
---@param key string The key to check
---@return boolean found Whether the key exists
function TrieMap:find(key)
    expect(1, key, "string")
    return self._tree:find(key) == true
end

local function TMiter(self, str)
    if self.character == "" then coroutine.yield(str, self.value) else
        for i = -1, 255 do
            if self.children[i] then
                TMiter(self.children[i], str .. (i == -1 and "" or string.char(i)))
            end
        end
    end
end

--- Returns a key-value iterator function for a for loop. (O(1))
---@return fun():any|nil,any|nil iter The iterator function
function TrieMap:enumerate()
    return coroutine.wrap(function() return TMiter(self._tree, "") end)
end

--- Returns a normal table with the contents of the map. (O(n))
---@return table table A table with the contents of the map
function TrieMap:table()
    local t = {}
    for k, v in self:enumerate() do t[k] = v end
    return t
end

--- Returns a list (optionally of a List type) with pairs of key-value entries. (O(n))
---@param List? ListType The type of list to make (defaults to a normal table)
---@return table<{key:string,value:any}>|List pairs A list of key-value pairs in the table
function TrieMap:pairs(List)
    if List then
        expect(1, List, "table")
        local retval = List:new()
        for k, v in self:enumerate() do retval:append({key = k, value = v}) end
        return retval
    else
        local retval = {}
        for k, v in self:enumerate() do retval[#retval+1] = {key = k, value = v} end
        return retval
    end
end

function TrieMap.__mt:__index(key)
    if TrieMap[key] then return TrieMap[key] end
    return self:get(key)
end

function TrieMap.__mt:__len()
    return self._tree:length()
end

function TrieMap.__mt:__newindex(key, val)
    return self:set(key, val)
end

function TrieMap.__mt:__pairs()
    return self:enumerate()
end

return TrieMap
