local _, ns = ...

local skippedItemCache = {}
local soldItemCache = {}

ns.Api:AddRule(
    "Collected all Things",
    function(itemStack)
        -- to try and avoid self-ddos with ATT calls, lets only pass calls to ATT when we KNOW its valid for this
        -- skip for any armor
        if itemStack.itemData.classId == Enum.ItemClass.Weapon or itemStack.itemData.classId == Enum.ItemClass.Armor then return false end
        
        -- skip for anything in the skipped item cache
        if skippedItemCache[itemStack.itemId] ~= nil then return false end
        if soldItemCache[itemStack.itemId] ~= nil and itemStack.isSoulbound then return { action = "sell" } end
        
        -- @todo: do we need to check for pets here?
        --if itemStack.itemData.classId == Enum.ItemClass.Miscellaneous then
        --    if itemStack.itemData.
        --end
        
        local total, progress = itemStack:GetThingsCount()
        if total == 0 then
            skippedItemCache[itemStack.itemId] = true
            return false
        end

        if total == progress and itemStack.isSoulbound then
            soldItemCache[itemStack.itemId] = true
            return { action = "sell" }
        end
        
        skippedItemCache[itemStack.itemId] = true
        
        return false
    end
)