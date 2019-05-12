CasingModeWeaponSwitch = CasingModeWeaponSwitch or {}

function CasingModeWeaponSwitch:forbid_state(unit)
    local state = unit:movement():current_state_name()

    return unit == managers.player:local_player() and HuskPlayerMovement.clean_states[state]
end

if RequiredScript == "lib/units/beings/player/playerinventory" then
    local PlayerInventorySynchGadget = PlayerInventory.synch_gadget_state
    local PlayerInventorySynchWeapon = PlayerInventory.synch_equipped_weapon

    function PlayerInventory:synch_gadget_state(...)
        if not CasingModeWeaponSwitch:forbid_state(self._unit) then
            PlayerInventorySynchGadget(self, ...)
        else
            PlayerInventorySynchGadget(self)
        end
    end

    function PlayerInventory:synch_equipped_weapon(...)
        if not CasingModeWeaponSwitch:forbid_state(self._unit) then
            PlayerInventorySynchWeapon(self, ...)
        end
    end
else
    local HookClass = PlayerMaskOff or PlayerClean
    local HookClassUpdateCheckActions = HookClass._update_check_actions

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

        player_inventory:hide_equipped_unit()
    end
end