do
  local utils = dofile_once("mods/adjustable-perk-reroll/files/scripts/utils.lua") ---@type utils

  local price_start = utils:ModSettingGetNumber("price_start") * 100
  local price_growth = utils:ModSettingGetNumber("price_growth")
  local price_cap = utils:ModSettingGetNumber("price_cap") * 1000

  local __original_fn = math.pow
  function math.pow(_, perk_reroll_count)
    math.pow = __original_fn

    local cost = price_start * (1 + price_growth) ^ perk_reroll_count
    if price_cap ~= 0 then cost = math.min(cost, price_cap) end
    return cost / 200
  end
end
