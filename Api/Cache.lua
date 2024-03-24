local _, ns = ...

local Cache = {}
Cache.__index = Cache

local function getCacheKey(args)
    local key = nil
    if type(args) == "table" then
        key = table.concat(args, ":")
    else
        key = tostring(args)
    end

    return key
end

function Cache:New()
    local localCache = {}
    setmetatable(localCache, Cache)
    self.__index = self

    self.items = {}
    self.isEmpty = true

    return localCache
end

function Cache:Has(...)
    local key = getCacheKey(...)
    if key == nil then return false end

    return self.items[key] ~= nil
end

function Cache:Get(...)
    if self.isEmpty then return false end

    local key = getCacheKey(...)

    return self.items[key] or false
end

function Cache:Set(...)
    local args = { ... }
    local value = args[#args]
    args[#args] = nil

    self.items[getCacheKey(args)] = value
    if self.isEmpty then self.isEmpty = false end
end

function Cache:Empty()
    self.items = {}
    self.isEmpty = true
end

ns.Class.Cache = Cache