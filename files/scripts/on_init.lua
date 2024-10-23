-- Patches
local strmanip = dofile_once("mods/adjustable-perk-reroll/files/scripts/lib/stringmanip.lua") ---@type StringManip

local file = strmanip:new("data/scripts/perks/perk_reroll_init.lua")
file:AppendBefore(ModTextFileGetContent("mods/adjustable-perk-reroll/files/scripts/patches/perk_reroll_init.lua"))
file:Write()

-- Appends
ModLuaFileAppend("data/scripts/perks/perk.lua", "mods/adjustable-perk-reroll/files/scripts/appends/perk.lua")
