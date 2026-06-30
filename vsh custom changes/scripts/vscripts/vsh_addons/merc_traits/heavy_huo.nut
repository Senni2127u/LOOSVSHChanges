// Script by Senni, Assistance from Bradasparky.
// Script handles Heavy's Huo Long Heater ammo consumption removal
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        if (WeaponIs(weapon, "huolongheater"))
        {
            weapon.AddAttribute("uses ammo while aiming", 0, -1);
        }
    }
});