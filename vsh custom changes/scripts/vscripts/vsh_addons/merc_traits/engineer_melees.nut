// Script by: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)
// This script handles everything to do with Engineer's melees.

characterTraitsClasses.push(class extends CharacterTrait
{
	// weapon_primary = null;
	// weapon_melee = null;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

	function OnApply()
	{
		// weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		// weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
		local weapon_builder = player.GetWeaponBySlot(TF_WEAPONSLOTS.TOOLBOX);
		local toolbox = weapon_builder;

		if (WeaponIs(weapon_melee, "wrench"))
		{
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.2, -1);
			toolbox.AddAttribute("mult_player_movespeed_active", 1.2, -1);
		}
		if (WeaponIs(weapon_melee, "jag"))
		{
			weapon_melee.AddAttribute("engy sentry radius increased", 1.15, -1)
		}
		if (WeaponIs(weapon_melee, "eureka_effect"))
		{
			weapon_melee.AddAttribute("engineer building teleporting pickup", 100, -1)
			weapon_melee.AddAttribute("mod teleporter cost", 1, -1)
		}
		if (WeaponIs(weapon_melee, "southern_hospitality"))
		{
			weapon_melee.AddAttribute("engy dispenser radius increased", 3, -1)
			// weapon_melee.AddAttribute("heal rate bonus", 2, -1)
		}
		if (WeaponIs(weapon_melee, "gunslinger"))
		{
		}
	}

	function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("move speed bonus");
        }
        if (weapon_melee && weapon_melee.IsValid())
        {
			weapon_melee.RemoveAttribute("engy dispenser radius increased")
			weapon_melee.RemoveAttribute("move speed bonus")
			weapon_melee.RemoveAttribute("provide on active")
        }
    }
});