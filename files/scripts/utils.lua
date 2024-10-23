local const = dofile_once("mods/adjustable-perk-reroll/files/scripts/const.lua") ---@type const

---@class utils
local utils = {}

---@param id string
function utils:ResolveModSettingId(id) return const.MOD_ID .. "." .. id end

---@param id string
function utils:ModSettingGet(id) return ModSettingGet(self:ResolveModSettingId(id)) end

---@param id string
---@return number
function utils:ModSettingGetNumber(id)
  return utils:ModSettingGet(id) --[[@as number]]
end

return utils
