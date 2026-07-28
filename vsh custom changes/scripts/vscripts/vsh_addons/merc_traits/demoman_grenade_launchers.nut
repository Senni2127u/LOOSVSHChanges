//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;

	function CanApply() //Since these changes only apply to demoman, we only need to check if the player is a demoman. -Delfite
	{
		return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
	}

	function OnApply()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

		//printl(weapon_primary) //Debug
		if (WeaponIs(weapon_primary, "any_grenade_launcher"))
		{
			weapon_primary.AddAttribute("max health additive bonus", 25, -1)
			// Delfite: Give demo 25 more health so he doesn't die in 1 hit. Boots should not be a hard requirement for preventing death.
			weapon_primary.AddAttribute("Projectile speed increased", weapon_primary.GetAttribute("Projectile speed increased", 1.0) + 0.25, -1)
			// Delfite: Projectiles are remarkably slow by default, and Hale is pretty dang fast. A little projectile speed should help bridge the gap.
			//printl("Generic Demoman primary stats applied.")
			if (WeaponIs(weapon_primary, "grenade_launcher"))
			{
				weapon_primary.AddAttribute("clip size bonus", weapon_primary.GetAttribute("clip size bonus", 1.0) + 0.5, -1)
				weapon_primary.AddAttribute("maxammo primary increased", weapon_primary.GetAttribute("maxammo primary increased", 1.0) + 0.5, -1)
				weapon_primary.AddAttribute("Reload time decreased", weapon_primary.GetAttribute("Reload time decreased", 1.0) - 0.20, -1)
				weapon_primary.AddAttribute("fire rate bonus", weapon_primary.GetAttribute("fire rate bonus", 1.0) - 0.15, -1)
				//printl("Grenade Launcher stats applied.")
			}
			//Purpose: Strengthen the Iron Bomber's identity as a pseudo-jumper weapon, at the cost of some of its damage output.
			//
			if (WeaponIs(weapon_primary, "iron_bomber"))
			{
				weapon_primary.AddAttribute("Blast radius increased", 1.35, -1)
				weapon_primary.AddAttribute("Projectile speed increased", weapon_primary.GetAttribute("Projectile speed increased", 1.0) + 0.15, -1)
				weapon_primary.AddAttribute("fuse bonus", weapon_primary.GetAttribute("fuse bonus", 1.0) - 0.50, -1)
				// Fuse time: From -30% -> -80%. Still lets you hit Hale at medium range while decreasing the interval between jumps to a reasonable level.
				weapon_primary.AddAttribute("rocket jump damage reduction", 0.7, -1)
				weapon_primary.AddAttribute("self dmg push force increased", 1.20, -1)
				weapon_primary.AddAttribute("maxammo primary increased", 1.5, -1)
				// weapon_primary.AddAttribute("self dmg push force increased", weapon_primary.GetAttribute("self dmg push force increased", 1.0) + 0.20, -1)
				weapon_primary.AddAttribute("damage penalty", 0.80, -1)
				//printl("Iron Bomber stats applied.")
			}
			//Purpose: Strengthen the Loch'n'load's identity as a hard-hitting, high-speed grenade launcher.
			//The main drawback of this item, that being the 3 grenades it has, now has a bigger gap due to the stock GL getting 6.
			if (WeaponIs(weapon_primary, "loch_n_load"))
			{
				// Delfite: I would've removed the attributes already on the weapon, but since they're static, we can't do that. Argh!
				weapon_primary.AddAttribute("damage bonus", weapon_primary.GetAttribute("damage bonus", 1.0) + 0.20, -1)
				// Delfite:	Hale isn't a building. As funny as that sounds out loud, we still need to give the Loch-n-Load a damage bonus.
				weapon_primary.AddAttribute("fire rate bonus", weapon_primary.GetAttribute("fire rate bonus", 1.0) - 0.20, -1)
				//printl("Loch-n-Load stats applied.")
			}
			// else if (WeaponIs(weapon_primary, "loose_cannon"))
			// {
			// 	weapon_primary.AddAttribute("", 0, -1)
			// 	weapon_primary.AddAttribute("damage penalty", weapon_primary.GetAttribute("damage bonus", 1.0) - 0.15, -1)
			// }
			player.Regenerate(true);
			// Delfite: If we don't regenerate the player, they'll start with health and ammo missing (bad).
		}
	}

	function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("max health additive bonus");
            weapon_primary.RemoveAttribute("Projectile speed increased");
            weapon_primary.RemoveAttribute("clip size bonus");
            weapon_primary.RemoveAttribute("maxammo primary increased");
            weapon_primary.RemoveAttribute("fuse bonus");
            weapon_primary.RemoveAttribute("rocket jump damage reduction");
            weapon_primary.RemoveAttribute("self dmg push force increased");
            weapon_primary.RemoveAttribute("dmg bonus vs buildings");
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("fire rate bonus");
            weapon_primary.RemoveAttribute("Reload time decreased");
        }
    }
})