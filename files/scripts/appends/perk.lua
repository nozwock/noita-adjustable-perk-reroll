local __original_fn = perk_pickup
function perk_pickup(...)
  local forever_reroll = ModSettingGet("adjustable-perk-reroll.forever_reroll") --[[@as boolean]]

  local __EntityGetInRadiusWithTag = EntityGetInRadiusWithTag
  function EntityGetInRadiusWithTag(...)
    if ({ ... })[4] == "perk_reroll_machine" and forever_reroll then
      EntityGetInRadiusWithTag = __EntityGetInRadiusWithTag
      return {}
    end
    return __EntityGetInRadiusWithTag(...)
  end

  local ok, result = pcall(__original_fn, ...)
  if not ok then print(result) end

  EntityGetInRadiusWithTag = __EntityGetInRadiusWithTag
end
