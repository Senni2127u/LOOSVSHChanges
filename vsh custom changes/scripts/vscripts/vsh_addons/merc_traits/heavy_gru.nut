//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
	{
		function CanApply()
		{
			return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS
		}

		function OnApply()
		{
			local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
			if (WeaponIs(weapon, "gru"))
			{
				weapon.AddAttribute("mod_maxhealth_drain_rate", 0, -1);
				//weapon.AddAttribute("self mark for death", 1, -1); //Used to test if the weapon attributes are applying to the correct weapon or not. -Delfite
				//printl(weapon)
			}
		}
	}
);
