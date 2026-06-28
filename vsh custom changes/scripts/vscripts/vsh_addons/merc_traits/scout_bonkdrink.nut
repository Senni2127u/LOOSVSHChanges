// Script by Senni, Assistance from Bradasparky.
// Script handles Scout's Bonk Atomic Punch recharge time.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        if (WeaponIs(weapon, "bonkatomicpunch"))
        {
            weapon.AddAttribute("effect bar recharge rate increased", 0.65, -1);
        }
    }
});