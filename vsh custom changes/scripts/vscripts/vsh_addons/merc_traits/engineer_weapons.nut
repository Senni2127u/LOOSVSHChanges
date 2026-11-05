// Script by: Delfite (I don't care if you use any of my code, just as long as you credit me. Open source stuff quite literally runs the world.)
// This script handles everything to do with Engineer's weapons.
// For code related to Engineer's buildings, please refer to `engineer_sentry.nut` in the vsh_overrides folder.


const GUNSLINGER_RESISTANCE_FACTOR = 0.7

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

	// Melee handles.
	Hospitality = null;
	Gunslinger = null;

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
		local pda = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA);			// Construction PDA.
		local pda2 = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA2);		// Destruction PDA.
		local toolbox = player.GetWeaponBySlot(TF_WEAPONSLOTS.TOOLBOX);	// Exactly what you think it is.

		toolbox.AddAttribute("single wep deploy time decreased", 0.5, -1)
		toolbox.AddAttribute("switch from wep deploy time decreased", 0.5, -1)

		// Primary definitions.
		if (WeaponIs(weapon_primary, "shotgun"))
		{
			Shotgun = weapon_primary;
			Shotgun.AddAttribute("damage bonus" 1.10, -1)
            Shotgun.AddAttribute("weapon spread bonus", 0.70, -1)
            Shotgun.AddAttribute("reload time decreased", 0.85, -1)
            Shotgun.AddAttribute("single wep deploy time decreased", 0.8, -1)
		}
		if (WeaponIs(weapon_primary, "panic_attack"))
		{
			weapon_primary.AddAttribute("damage bonus", 1.25, -1)
			// weapon_primary.AddAttribute("bullets per shot bonus", 1.5, -1)
			weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1)
			weapon_primary.AddAttribute("reload time decreased", 0.6, -1)
			weapon_primary.AddAttribute("fire rate bonus", 0.7, -1)
			weapon_primary.AddAttribute("damage penalty", 1.0, -1)
			weapon_primary.AddAttribute("special taunt", 1, -1)
		}
		if (WeaponIs(weapon_primary, "frontier_justice"))
		{
			weapon_primary.AddAttribute("fire rate bonus", 0.7, -1)
		}
		if (WeaponIs(weapon_primary, "widowmaker"))
		{
			weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1)
		}
		if (WeaponIs(weapon_primary, "rescue_ranger"))
		{
			weapon_primary.AddAttribute("fire rate bonus", 0.7, -1)
			weapon_primary.AddAttribute("mark for death on building pickup", 0, -1)
			weapon_primary.AddAttribute("engineer building teleporting pickup", 50, -1)
		}
		if (WeaponIs(weapon_primary, "pomson_6000"))
		{
			Pomson = weapon_primary;
            Pomson.AddAttribute("fire rate bonus", 0.80, -1)
            Pomson.AddAttribute("reload time decreased", 0.80, -1)
            Pomson.AddAttribute("dmg penalty vs players", 1.5, -1)
		}

		// Secondary definitions.
		if (WeaponIs(weapon_secondary, "pistol"))
        {
            weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1)
            weapon_secondary.AddAttribute("damage bonus", 1.20, -1)
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
			weapon_secondary.AddAttribute("single wep deploy time decreased", 0.75, -1)
			weapon_secondary.AddAttribute("switch from wep deploy time decreased", 0.75, -1)
		}
		if (WeaponIs(weapon_secondary, "wrangler"))
        {
            Wrangler = weapon_secondary;
            // Wrangler.AddAttribute("deploy time decreased", 0.65, -1)
		}
		if (WeaponIs(weapon_secondary, "short_circuit"))
        {
            weapon_secondary.AddAttribute("mod ammo per shot", 0, -1)
            weapon_secondary.AddAttribute("crit mod disabled", 1, -1)
            weapon_secondary.AddAttribute("dmg penalty vs players", 2.5, -1)
            weapon_secondary.AddAttribute("maxammo metal increased", 1.3333, -1)
			weapon_secondary.AddAttribute("single wep deploy time decreased", 0.75, -1)
			weapon_secondary.AddAttribute("switch from wep deploy time decreased", 0.75, -1)
		}

		// Melee definitions.
		if (WeaponIs(weapon_melee, "wrench"))
		{
			weapon_melee.AddAttribute("Repair rate increased", 1.5, -1)
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.2, -1)
			toolbox.AddAttribute("mult_player_movespeed_active", 1.2, -1)
			pda.AddAttribute("mult_player_movespeed_active", 1.2, -1)
			pda2.AddAttribute("mult_player_movespeed_active", 1.2, -1)
		}
		if (WeaponIs(weapon_melee, "jag"))
		{
			weapon_melee.AddAttribute("engy sentry radius increased", 1.2, -1)
		}
		if (WeaponIs(weapon_melee, "eureka_effect"))
		{
			weapon_melee.AddAttribute("engineer building teleporting pickup", 50, -1)
			weapon_melee.AddAttribute("mod teleporter cost", 1, -1)
		}
		if (WeaponIs(weapon_melee, "southern_hospitality"))
		{
			Hospitality = weapon_melee;
			weapon_melee.AddAttribute("engy dispenser radius increased", 3, -1)
			// weapon_melee.AddAttribute("heal rate bonus", 2, -1)
		}
		if (WeaponIs(weapon_melee, "gunslinger"))
		{
			Gunslinger = weapon_melee;
			Gunslinger.AddAttribute("engy sentry radius increased", 1.2, -1)
			// Gunslinger.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			// toolbox.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			// pda.AddAttribute("mult_player_movespeed_active", 1.25, -1);
			// pda2.AddAttribute("mult_player_movespeed_active", 1.25, -1);
		}
	}
	// Idea: Make the Rescue Ranger upgrade buildings on hit.

	// function OnTickAlive(timeDelta)
	// {
	// 	// WranglerNerf()
	// }

	function WranglerNerf()
	{
		local active_weapon = player.GetActiveWeapon()
        if (weapon_secondary == Wrangler)
        {
            if (active_weapon == Wrangler)
            {
                if (isWranglerNerfApplied)
                    return;

				// Delfite: Turns out negating the wrangler's doubled fire rate is as simple as giving this attribute a value of 2.
                // This nerf - in practice, however - ended up being pretty harsh since sentries already deal half of their normal damage.
                // Reducing this value to 1.75 so the player can at least get a 25% fire rate bonus on their sentry.
                player.AddCustomAttribute("engy sentry fire rate increased", 1.75, -1)
                isWranglerNerfApplied = true;
            }
            else
            {
                if (!isWranglerNerfApplied)
                    return;

                player.RemoveCustomAttribute("engy sentry fire rate increased")
                isWranglerNerfApplied = false;
            }
        }
	}

	function OnDamageDealt(victim, params)
	{
		if (weapon_primary == Shotgun)
			lastHitWasShotgun = params.weapon == Shotgun

		if (params.weapon == Pomson)
			if (params.damage_type & DMG_ACID)
				params.damage *= 0.67

		if (params.weapon == Hospitality)
			if (params.damage_custom == TF_DMG_CUSTOM_BLEEDING)
				params.damage_type = params.damage_type | DMG_ACID;
	}

	function OnHurtDealtEvent(victim, params)
	{
		if (lastHitWasShotgun)
		{
			local damage_dealt = params.damageamount
			player.SetHealth(clampCeiling(player.GetMaxOverheal(), player.GetHealth() + (damage_dealt / 2)))
		}
	}

	function OnDamageTaken(attacker, params)
    {
        if (weapon_melee == Gunslinger)
        {
            // printdev("The player has a bow equipped.")
            if (IsValidBoss(attacker) || params.attacker == worldspawn)
            {
                // printdev("The attacker is either Hale or Worldspawn.")
                if (params.damage_type & (DMG_CLUB | DMG_FALL))
                {
                    // printdev("The player received either melee damage or fall damage.")
                    params.damage *= params.inflictor == custom_dmg_saxton_punch ? 1.0 : GUNSLINGER_RESISTANCE_FACTOR;

                    // local deltaVector = player.GetOrigin() - attacker.GetOrigin();
                    // deltaVector.z = 0;
                    // deltaVector.Norm();
                    // player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
                    // params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
                }
            }
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
		local pda = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA);			// Construction PDA.
		local pda2 = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA2);		// Destruction PDA.
		local toolbox = player.GetWeaponBySlot(TF_WEAPONSLOTS.TOOLBOX);	// Exactly what you think it is.

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

        if (pda && pda.IsValid())
        {
			pda.RemoveAttribute("mult_player_movespeed_active");
        }

        if (pda2 && pda2.IsValid())
        {
			pda2.RemoveAttribute("mult_player_movespeed_active");
        }

        if (toolbox && toolbox.IsValid())
        {
			toolbox.RemoveAttribute("mult_player_movespeed_active");
        }
    }
});