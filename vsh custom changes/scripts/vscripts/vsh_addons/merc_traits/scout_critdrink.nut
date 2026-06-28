// Script by Senni, Assistance from Bradasparky.
// Script handles Scout's Crit a Cola, just removing Marked for Death here, CD remains the same as base game.
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
        if (WeaponIs(weapon, "critacola"))
        {
            weapon.AddAttribute("mod_mark_attacker_for_death", 0, -1);
        }
    }
});