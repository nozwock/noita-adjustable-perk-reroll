dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "adjustable-perk-reroll" -- This should match the name of your mod's folder.
mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.

mod_settings = {
  {
    id = "price_start",
    ui_name = "Price Start",
    value_default = 2,
    value_min = 1,
    value_max = 4,
    value_display_multiplier = 100,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "price_growth",
    ui_name = "Price Growth",
    value_default = 1,
    value_min = 0,
    value_max = 2,
    value_display_multiplier = 100,
    value_display_formatting = " +$0% cost",
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "price_cap",
    ui_name = "Price Cap",
    value_default = 2,
    value_min = 0,
    value_max = 100,
    value_display_formatting = " $0k",
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "forever_reroll",
    ui_name = "Forever Reroll Machine",
    ui_description = "Reroll machine wouldn't be disabled on picking a perk.",
    value_default = false,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
}

-- This function is called to ensure the correct setting values are visible to the game via ModSettingGet(). your mod's settings don't work if you don't have a function like this defined in settings.lua.
-- This function is called:
--		- when entering the mod settings menu (init_scope will be MOD_SETTINGS_SCOPE_ONLY_SET_DEFAULT)
-- 		- before mod initialization when starting a new game (init_scope will be MOD_SETTING_SCOPE_NEW_GAME)
--		- when entering the game after a restart (init_scope will be MOD_SETTING_SCOPE_RESTART)
--		- at the end of an update when mod settings have been changed via ModSettingsSetNextValue() and the game is unpaused (init_scope will be MOD_SETTINGS_SCOPE_RUNTIME)
function ModSettingsUpdate(init_scope)
  local old_version = mod_settings_get_version(mod_id) -- This can be used to migrate some settings between mod versions.
  mod_settings_update(mod_id, mod_settings, init_scope)
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic.
-- The value will be used to determine whether or not to display various UI elements that link to mod settings.
-- At the moment it is fine to simply return 0 or 1 in a custom implementation, but we don't guarantee that will be the case in the future.
-- This function is called every frame when in the settings menu.
function ModSettingsGuiCount() return mod_settings_gui_count(mod_id, mod_settings) end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui(gui, in_main_menu) mod_settings_gui(mod_id, mod_settings, gui, in_main_menu) end
