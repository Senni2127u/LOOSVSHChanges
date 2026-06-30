// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's Beggar's Bazooka deviation removal.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        if (WeaponIs(weapon, "beggarsbazooka"))
        {
            weapon.AddAttribute("projectile spread angle penalty" 0, -1);
        }
    }
});