// Script by Senni, Assistance from Bradasparky.
// Script handles Scout's Backscatter accuracy increase.
// This script requires modification to weapon_primarys.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        if (WeaponIs(weapon_primary, "scattergun"))
        {
            weapon_primary.AddAttribute("damage bonus", 1.30, -1);
        }
        if (WeaponIs(weapon_primary, "backscatter"))
        {
            weapon_primary.AddAttribute("spread penalty", 1.0, -1);
        }
        if (WeaponIs(weapon_primary, "shortstop"))
        {
            weapon_primary.AddAttribute("weapon spread bonus", 0.35, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.9, -1);
            weapon_primary.AddAttribute("damage bonus", 1.15, -1);
        }
    }

    function OnDiscard()
	{
		// Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("weapon spread bonus");
            weapon_primary.RemoveAttribute("reload time decreased");
            //printl("Secondary attributes discarded.")
        }
	}
});