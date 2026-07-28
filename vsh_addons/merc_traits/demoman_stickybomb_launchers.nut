//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_secondary = null;

	function CanApply() //Since these changes only apply to demoman, we only need to check if the player is a demoman. -Delfite
	{
		return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
	}

	function OnApply()
	{
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);

		//printl(weapon_secondary_index) //Debug
		if (WeaponIs(weapon_secondary, "any_stickybomb_launcher"))
		{
			weapon_secondary.AddAttribute("Projectile speed increased", weapon_secondary.GetAttribute("Projectile speed increased", 1.0) + 0.20, -1)
			if (WeaponIs(weapon_secondary, "stickybomb_launcher"))
			{
				weapon_secondary.AddAttribute("damage bonus", 1.10, -1)
				weapon_secondary.AddAttribute("Blast radius increased", 1.2, -1)
				weapon_secondary.AddAttribute("fire rate bonus", 0.75, -1)
				// printl("Stickybomb Launcher stats applied.")
			}
			//Purpose:
			//
			// else if (WeaponIs(weapon_secondary, "scottish_resistance"))
			// {
			// 	weapon_secondary.AddAttribute("Reload time decreased", 0.9, -1)
			// }
			//Purpose: The quickiebomb launcher, due to its short arm time, is generally better as an offensive implement than a trapping tool.
			//As a result, I decided to buff its blast radius to make hitting Hale with the explosions easier.
			else if (WeaponIs(weapon_secondary, "quickiebomb_launcher"))
			{
				weapon_secondary.AddAttribute("Blast radius increased", 1.5, -1)
				weapon_secondary.AddAttribute("clip size penalty", 0.75, -1)
				weapon_secondary.AddAttribute("max pipebombs decreased", -2, -1)
			}
			player.Regenerate(true);
			// Delfite: Regenerate the player so they start with full health and a reloaded magazine.
			//TODO: Make stickybomb launchers auto-reload.
		}
	}

	function OnDiscard()
    {
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("max health additive bonus");
            weapon_secondary.RemoveAttribute("Projectile speed increased");
            weapon_secondary.RemoveAttribute("Reload time decreased");
            weapon_secondary.RemoveAttribute("maxammo secondary increased");
            weapon_secondary.RemoveAttribute("rocket jump damage reduction");
            weapon_secondary.RemoveAttribute("damage bonus");
            weapon_secondary.RemoveAttribute("fire rate bonus");
            weapon_secondary.RemoveAttribute("Blast radius increased");
            weapon_secondary.RemoveAttribute("max pipebombs decreased");
        }
    }
})