if RequiredScript == "lib/units/beings/player/huskplayermovement" then
    local HuskPlayerMovementSwitch = HuskPlayerMovement._can_play_weapon_switch_anim

    function HuskPlayerMovement:_can_play_weapon_switch_anim()
        if not self.clean_states[self._state] then
            return HuskPlayerMovementSwitch(self)
        end

        return false
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