// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's Black Box HP on hit increase.
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
        if (WeaponIs(weapon, "blackbox"))
        {
            weapon.AddAttribute("health on radius damage" 50, -1);
        }
    }
});