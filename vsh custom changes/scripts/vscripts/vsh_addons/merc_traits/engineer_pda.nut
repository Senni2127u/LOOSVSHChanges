//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
	{
		function CanApply()
		{
			return player.GetPlayerClass() == TF_CLASS_ENGINEER
		}

		function OnApply()
		{
			// local weapon_pda = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA);
			if (WeaponIs(weapon_pda, "pda"))
			{
				// weapon_pda.AddAttribute("engineer teleporter build rate multiplier", 3.0, -1)
				// weapon_pda.AddAttribute("bidirectional teleport", 1, -1);
				// weapon_pda.AddAttribute("maxammo metal increased", 1.5, -1); // Metal reserve: 200 -> 300
				// weapon_pda.AddAttribute("SET BONUS: dmg from sentry reduced", 0.1, -1);
				// weapon_pda.AddAttribute("rocket jump damage reduction", 0.1, -1);
				// weapon_pda.AddAttribute("mod teleporter cost", 0.5, -1);
				player.Regenerate(true)
			}
		}
	}
);