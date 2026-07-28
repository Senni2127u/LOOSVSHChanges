//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_secondary = null;

	function CanApply() //Since these changes only apply to demoman, we only need to check if the player is a demoman. -Delfite
	{
		return player.GetPlayerClass() == TF_CLASS_SNIPER;
	}

	function OnApply()
	{
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);


		// Delfite: This rebalance of the SMG is intended to make it a TRUE SMG.
		// High rate of fire, good damage, but mandates that you stay relatively close to your target to deal good damage.
		if (WeaponIs(weapon_secondary, "smg"))
		{
			weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1)
			// +15% fire rate. Make the SMG a proper machine gun!
			weapon_secondary.AddAttribute("damage bonus", 2, -1)
			// Damage per bullet: 8 -> 16 (1 damage more than pistol), compensates for falloff just a bit, and makes sniper a serious threat if kritz'd.
			weapon_secondary.AddAttribute("maxammo secondary increased", 2.67, -1)
			// 200 spare rounds.
			weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
			// Perfectly accurate.
			// printl("SMG stats applied.")
		}
		// Delfite: This rebalance of the Cleaner's Carbine is intended to make it better at mid-range combat.
		// The damage is still worse than the SMG's, but on-demand mini-crits combined with the accuracy bonus turn it into quite the long-range support tool.
		if (WeaponIs(weapon_secondary, "cleaners_carbine"))
		{
			weapon_secondary.AddAttribute("fire rate penalty", 1.0, -1)
			// No fire rate penalty. This is an SMG, not a lever-action rifle.
			weapon_secondary.AddAttribute("damage bonus", 1.75, -1)
			// Damage per bullet: 8 -> 14 (1 damage less than pistol)
			weapon_secondary.AddAttribute("maxammo secondary increased", 2.67, -1)
			// 200 spare rounds.
			weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
			// Perfect accuracy.
			// printl("Cleaner's Carbine stats applied.")
		}
		player.Regenerate(true)
		//TODO: Give Hitman's Heatmaker faster reload speed and faster charge rate while Focus is active.
	}

	function OnDiscard()
    {
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("fire rate bonus");
            weapon_secondary.RemoveAttribute("damage bonus");
            weapon_secondary.RemoveAttribute("maxammo secondary increased");
            weapon_secondary.RemoveAttribute("weapon spread bonus");
        }
    }
})