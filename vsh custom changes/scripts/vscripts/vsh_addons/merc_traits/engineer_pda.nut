//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
	{
		function CanApply()
		{
			return player.GetPlayerClass() == TF_CLASS_ENGINEER
		}

		function OnApply()
		{
			local weapon_pda = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA);
			if (WeaponIs(weapon_pda, "pda"))
			{
				weapon_pda.AddAttribute("engineer teleporter build rate multiplier", 3.0, -1)
				weapon_pda.AddAttribute("bidirectional teleport", 1, -1);
			}
		}
	}
);