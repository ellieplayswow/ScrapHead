local _, ns = ...

local EquipmentSet = {}
EquipmentSet.Cache = ns.Class.Cache:New()
EquipmentSet.Initialised = false
EquipmentSet.TimerStarted = false

function EquipmentSet:Init()
    local this = self
    CharacterFrame:HookScript("OnShow", function(self)
        -- run this a second after loading the character frame in order to ensure all equipment sets are loaded
        if not this.TimerStarted then
            C_Timer.After(1, function()
                this:Refresh()
            end)
            this.TimerStarted = true
        end
    end)
end

function EquipmentSet:Refresh()
    self.Cache:Empty()

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for _, setId in ipairs(setIds) do
        local setName = C_EquipmentSet.GetEquipmentSetInfo(setId)
        local locations = C_EquipmentSet.GetItemLocations(setId)
        for _, location in pairs(locations) do
            if location ~= 0 and location ~= 1 and location ~= -1 then
                local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
                if player == true and bank == false and bags == true then
                    -- valid item
                    local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                    if itemInfo ~= nil then
                        local itemString = string.match(itemInfo.hyperlink, "item[%-?%d:]+")
                        if not self.Cache:Has(itemString) then
                            self.Cache:Set(itemString, setId)
                        end
                    end
                end
            end
        end
    end

    if not self.Initialised then
        self.Initialised = true
    end
end

ns.EquipmentSet = EquipmentSet