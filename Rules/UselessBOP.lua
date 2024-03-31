local _, ns = ...

ns.Api:AddRule(
    "Useless Bind on Pickup",
    function(itemStack)
        -- exclude anything that isn't BOP
        if itemStack.itemData.bindType ~= 1 then return false end
        -- exclude legendaries & artifact weapons
        if itemStack.itemData.quality == 5 or itemStack.itemData.quality == 6 then return false end

        local playerLevel = UnitLevel("player")

        -- only trigger on weapons & armor here
        if itemStack.itemData.classId == Enum.ItemClass.Weapon or itemStack.itemData.classId == Enum.ItemClass.Armor then
            if not itemStack:CanEquip() then
                return { action = "sell" }
            end

            local levelDiff = abs(itemStack.itemData.minLevel - playerLevel)
            if levelDiff >= 10 and ns.EquipmentSet.Initialised then
                if not ns.EquipmentSet.Cache:Has(itemStack.itemString) then
                    return { action = "sell" }
                end
            end
        end

        return false
    end
)