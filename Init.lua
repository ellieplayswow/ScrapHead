---@diagnostic disable: undefined-global, undefined-field
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
    if OpenTradeSkill and OpenTradeSkill.Pricing then
        local price = OpenTradeSkill.Pricing:Lookup(itemRef.itemId)
        if price == -1 then return 0 end
        return price
    elseif TSM_API then
        local price, error = TSM_API.GetCustomPriceValue("DBMinBuyout", "i:" .. tostring(itemRef.itemId))
        if error ~= nil then return 0 end
        if price == nil then return 0 end
        return price
    elseif Auctionator then
        local price = Auctionator.API.v1.GetAuctionPriceByItemID("ScrapHead", itemRef.itemId)
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
        local result = ATT.GetCachedSearchResults(ATT.SearchForLink, itemRef.itemString)
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

ns.Theme = {
    Highlight = "#FBBF24",
    Reset = "<r>"
}