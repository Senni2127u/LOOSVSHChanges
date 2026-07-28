// Script by Senni, Delfite, Assistance from Bradasparky/Horiuchi
// Script handles all things related to Spy's watches.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnApply()
    {
        local pda2 = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA2);

        if (pda2 != null)
            pda2.AddAttribute("move speed bonus", 1.20, -1);
        if (WeaponIs(pda2, "cloak_and_dagger"))
        {
            pda2.AddAttribute("set cloak is movement based", 0, -1);
            pda2.AddAttribute("mult cloak meter regen rate", 1, -1);
            pda2.AddAttribute("NoCloakWhenCloaked", 1, -1);
            pda2.AddAttribute("ReducedCloakFromAmmo", 1, -1);
        }
    }
});