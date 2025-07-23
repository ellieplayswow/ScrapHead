local _, ns = ...

ns.Api:AddRule(
    "Junk Consumables",
    function(itemStack)
        if itemStack.itemData.classId == Enum.ItemClass.Consumable then
            -- food/drink, potions, other (scrolls)
            if itemStack.itemData.subClassId == Enum.ItemConsumableSubclass.Fooddrink or itemStack.itemData.subClassId == Enum.ItemConsumableSubclass.Potion then
                local playerLevel = UnitLevel("player")

                -- most food is level -12, but can get a bit tricky around old xpacs
                local levelDiff = abs(itemStack.itemData.minLevel - playerLevel)
                if levelDiff > 15 then

                    -- crude item id filter
                    if itemStack.itemData.expansion <= 3 and itemStack.itemData.quality <= 2 then
                        return { action = "sell" }
                    end
                end
            end
        end

        return false
    end
)