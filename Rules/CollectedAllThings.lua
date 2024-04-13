local _, ns = ...

--[[ns.Api:AddRule(
    "Collected all Things",
    function(itemStack)
        local total, progress = itemStack:GetThingsCount()
        if total == 0 then return false end

        if total == progress and itemStack.isSoulbound then
            return { action = "sell" }
        end
    end
)]]--