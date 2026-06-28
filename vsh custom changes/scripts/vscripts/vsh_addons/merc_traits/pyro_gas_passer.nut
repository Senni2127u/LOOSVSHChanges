// Script by Senni, Assistance from Bradasparky/Horiuchi
// Script handles Pyro's Gas Passer exploding on ignite, slightly reduces charge rate and sets the damage for a full charge to 800 instead of typical 750.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        if (WeaponIs(weapon, "gas_passer"))
        {
            weapon.AddAttribute("explode_on_ignite", 1, -1);
            weapon.AddAttribute("single wep deploy time decreased", 0.85, -1);
            weapon.AddAttribute("switch from wep deploy time decreased", 0.85, -1);
            weapon.AddAttribute("item_meter_damage_for_full_charge", 800, -1);
        }
    }
});