local _, ns = ...

ns.Api:AddRule(
    "Artifact Relics",
    function(itemStack)
        if itemStack.itemData.classId == Enum.ItemClass.Gem and itemStack.itemData.subClassId == Enum.ItemGemSubclass.Artifactrelic then
            return { action = "sell" }
        end
        return false
    end
)