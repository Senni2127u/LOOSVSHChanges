//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
	// weapon_secondary = null;

	function CanApply() //Since these changes only apply to demoman, we only need to check if the player is a demoman. -Delfite
	{
		return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
	}

	function OnApply()
	{
		// weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);

		//printl(weapon_secondary_index) //Debug
		if (WeaponIs(weapon_secondary, "any_stickybomb_launcher"))
		{
			weapon_secondary.AddAttribute("Projectile speed increased", weapon_secondary.GetAttribute("Projectile speed increased", 1.0) + 0.20, -1)
			if (WeaponIs(weapon_secondary, "stickybomb_launcher"))
			{
				// Delfite: I originally gave the stock launcher a damage bonus to make its damage similar to the SR, but it turns out even a 10% bonus
				// significantly increases the amount of damage those 8 stickies can deal, especially if critboosted. Due to this, I realized that the
				// damage bonus wasn't really necessary and didn't cover any weakness the stock launcher had. All it really needed was some agility.
				// weapon_secondary.AddAttribute("damage bonus", 1.10, -1)
				weapon_secondary.AddAttribute("Blast radius increased", 1.2, -1)
				weapon_secondary.AddAttribute("fire rate bonus", 0.75, -1)
				// printl("Stickybomb Launcher stats applied.")
			}
			// Delfite: The Scottish Resistance benefits from being able to set up multiple traps. Paired with Engineer buildings, it can be an incredibly
			// powerful weapon, but on its own it's not very strong due to how long it takes to set up each trap, as well as requiring both the user to be
			// smart enough to take advantage of the weapon's unique attribute and Hale to lack the awareness needed to spot the player's traps.
			// With these downsides in mind, I decided to make the weapon a little more agile by making it reload faster, but nerfing its damage slightly
			// to compensate, since stacking 14 stickies in one trap still does an enormous amount of damage and knockback to Hale.
			else if (WeaponIs(weapon_secondary, "scottish_resistance"))
			{
				weapon_secondary.AddAttribute("damage penalty", 0.9, -1)
				weapon_secondary.AddAttribute("Reload time decreased", 0.85, -1)
			}
			// Delfite: The quickiebomb launcher, due to its short arm time, is generally better as an offensive implement than a trapping tool.
			// As a result, I decided to buff its blast radius to make hitting Hale with the explosions easier.
			else if (WeaponIs(weapon_secondary, "quickiebomb_launcher"))
			{
				weapon_secondary.AddAttribute("Blast radius increased", 1.5, -1)
				weapon_secondary.AddAttribute("clip size penalty", 0.75, -1)
				weapon_secondary.AddAttribute("max pipebombs decreased", -2, -1)
			}
			player.Regenerate(true);
			// Delfite: Regenerate the player so they start with full health and a reloaded magazine.
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