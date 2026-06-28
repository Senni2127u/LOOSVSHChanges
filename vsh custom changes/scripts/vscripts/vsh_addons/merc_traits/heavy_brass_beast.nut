// Script by Senni, Assistance from Bradasparky.
// Script handles Heavy's Brass Beast speed penalty removal, and removal of damage penalty from Natascha.
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
        if (WeaponIs(weapon, "brassbeast"))
        {
            weapon.AddAttribute("aiming movespeed decreased", 1, -1);
        }
        else if (weaponIs(weapon, "natascha")) //Kill two birds with one stone.
        {
            weapon.addAttribute("damage penalty", 1, -1)
        }
    }
});