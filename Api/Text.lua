local addonName, ns = ...

local Text = {}
Text.__index = Text

function Text:New()
    local localText = {}
    setmetatable(localText, Text)
    self.__index = self


    return localText
end

function Text:Write(...)
    local line = ""

    for _, v in ipairs({ ... }) do
        local part = tostring(v)
        if part:sub(1, 1) == "#" then
            part = "\124cFF" .. part:sub(2)
        elseif part == "<r>" then
            part = "\124r"
        end

        line = line .. part
    end

    print("\124cFFFBBF24[" .. addonName .. "]: \124r" .. line)
end

ns.Class.Text = Text
-- init default output
ns.out = Text:New()