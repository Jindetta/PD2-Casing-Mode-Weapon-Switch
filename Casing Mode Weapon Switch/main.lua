CasingModeWeaponSwitch = CasingModeWeaponSwitch or {}

function CasingModeWeaponSwitch:get(unit, has_weapon_ban)
    if has_weapon_ban ~= nil then
        has_weapon_ban = has_weapon_ban == self._weapons_banned
    end

    return unit == managers.player:local_player(), has_weapon_ban
end

if RequiredScript == "lib/units/beings/player/playerinventory" then
    local PlayerInventoryPlaceSelection = PlayerInventory._place_selection

    function PlayerInventory:_place_selection(index, equip)
        local player, ban = CasingModeWeaponSwitch:get(self._unit, true)

        if not player or not equip or not ban then
            PlayerInventoryPlaceSelection(self, index, equip)
        end
    end
elseif RequiredScript == "lib/units/beings/player/states/playerstandard" then
    local PlayerStandardStartActionEquip = PlayerStandard._start_action_equip

    function PlayerStandard:_start_action_equip(...)
        if CasingModeWeaponSwitch:get(self._unit) then
            CasingModeWeaponSwitch._weapons_banned = false
        end

        return PlayerStandardStartActionEquip(self, ...)
    end
else
    local HookClass = PlayerMaskOff or PlayerClean
    local HookClassUpdateCheckActions = HookClass._update_check_actions
    local HookClassEnter = HookClass._enter

    function HookClass:_enter(...)
        CasingModeWeaponSwitch._weapons_banned = true
        HookClassEnter(self, ...)
    end

    function HookClass:_update_check_actions(...)
        HookClassUpdateCheckActions(self, ...)
        self:_check_change_weapon(...)
    end

    function HookClass:_check_change_weapon(...)
        local player_inventory = self._ext_inventory
        local input = self:_get_input(...)

        if type(input.btn_primary_choice) == "number" then
            player_inventory:equip_selection(input.btn_primary_choice)
        elseif type(self._previous_equipped_selection) == "number" then
            player_inventory:equip_selection(self._previous_equipped_selection)
            self._previous_equipped_selection = nil
        elseif input.btn_switch_weapon_press then
            player_inventory:equip_next()
        end
    end
end