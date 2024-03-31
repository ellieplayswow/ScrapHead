local addonName, ns = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonLoaded = ...
        if addonLoaded == addonName then
            ns.EquipmentSet:Init()
        end
    end

    if event == "EQUIPMENT_SETS_CHANGED" then
        ns.EquipmentSet:Refresh()
    end
    if event == "MERCHANT_SHOW" then
        --if not ns.EquipmentSet.Initialised then
            ns.EquipmentSet:Refresh()
        --end

        local sellData = {}
        local totalPrice = 0

        for bag = 0, 5 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemInfo ~= nil then
                    local itemString = string.match(itemInfo.hyperlink, "item[%-?%d:]+")
                    if itemString ~= nil then
                        local itemStack = ns.Class.ItemStack:New(itemString, itemInfo.stackCount)

                        for _, rule in ipairs(ns.Api.Rules) do
                            local result = rule.func(itemStack)
                            if result ~= false then
                                ns.out:Write("Item ", itemInfo.hyperlink, " (" .. bag .. ":" .. slot .. ") matches rule ", ns.Theme.Highlight, rule.name, ns.Theme.Reset, "!")
                                if itemStack.itemData.sellPrice > 0 then
                                    sellData[rule.name] = (sellData[rule.name] or 0) + (itemStack.itemData.sellPrice * itemStack.quantity)
                                    C_Container.UseContainerItem(bag, slot)
                                    totalPrice = totalPrice + (itemStack.itemData.sellPrice * itemStack.quantity)
                                else
                                    print(bag .. ":" .. slot .. ", " .. itemStack.itemData.name .. " rule " .. rule.name)
                                end
                                break
                            end
                        end
                    else
                        print(bag .. ":" .. slot .. " seems invalid")
                    end
                end
            end
        end

        ns.out:Write("Vendor report: ", ns.Theme.Highlight, C_CurrencyInfo.GetCoinTextureString(totalPrice))
        for name, price in pairs(sellData) do
            ns.out:Write(ns.Theme.Highlight, name, ns.Theme.Reset, ": ", ns.Theme.Highlight, C_CurrencyInfo.GetCoinTextureString(price))
        end
    end
end)

_ScrapHead = ns
function _ScrapHeadItem(link)
    return string.match(link, "item[%-?%d:]+")
end