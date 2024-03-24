local _, ns = ...

local Api = {}
Api.Rules = {}

function Api:AddRule(ruleName, ruleFunction)
    local rule = {
        name = ruleName,
        func = ruleFunction
    }

    table.insert(Api.Rules, rule)
end

function Api:GetItemValue(itemRef)
    if TSM_API then
        local price, error = TSM_API.GetCustomPriceValue("DBMinBuyout", "i:" .. tostring(itemRef.itemId))
        if error ~= nil then return 0 end
        if price == nil then return 0 end
        return price
    end

    return 0
end

function Api:GetThingsCount(itemRef)
    local total = 0
    local progress = 0

    if _G and _G.AllTheThings then
        local ATT = _G.AllTheThings
        --local result = _G.AllTheThings.GetCachedSearchResults(_G.AllTheThings.SearchForField, "itemID", itemRef.itemId)
        local result = ATT.GetCachedSearchResults(ATT.SearchForLink, itemRef.itemLink)
        if result ~= nil then
            total = result.total or 0
            progress = result.progress or 0
        end
    end

    return total, progress
end
ns.Cache = {}
ns.Api = Api
ns.Class = {}