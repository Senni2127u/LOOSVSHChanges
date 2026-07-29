//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_secondary = null;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS
	}

	function OnApply()
	{
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);


		if (WeaponIs(weapon_secondary, "shotgun"))
		{
			weapon_secondary.AddAttribute("damage bonus", 1.40, -1);
			weapon_secondary.AddAttribute("weapon spread bonus", 0.7, -1);
			weapon_secondary.AddAttribute("reload time decreased", 0.85, -1);
		}
		if (WeaponIs(weapon_secondary, "family_business"))
		{
			weapon_secondary.AddAttribute("weapon spread bonus", 0.7, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
		}
		if (WeaponIs(weapon_secondary, "panic_attack"))
		{
			weapon_secondary.AddAttribute("weapon spread bonus", 0.6, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
		}
		if (WeaponIs(weapon_secondary, "sandvich"))
		{
			// Delfite: Small Medkits: 60 health -> 90 health
			// Delfite: Medium Medkits: 150 health -> 225 health
			weapon_secondary.AddAttribute("health from packs increased", 1.50, -1);
		}
		//if (WeaponIs(weapon_secondary, "dalokohs_bar"))
		//{
			//weapon_secondary.AddAttribute("lunchbox adds maxhealth bonus", 0, -1); //Commented out due to issues with implementation, revisit at a later date. - Senni
			//weapon_secondary.AddAttribute("lunchbox healing decreased", 0.44, -1);
			//weapon_secondary.AddAttribute("charge recharge rate increased", 2, -1);
			//weapon_secondary.AddAttribute("max health additive bonus", 50, -1);
		//}
		if (WeaponIs(weapon_secondary, "buffalo_steak_sandvich"))
		{
			weapon_secondary.AddAttribute("energy buff dmg taken multiplier", 1.0, -1);
		}
		// if (weapon_secondaryIs(weapon_secondary, "second_banana"))
		// {

		// }
		player.Regenerate(true)
	}

	function OnDiscard()
    {
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("health from packs increased");
            weapon_secondary.RemoveAttribute("lunchbox adds maxhealth bonus");
            weapon_secondary.RemoveAttribute("lunchbox healing decreased");
            weapon_secondary.RemoveAttribute("charge recharge rate increased");
            weapon_secondary.RemoveAttribute("max health additive bonus");
            weapon_secondary.RemoveAttribute("energy buff dmg taken multiplier");
            weapon_secondary.RemoveAttribute("damage penalty");
        }
    }
});
