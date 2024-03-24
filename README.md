# ScrapHead

a (better?) addon to manage scrapping of items, with advanced rules to filter out most common scrappable items for you

## how it works

rules are defined in the `Rules` directory. at present:

- `IsJunk.lua` is for, well, junk;
- `BelowAuctionPrice.lua` works in combination with TSM4 to determine if a sellable item is going for <95% of its vendor price;
- `UselessBOP.lua` finds all BOP items that are useless for you (10 or more levels lower; not in an equipment set; not equippable)
- `CollectedAllThings.lua` works in combination with All The Things to determine if you've completed everything for a given item