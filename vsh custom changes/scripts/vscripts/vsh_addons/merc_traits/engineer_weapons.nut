// Script by: Delfite (I don't care if you use any of my code, just as long as you credit me. Open source stuff quite literally runs the world.)
// This script handles everything to do with Engineer's weapons.
// For code related to Engineer's buildings, please refer to `engineer_sentry.nut` in the vsh_overrides folder.

characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;
	weapon_secondary = null;
	weapon_melee = null;

	// Primary handles.
	Shotgun = null;
	Pomson = null;

	// Secondary handles.
	Wrangler = null;

	lastHitWasShotgun = false;
	pomsonCritNerfApplied = false;
	isWranglerNerfApplied = false;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

	function OnApply()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
		weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE)
		local pda = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA);
		local pda2 = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA2);	// Delfite: Destruction PDA.
		local toolbox = player.GetWeaponBySlot(TF_WEAPONSLOTS.TOOLBOX);

		// Primary definitions.
		if (WeaponIs(weapon_primary, "shotgun"))
		{
			Shotgun = weapon_primary
			// Shotgun.AddAttribute("damage bonus", 1.40, -1);
			Shotgun.AddAttribute("max health additive bonus", 25, -1);
			Shotgun.AddAttribute("weapon spread bonus", 0.7, -1);
			Shotgun.AddAttribute("reload time decreased", 0.75, -1);
		}
		else if (WeaponIs(weapon_primary, "panic_attack"))
		{
			weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1);
			weapon_primary.AddAttribute("damage penalty", 1.0, -1);
		}
		else if (WeaponIs(weapon_primary, "frontier_justice"))
		{
			weapon_primary.AddAttribute("bullets per shot bonus", 1.0, -1);
			weapon_primary.AddAttribute("fire rate bonus", 0.7, -1);
		}
		else if (WeaponIs(weapon_primary, "widowmaker"))
		{
			weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1);
		}
		else if (WeaponIs(weapon_primary, "rescue_ranger"))
		{
			weapon_primary.AddAttribute("fire rate bonus", 0.7, -1)
			weapon_primary.AddAttribute("mark for death on building pickup", 0, -1)
		}
		else if (WeaponIs(weapon_primary, "pomson_6000"))
		{
			Pomson = weapon_primary
            Pomson.AddAttribute("fire rate bonus", 0.80, -1);
            Pomson.AddAttribute("reload time decreased", 0.80, -1);
            Pomson.AddAttribute("dmg penalty vs players", 1.5, -1);
		}

		// Secondary definitions.
		if (WeaponIs(weapon_secondary, "pistol"))
        {
            weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1)
            weapon_secondary.AddAttribute("damage bonus", 1.20, -1)
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
		}
		else if (WeaponIs(weapon_secondary, "wrangler"))
        {
            Wrangler = weapon_secondary
            Wrangler.AddAttribute("deploy time decreased", 0.65, -1)
		}

		// Melee definitions.
		if (WeaponIs(weapon_melee, "wrench"))
		{
			weapon_melee.AddAttribute("Repair rate increased", 1.5, -1);
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			toolbox.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			pda.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			pda2.AddAttribute("mult_player_movespeed_active", 1.25, -1);
		}
		else if (WeaponIs(weapon_melee, "jag"))
		{
			weapon_melee.AddAttribute("engy sentry radius increased", 1.15, -1)
		}
		else if (WeaponIs(weapon_melee, "eureka_effect"))
		{
			weapon_melee.AddAttribute("engineer building teleporting pickup", 100, -1)
			weapon_melee.AddAttribute("mod teleporter cost", 1, -1)
		}
		else if (WeaponIs(weapon_melee, "southern_hospitality"))
		{
			weapon_melee.AddAttribute("engy dispenser radius increased", 3, -1)
			// weapon_melee.AddAttribute("heal rate bonus", 2, -1)
		}
		else if (WeaponIs(weapon_melee, "gunslinger"))
		{
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			toolbox.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			pda.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			pda2.AddAttribute("mult_player_movespeed_active", 1.25, -1);
		}
	}

	function OnTickAlive()
	{
		local active_weapon = player.GetActiveWeapon()
        if (Wrangler)
        {
            if (active_weapon == Wrangler)
            {
                if (isWranglerNerfApplied)
                    return;

				// Delfite: Turns out negating the wrangler's doubled fire rate is as simple as giving this attribute a value of 2.
                // This nerf - in practice, however - ended up being pretty harsh since sentries already deal half of their normal damage.
                // Reducing this value to 1.75 so the player can at least get a 25% fire rate bonus on their sentry.
                weapon_secondary.AddAttribute("engy sentry fire rate increased", 1.75, -1)
                isWranglerNerfApplied = true;
            }
            else
            {
                if (!isWranglerNerfApplied)
                    return;

                weapon_secondary.RemoveAttribute("engy sentry fire rate increased")
                isWranglerNerfApplied = false;
            }
        }

		if (weapon_primary == Pomson)
		{
			if (player.IsCritBoosted())
			{
				if (pomsonCritNerfApplied)
					return;

				Pomson.AddAttribute("dmg penalty vs players", 1.1, -1);
				pomsonCritNerfApplied = true;
			}
			else
			{
				if (!pomsonCritNerfApplied)
					return;

				Pomson.AddAttribute("dmg penalty vs players", 1.5, -1);
				pomsonCritNerfApplied = false;
			}
		}
	}

	function OnDamageDealt(victim, params)
	{
		if (Shotgun != null)
			lastHitWasShotgun = params.weapon == Shotgun
	}

	function OnHurtDealtEvent(victim, params)
	{
		if (lastHitWasShotgun)
		{
			local damage_dealt = params.damageamount
			local overheal_limit = player.GetMaxHealth() * 1.5
			player.SetHealth(clampCeiling(overheal_limit, player.GetHealth() + (damage_dealt / 2)))
		}
	}

	function OnDeath(attacker, params)
    {
        // Delfite: Remove the fire rate penalty if the Engineer dies, otherwise his sentry will remain nerfed until the next round.
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("engy sentry fire rate increased");
        }
    }

	function OnDiscard()
    {
		if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("damage bonus");
        }

		if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("engy sentry fire rate increased");
        }

        if (weapon_melee && weapon_melee.IsValid())
        {
			weapon_melee.RemoveAttribute("engy dispenser radius increased")
        }
    }
});