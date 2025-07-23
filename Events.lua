local addonName, ns = ...

local isMerchantOpen = false
local queuedBagUpdates = 0

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonLoaded = ...
        if addonLoaded == addonName then
            -- run any init logic on load, keep in mind most apis won't work here
            ns.EquipmentSet:Init()
        end
    end

    -- keep equipment sets in sync (@todo - is this needed now?)
    if event == "EQUIPMENT_SETS_CHANGED" then
        ns.EquipmentSet:Refresh()
    end
    
    -- cleanup bag operations
    if event == "MERCHANT_CLOSED" then 
        isMerchantOpen = false
        frame:UnregisterEvent("BAG_UPDATE")
    end
    
    if event == "BAG_UPDATE" then
        if isMerchantOpen == true and queuedBagUpdates > 0 then
            queuedBagUpdates = queuedBagUpdates - 1
        end
    end
    
    if event == "MERCHANT_SHOW" then
        -- we only need BAG_UPDATE when we're selling to keep track of when we can sell more
        frame:RegisterEvent("BAG_UPDATE")
        isMerchantOpen = true
        ns.EquipmentSet:Refresh()
        
        local sellData = {}
        local totalPrice = 0
        local loopStart = debugprofilestop()
        
        local bagLoop = function(bagStart, slotStart, scrappedCount, loopBudgetMs, loopScrappedBudget, loopFunc, afterLoopFunc)
            local elapsedMs = 0
            for bag = bagStart, 5 do
                for slot = slotStart, C_Container.GetContainerNumSlots(bag) do
                    local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                    if itemInfo ~= nil then
                        local itemString = string.match(itemInfo.hyperlink, "item[%-?%d:]+")
                        if itemString ~= nil then
                            local itemStack = ns.Class.ItemStack:New(itemString, itemInfo.stackCount, itemInfo.isBound)
                            -- @todo: handle sell price better, but this is a good gate for spam atm
                            if itemStack.itemData.sellPrice ~= nil and itemStack.itemData.sellPrice > 0 then
                                local t1 = debugprofilestop()
                                for _, rule in ipairs(ns.Api.Rules) do
                                    local result = rule.func(itemStack)
                                    if result ~= false then
                                        -- exit here 
                                        if isMerchantOpen == false then
                                            afterLoopFunc()
                                            return
                                        end
                                        
                                        -- @todo: if sellPrice is nil or 0, we should select the item & destroycursoritem instead
                                        C_Container.UseContainerItem(bag, slot)
                                        
                                        totalPrice = totalPrice + (itemStack.itemData.sellPrice * itemStack.quantity)
                                        sellData[rule.name] = (sellData[rule.name] or 0) + (itemStack.itemData.sellPrice * itemStack.quantity)
                                        
                                        queuedBagUpdates = queuedBagUpdates + 1
                                        scrappedCount = scrappedCount + 1
                                        break
                                    end
                                end
                                local t2 = debugprofilestop()
                                elapsedMs = elapsedMs + (t2 - t1)
                                if scrappedCount > loopScrappedBudget then
                                    -- here we want to poll until queuedBagUpdates = 0
                                    local poll = C_Timer.NewTicker(0.05, function(self)
                                        if isMerchantOpen == false then
                                            -- @todo: is there ever a case to call afterLoopFunc here?
                                            self:Cancel()
                                        end
                                        
                                        if queuedBagUpdates == 0 then
                                            -- wait a bit before continuing to account for latency
                                            C_Timer.After(0.1, function()
                                                loopFunc(bag, slot, 0, loopBudgetMs, loopScrappedBudget, loopFunc, afterLoopFunc)
                                            end)
                                            self:Cancel()
                                        end
                                    end, 20 * 30) -- 30s timeout
                                    return
                                end
                                
                                -- continue next frame so the game only slightly runs like ass
                                if elapsedMs > loopBudgetMs then
                                    RunNextFrame(function() loopFunc(bag, slot, scrappedCount, loopBudgetMs, loopScrappedBudget, loopFunc, afterLoopFunc) end)
                                    return
                                end
                            end
                        end
                    end
                end
                slotStart = 1
            end
            
            afterLoopFunc()
        end
        
        local afterLoop = function()
            if totalPrice > 0 then
                ns.out:Write("Vendor report: ", ns.Theme.Highlight, C_CurrencyInfo.GetCoinTextureString(totalPrice))
                for name, price in pairs(sellData) do
                    ns.out:Write(ns.Theme.Highlight, name, ns.Theme.Reset, ": ", ns.Theme.Highlight, C_CurrencyInfo.GetCoinTextureString(price))
                end
                ns.out:Write("This operation took ", ns.Theme.Highlight, string.format("%.2f", (debugprofilestop() - loopStart)), "ms", ns.Theme.Reset, "!")
            end
        end
        
        -- loop with a 10ms budget and 10 items scrapped budget to keep the game playable
        -- TIME BUDGET:
        -- this all runs on the main(?) thread, so the idea is to try and reduce stuttering at the cost of operation speed
        -- it's important to note that the one call to ATT can take many times the loop budget
        -- without the ATT rule, you will very likely never hit the 10ms budget
        -- SCRAPPED BUDGET:
        -- the game only allows you to queue up a certain number of container actions at a time. normally, this is 12, but
        -- sometimes i've seen this be 10 for... reasons?
        -- when we've queued up our 10 items, we'll listen for 10 BAG_UPDATE events in order to continue
        bagLoop(0, 1, 0, 10, 10, bagLoop, afterLoop)
    end
end)

_ScrapHead = ns
function _ScrapHeadItem(link)
    return string.match(link, "item[%-?%d:]+")
end