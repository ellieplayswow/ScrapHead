local _, ns = ...

ns.Api:AddRule(
    "Sellable Junk",
    function(itemStack)
        if itemStack.itemData.sellPrice > 0 and itemStack.itemData.quality == 0 then
            -- if the item is armor or a weapon, we want to run extra checks
            if itemStack.itemData.classId == Enum.ItemClass.Weapon or itemStack.itemData.classId == Enum.ItemClass.Armor then
                -- have we collected the transmog OR is it unequippable?
                if itemStack:HasCollected() or not itemStack:CanEquip() then
                    return { action = "sell" }
                end
            else
                return { action = "sell" }
            end
        end

        return false
    end
)