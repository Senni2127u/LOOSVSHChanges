// Script by: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)
// This script handles everything to do with Heavy's melees.

characterTraitsClasses.push(class extends CharacterTrait
{
	// weapon_melee = null;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS
	}

	function OnApply()
	{
		// weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

		if (WeaponIs(weapon_melee, "fists"))
		{
			weapon_melee.AddAttribute("fire rate bonus", 0.8, -1);
		}
		if (WeaponIs(weapon_melee, "gru"))
		{
			weapon_melee.AddAttribute("damage penalty", 0.7, -1);
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.3, -1);
			weapon_melee.AddAttribute("mod_maxhealth_drain_rate", 0, -1);
		}
		if (WeaponIs(weapon_melee, "eviction_notice"))
		{
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.15, -1);
			// weapon_melee.AddAttribute("move speed bonus", 1.15, -1);
			// weapon_melee.AddAttribute("provide on active", 1, -1);
			weapon_melee.AddAttribute("speed_boost_on_hit", 8, -1);
			weapon_melee.AddAttribute("fire rate bonus", 0.9, -1);
			weapon_melee.AddAttribute("mod_maxhealth_drain_rate", 0, -1);
			// Delfite: Max health drain has been taken out back and blasted with a shotgun.
			// Please, do not ever use this attribute on a weapon.
			weapon_melee.AddAttribute("damage penalty", 0.5, -1);
			// Delfite: Damage penalty: 60% -> 50%
		}
		if (WeaponIs(weapon_melee, "fists_of_steel"))
		{
			weapon_melee.AddAttribute("dmg from melee increased", 1, -1);
			// Delfite: No, Hale should not be able to 1-shot a Heavy while he has this item out.
			weapon_melee.AddAttribute("single wep holster time increased", 1.5, -1);
		}
		if (WeaponIs(weapon_melee, "warriors_spirit"))
		{
			weapon_melee.AddAttribute("dmg taken increased", 1, -1);
			// Delfite: Again with the damage vulns on melees Valve...
			// Delfite: It at least made sense on the Fists of Steel, but why this item?!
			weapon_melee.AddAttribute("single wep holster time increased", 1.5, -1);
		}
		player.Regenerate(true)
	}

	function OnDamageDealt(victim, params)
    {
        if (params.damage_type & 128 && player.GetHealth() < player.GetMaxHealth() && WeaponIs(params.weapon, "warriors_spirit"))
            player.SetHealth(clampCeiling(player.GetHealth() + 50, player.GetMaxHealth()));
		else if ((params.damage_type & 128) && WeaponIs(params.weapon, "kgb"))
            player.AddCondEx(TF_COND_CRITBOOSTED_ON_KILL, 5, null);
    }
});