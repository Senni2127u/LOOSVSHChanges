//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
	{
		function CanApply()
		{
			return player.GetPlayerClass() == TF_CLASS_SOLDIER
		}

		function OnApply()
		{
			local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
			//printl(weapon)
			if (WeaponIs(weapon, "escape_plan"))
			{
				weapon.AddAttribute("self mark for death", 0, -1);
			}
		}
	}
);