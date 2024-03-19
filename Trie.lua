local expect = require "expect"

---@class Trie
---@field character string|nil
---@field children table<number,Trie>
---@field value any|nil
local Trie = {}
Trie.__mt = {__name = "Trie", __index = Trie}

--- Creates a new trie. (O(1))
---@param c? string The character to assign as a byte
---@return Trie trie The new trie
function Trie:new(c)
    expect(1, c, "string", "nil")
    return setmetatable({character = c, children = {}}, self.__mt)
end

--- Inserts a string into the trie. (O(#str))
---@param str string The string to add
---@param v? any A value to store in the final node
function Trie:insert(str, v)
    expect(1, str, "string")
    local b = str:byte(1)
    if not self.children[b or -1] then self.children[b or -1] = Trie:new(b and string.char(b) or "") end
    if b then return self.children[b]:insert(str:sub(2), v)
    else self.children[-1].value = v end
end

--- Removes a string from the trie. (O(#str))
---@param str string The string to remove
function Trie:remove(str)
    expect(1, str, "string")
    local b = str:byte(1) or -1
    if self.children[b] then
        self.children[b]:remove(str:sub(2))
        if next(self.children[b].children) == nil then self.children[b] = nil end
    end
end

--- Returns whether the specified string is in the trie. (O(#str))
---@param str string The string to search for
---@return boolean found Whether the string was found
---@return any|nil value The value associated with the key
function Trie:find(str)
    expect(1, str, "string")
    local b = str:byte(1) or -1
    if self.character == "" and b == -1 then return true, self.value end
    if not self.children[b] then return false end
    return self.children[b]:find(str:sub(2))
end

--- Returns all completions for the specified prefix string. (O(n))
---@param str? string The string to complete; defaults to "", or all strings in the trie
---@return string[] completions The possible completion suffixes
function Trie:complete(str)
    str = expect(1, str, "string", "nil") or ""
    local b = str:byte(1)
    if b then
        if self.children[b] then return self.children[b]:complete(str:sub(2))
        else return {} end
    end
    if self.character == "" then return {""} end
    local retval = {}
    for _, v in pairs(self.children) do
        local strs = v:complete()
        for _, s in ipairs(strs) do retval[#retval+1] = v.character .. s end
    end
    return retval
end

return Trie
