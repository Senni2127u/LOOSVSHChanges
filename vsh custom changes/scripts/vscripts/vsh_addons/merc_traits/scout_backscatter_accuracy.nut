// Script by Senni, Assistance from Bradasparky.
// Script handles Scout's Backscatter accuracy increase.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        if (WeaponIs(weapon, "backscatter"))
        {
            weapon.AddAttribute("weapon spread bonus", 1.2, -1);
        }
    }
});