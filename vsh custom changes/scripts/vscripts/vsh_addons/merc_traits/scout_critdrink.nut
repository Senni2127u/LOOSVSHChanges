// Script by Senni, Assistance from Bradasparky.
// Script handles Scout's Crit a Cola and Bonk, reducing cooldown and removing marked for death.
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
        if (WeaponIs(weapon, "energydrink"))
        {
            weapon.AddAttribute("mod_mark_attacker_for_death", 0, -1);
            weapon.AddAttribute("effect bar recharge rate increased", 0.65, -1);
        }
    }
});
