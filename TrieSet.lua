local expect = require "expect"
local Trie = require "Trie"

---@class TrieSet: Trie, Set A set of string values.
---@operator len: number
---@operator add(Set): TrieSet
---@operator sub(Set): TrieSet
local TrieSet = setmetatable({}, {__index = Trie})
TrieSet.__mt = {__name = "TrieSet", __index = TrieSet}

--- Creates a new set. (O(1) or O(n))
---@param tab? string[] A list of values to prefill the set with
---@return TrieSet set The new set
function TrieSet:new(tab)
    expect(1, tab, "table")
    local obj = Trie.new(self) ---@cast obj TrieSet
    if tab then
        for _, v in pairs(tab) do obj:insert(v) end
    end
    return obj
end

--- Returns the number of items in the set. (O(n))
---@return number length The number of items in the set
function TrieSet:length()
    local n = 0
    for _ in self:enumerate() do n = n + 1 end
    return n
end

--- Returns a new set which only contains items in both sets. (O(n log m))
---@param other Set The other set to operate on
---@return TrieSet intersection The intersection of the two sets
function TrieSet:intersection(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if other:find(v) then s:insert(v) end
    end
    return s
end

--- Returns a new set which contains items in either set. (O(n*m) amortized, O(n*m log n log m) worst)
---@param other Set The other set to operate on
---@return TrieSet union The union of the two sets
function TrieSet:union(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do s:insert(v) end
    for _, v in other:enumerate() do s:insert(v) end
    return s
end

--- Returns a new set which contains all items in this set, except for ones in the other set. (O(n log m))
---@param other Set The other set to operate on
---@return TrieSet difference The difference of the two sets
function TrieSet:difference(other)
    expect(2, other, "table")
    local s = self:new()
    for _, v in self:enumerate() do
        if not other:find(v) then s:insert(v) end
    end
    return s
end

local function TSiter(self, str, i)
    if self.character == "" then coroutine.yield(i, str) return i + 1 else
        for j = -1, 255 do
            if self.children[j] then
                i = TSiter(self.children[j], str .. (j == -1 and "" or string.char(j)), i)
            end
        end
    end
    return i
end

--- Returns a key-value iterator function for a for loop. (O(1))
---@return fun():any|nil,any|nil iter The iterator function
function TrieSet:enumerate()
    return coroutine.wrap(function() TSiter(self._tree, "", 1) end)
end

--- Returns an array table or List type with the contents of the set. (O(n))
---@param List? ListType If provided, use this type of list as output
---@return table|List table A table with the contents of the set
function TrieSet:array(List)
    if List then
        local t = List:new()
        for _, v in self:enumerate() do t:append(v) end
        return t
    else
        local t = {}
        for i, v in self:enumerate() do t[i] = v end
        return t
    end
end

function TrieSet.__mt:__len()
    return self:length()
end

function TrieSet.__mt:__pairs()
    return self:enumerate()
end

function TrieSet.__mt:__add(other)
    return self:union(other)
end

function TrieSet.__mt:__sub(other)
    return self:difference(other)
end

return TrieSet
