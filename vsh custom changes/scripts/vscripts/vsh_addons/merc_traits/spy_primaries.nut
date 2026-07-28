// Script by: Delfite


characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnApply()
    {
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "any_revolver"))
        {
            weapon_primary.AddAttribute("weapon spread bonus", 0.0, -1)
            weapon_primary.AddAttribute("maxammo secondary increased", 2.0, -1)
			if (WeaponIs(weapon_primary, "revolver"))
			{
				weapon_primary.AddAttribute("damage bonus", 2.0, -1)
				weapon_primary.AddAttribute("fire rate bonus", 0.85, -1)
				weapon_primary.AddAttribute("reload time decreased", 0.85, -1)
			}
			if (WeaponIs(weapon_primary, "ambassador"))
			{
				weapon_primary.AddAttribute("damage penalty", 0.8, -1)
				weapon_primary.AddAttribute("headshot damage increase", 2.25, -1)
				weapon_primary.AddAttribute("crit_dmg_falloff", 0, -1)
				weapon_primary.AddAttribute("reload time decreased", 0.85, -1)
			}
			if (WeaponIs(weapon_primary, "diamondback"))
			{
				weapon_primary.AddAttribute("damage penalty", 1.0, -1)
			}
			if (WeaponIs(weapon_primary, "enforcer"))
			{
				weapon_primary.AddAttribute("fire rate penalty", 1.0, -1)
			}
			if (WeaponIs(weapon_primary, "letranger"))
			{
				// Delfite: Nothing. This revolver already serves its purpose very well.
			}
        }
		player.Regenerate(true)
    }

	function OnDiscard()
	{
		// Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("move speed bonus");
            weapon_primary.RemoveAttribute("provide on active");
            //printl("Secondary attributes discarded.")
        }
	}
});