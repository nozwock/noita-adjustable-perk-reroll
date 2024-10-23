dofile("data/scripts/lib/mod_settings.lua")

local MOD_ID = "adjustable-perk-reroll" -- This should match the name of your mod's folder.
mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.

---@param local_id string
local function ResolveModSettingId(local_id) return MOD_ID .. "." .. local_id end

---@param fn fun(a, b):boolean
---@param a any
---@param ... any
local function All(fn, a, ...)
  for _, b in ipairs({ ... }) do
    if not fn(a, b) then return false end
  end
  return true
end

---@param fn fun(a, b):boolean
---@param a any
---@param ... any
local function Any(fn, a, ...)
  for _, b in ipairs({ ... }) do
    if fn(a, b) then return true end
  end
  return false
end

---@param number number
---@param decimal? integer
local function TruncateNumber(number, decimal)
  if decimal and decimal <= 0 then decimal = nil end
  local pow = 10 ^ (decimal or 0)
  return math.floor(number * pow) / pow
end

---@param number number
local function FloorSliderValueInteger(number)
  return math.floor(number + 0.5) -- Because the slider can return ranging from 1.8 to 2.3 while showing 2, just as an example
end

---@param number number
---@param decimal? integer
local function FloorSliderValueFloat(number, decimal)
  if not decimal or decimal <= 0 then decimal = 0 end
  local pow = 10 ^ (decimal + 1)
  return TruncateNumber(number + 5 / pow, decimal)
end

---@class enum_variant_detail
---@field ui_name string
---@field ui_description string
---@alias enum_variant integer|string
---@alias enum_variant_details { [enum_variant]: enum_variant_detail }

---Order of variants determines the order.
---
---Very little sanity checks in place. Don't pass in empty lists, etc.
---@param variants enum_variant[]
---@param variant_details enum_variant_details
local function CreateGuiSettingEnum(variants, variant_details)
  return function(mod_id, gui, in_main_menu, im_id, setting)
    local setting_id = mod_setting_get_id(mod_id, setting)
    local prev_value = ModSettingGetNextValue(setting_id) or setting.value_default

    GuiLayoutBeginHorizontal(gui, mod_setting_group_x_offset, 0, true)

    local value = nil

    if variant_details[prev_value] == nil then prev_value = setting.value_default end

    if GuiButton(gui, im_id, 0, 0, setting.ui_name .. ": " .. variant_details[prev_value].ui_name) then
      for i, v in ipairs(variants) do
        if prev_value == v then
          value = variants[i % #variants + 1]
          break
        end
      end
    end
    local right_clicked, hovered = select(2, GuiGetPreviousWidgetInfo(gui))
    if right_clicked then
      value = setting.value_default
      GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
    end
    if hovered and is_visible_string(variant_details[prev_value].ui_description) then
      GuiTooltip(gui, variant_details[prev_value].ui_description, "")
    end

    GuiLayoutEnd(gui)

    if value ~= nil then
      ModSettingSetNextValue(setting_id, value, false)
      mod_setting_handle_change_callback(mod_id, gui, in_main_menu, setting, prev_value, value)
    end
  end
end

---@param mod_id string
---@param gui gui
---@param in_main_menu boolean
---@param im_id integer
---@param setting table
---@param value_formatting string
---@param value_display_multiplier? number
---@param value_map? fun(value:number):number
local function ModSettingSlider(
  mod_id,
  gui,
  in_main_menu,
  im_id,
  setting,
  value_formatting,
  value_display_multiplier,
  value_map
)
  local empty = "data/ui_gfx/empty.png"
  local setting_id = mod_setting_get_id(mod_id, setting)
  local value = ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))
  if type(value) ~= "number" then value = setting.value_default or 0.0 end

  GuiLayoutBeginHorizontal(gui, mod_setting_group_x_offset, 0, true)

  if setting.value_min == nil or setting.value_max == nil or setting.value_default == nil then
    GuiText(gui, 0, 0, setting.ui_name .. " - not all required values are defined in setting definition")
    return
  end

  GuiText(gui, 0, 0, "")
  local x_start, y_start = select(4, GuiGetPreviousWidgetInfo(gui))

  GuiIdPushString(gui, MOD_ID .. setting_id)

  local value_new = GuiSlider(
    gui,
    im_id,
    -2,
    0,
    setting.ui_name,
    value,
    setting.value_min,
    setting.value_max,
    setting.value_default,
    setting.value_slider_multiplier or 1, -- This affects the steps for slider aswell, so it's not just a visual thing.
    " ",
    64
  )
  if value_map then value_new = value_map(value_new) end

  local x_end, _, w = select(4, GuiGetPreviousWidgetInfo(gui))
  local display_text = string.format(value_formatting, value_new * (value_display_multiplier or 1))
  local tw = GuiGetTextDimensions(gui, display_text)

  GuiColorSetForNextWidget(gui, 0.8, 0.8, 0.8, 1)
  GuiText(gui, 0, 0, display_text)

  GuiIdPop(gui)
  GuiLayoutEnd(gui)

  GuiImageNinePiece(gui, im_id + 1, x_start, y_start, x_end - x_start + w + tw - 2, 8, 0, empty, empty)

  mod_setting_tooltip(mod_id, gui, in_main_menu, setting)

  if value ~= value_new then
    ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), value_new, false)
    mod_setting_handle_change_callback(mod_id, gui, in_main_menu, setting, value, value_new)
  end
end

local function mod_setting_integer(mod_id, gui, in_main_menu, im_id, setting)
  ModSettingSlider(
    mod_id,
    gui,
    in_main_menu,
    im_id,
    setting,
    setting.value_display_formatting or " %d",
    setting.value_display_multiplier,
    function(value) return FloorSliderValueInteger(value) end
  )
end

local function mod_setting_float(mod_id, gui, in_main_menu, im_id, setting)
  ModSettingSlider(
    mod_id,
    gui,
    in_main_menu,
    im_id,
    setting,
    setting.value_display_formatting or " %.1f",
    setting.value_display_multiplier,
    function(value) return FloorSliderValueFloat(value, setting.value_precision) end
  )
end

mod_settings = {
  {
    id = "price_start",
    ui_name = "Price Start",
    ui_description = "The initial cost of a reroll.",
    value_default = 2,
    value_min = 0,
    value_max = 10,
    value_precision = 1,
    value_display_multiplier = 100,
    value_display_formatting = " $ %d",
    ui_fn = mod_setting_float,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "price_growth",
    ui_name = "Price Growth",
    ui_description = "The percentage increase in reroll cost after each use.",
    value_default = 1,
    value_min = 0,
    value_max = 4,
    value_precision = 1,
    value_display_multiplier = 100,
    value_display_formatting = " $ +%d%%",
    ui_fn = mod_setting_float,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "price_cap",
    ui_name = "Price Cap",
    ui_description = "The maximum possible cost a reroll can reach.\nA value of 0 indicates that there is no price cap.",
    value_default = 10,
    value_min = 0,
    value_max = 20,
    value_precision = 1,
    value_display_formatting = " $ %.1fK",
    ui_fn = mod_setting_float,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "forever_reroll",
    ui_name = "Forever Reroll Machine",
    ui_description = "The reroll machine will remain active after selecting a perk.",
    value_default = false,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
}

-- This function is called to ensure the correct setting values are visible to the game via ModSettingGet(). your mod's settings don't work if you don't have a function like this defined in settings.lua.
-- This function is called:
--		- when entering the mod settings menu (init_scope will be MOD_SETTINGS_SCOPE_ONLY_SET_MOD_IDDEFAULT)
-- 		- before mod initialization when starting a new game (init_scope will be MOD_SETTING_SCOPE_NEW_GAME)
--		- when entering the game after a restart (init_scope will be MOD_SETTING_SCOPE_RESTART)
--		- at the end of an update when mod settings have been changed via ModSettingsSetNextValue() and the game is unpaused (init_scope will be MOD_SETTINGS_SCOPE_RUNTIME)
function ModSettingsUpdate(init_scope)
  local old_version = mod_settings_get_version(MOD_ID) -- This can be used to migrate some settings between mod versions.
  mod_settings_update(MOD_ID, mod_settings, init_scope)
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic.
-- The value will be used to determine whether or not to display various UI elements that link to mod settings.
-- At the moment it is fine to simply return 0 or 1 in a custom implementation, but we don't guarantee that will be the case in the future.
-- This function is called every frame when in the settings menu.
function ModSettingsGuiCount() return mod_settings_gui_count(MOD_ID, mod_settings) end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui(gui, in_main_menu) mod_settings_gui(MOD_ID, mod_settings, gui, in_main_menu) end
