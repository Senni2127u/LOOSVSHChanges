// Script by Senni, Assistance from Bradasparky/Horiuchi
// Script handles Cloak and Dagger hiding usage as it mirrors stock watch, and no Cloak for Spy when cloaked.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA2);
        if (WeaponIs(weapon, "cloakanddagger"))
        {
            weapon.AddAttribute("set cloak is movement based", 0, -1);
            weapon.AddAttribute("mult cloak meter regen rate", 1, -1);
            weapon.AddAttribute("NoCloakWhenCloaked", 1, -1);
            weapon.AddAttribute("ReducedCloakFromAmmo", 1, -1);
        }
    }
});