local _, ns = ...

ns.Api:AddRule(
    "Sellable Junk",
    function(itemStack)
        if itemStack.itemData.sellPrice > 0 and itemStack.itemData.quality == 0 then
            return { action = "sell" }
        else
            return false
        end
    end
)