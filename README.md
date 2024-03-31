# ScrapHead

an addon to manage scrapping of items, with rules to filter out most common scrappable items for you

**DISCLAIMER:** when you log in to a character, open your character tab (default bind: `C`) to cache your equipment sets. this is used by the `UselessBOP` rule and may cause issues otherwise for legacy/timewalking sets

## how it works

rules are defined in the `Rules` directory. at present:

- `IsJunk.lua` is for, well, junk;
- `BelowAuctionPrice.lua` works in combination with TSM4 to determine if a sellable item is going for <95% of its vendor price;
- `UselessBOP.lua` finds all BOP items that are useless for you (10 or more levels lower; not in an equipment set; not equippable)
- `CollectedAllThings.lua` works in combination with All The Things to determine if you've completed everything for a given item
- `ArtifactRelics.lua` scraps all artifact relics