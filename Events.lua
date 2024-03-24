local _, ns = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "EQUIPMENT_SETS_CHANGED" then
        ns.EquipmentSet:Refresh()
    end
    if event == "MERCHANT_SHOW" then
        if not ns.EquipmentSet.Initialised then
            ns.EquipmentSet:Refresh()
        end

        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemInfo ~= nil then
                    local itemString = string.match(itemInfo.hyperlink, "item[%-?%d:]+")
                    local itemStack = ns.Class.ItemStack:New(itemString, itemInfo.stackCount)

                    for _, rule in ipairs(ns.Api.Rules) do
                        local result = rule.func(itemStack)
                        if result ~= false then
                            if itemStack.itemData.sellPrice > 0 then
                                C_Container.UseContainerItem(bag, slot)
                            else
                                print(bag .. ":" .. slot .. ", " .. itemStack.itemData.name .. " rule " .. rule.name)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end)