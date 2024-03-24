local _, ns = ...

ns.Api:AddRule(
    "Below Auction Price",
    function(itemStack)
        local auctionPrice = itemStack:GetAuctionPrice()
        if auctionPrice == 0 then return false end

        -- if auction price - AH fee is less than or the same as the vendor price,
        -- we're better off vendoring
        if (auctionPrice * 0.95) <= itemStack.itemData.sellPrice then
            return { action = "highlight" }
        else
            return false
        end
    end
)