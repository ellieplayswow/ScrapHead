local _, ns = ...

local ItemStack = {}
ItemStack.__index = ItemStack

function ItemStack:New(itemString, quantity, isBound)
    local localItem = {}
    setmetatable(localItem, ItemStack)
    self.__index = self

    self.itemId = tonumber(itemString:match("item:(%d+)"))
    self.quantity = quantity
    self.itemString = itemString
    self.isSoulbound = isBound

    -- get transmog data
    if self.quantity == 1 then
        local transmogAppearanceId, transmogSourceId = C_TransmogCollection.GetItemInfo(self.itemId)
        self.isMog = true
        self.transmog = {
            appearanceId = transmogAppearanceId,
            sourceId = transmogSourceId
        }
    end

    -- get core item data
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType,
    itemSubType, itemMaxStack, itemEquipLocation, _, itemSellPrice,
    itemClassId, itemSubClassId, itemBindType, itemExpansion, itemSet,
    itemIsCraftingReagent = C_Item.GetItemInfo(itemString)

    self.itemData = {
        name = itemName,
        link = itemLink,
        quality = itemQuality,
        level = itemLevel,
        minLevel = itemMinLevel,
        type = itemType,
        subType = itemSubType,
        maxStack = itemMaxStack,
        equipLocation = itemEquipLocation,
        sellPrice = itemSellPrice,
        classId = itemClassId,
        subClassId = itemSubClassId,
        bindType = itemBindType,
        expansion = itemExpansion,
        set = itemSet,
        isCraftingReagent = itemIsCraftingReagent
    }

    return localItem
end

function ItemStack:GetAuctionPrice()
    return ns.Api:GetItemValue(self)
end

function ItemStack:HasCollected()
    if self.isMog == true then
        return C_TransmogCollection.PlayerKnowsSource(self.transmog.sourceId)
    end

    return false
end

function ItemStack:GetThingsCount()
    return ns.Api:GetThingsCount(self)
end

function ItemStack:CanEquip()
    local itemClass = self.itemData.classId
    local armorMapping = {
        [1] = Enum.ItemArmorSubclass.Plate, -- warrior
        [2] = Enum.ItemArmorSubclass.Plate, -- paladin
        [3] = Enum.ItemArmorSubclass.Mail, -- hunter
        [4] = Enum.ItemArmorSubclass.Leather, -- rogue
        [5] = Enum.ItemArmorSubclass.Cloth, -- priest
        [6] = Enum.ItemArmorSubclass.Plate, -- death knight
        [7] = Enum.ItemArmorSubclass.Mail, -- shaman
        [8] = Enum.ItemArmorSubclass.Cloth, -- mage
        [9] = Enum.ItemArmorSubclass.Cloth, -- warlock
        [10] = Enum.ItemArmorSubclass.Leather, -- monk
        [11] = Enum.ItemArmorSubclass.Leather, -- druid
        [12] = Enum.ItemArmorSubclass.Leather, -- demon hunter
        [13] = Enum.ItemArmorSubclass.Mail -- evoker
    }

    -- weapons, we only check if it is equippable
    if itemClass == Enum.ItemClass.Weapon then
        return C_Item.IsEquippableItem(self.itemId)
    end

    -- armor, check the armor mapping
    if itemClass == Enum.ItemClass.Armor then
        -- check if cosmetic or "generic" (rings, trinkets, necklaces) - those can always be equipped
        local armorType = self.itemData.subClassId
        if armorType == Enum.ItemArmorSubclass.Cosmetic or armorType == Enum.ItemArmorSubclass.Generic then return true end

        -- we can always equip cloaks...
        if self.itemData.equipLocation == "INVTYPE_CLOAK" then return true end

        -- everything else
        local _, _, ourClass = UnitClass("player")
        return armorMapping[ourClass] == armorType
    end

    return false
end

ns.Class.ItemStack = ItemStack