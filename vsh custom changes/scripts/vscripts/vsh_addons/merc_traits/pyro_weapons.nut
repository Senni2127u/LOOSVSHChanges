// Script by: Senni, Delfite.
// With assistance from: Bradasparky, Horiuchi, Lizard of Oz.
// This script handles everything to do with Pyro's weapons.
// All code in this script was previously split into 4 different scripts, one for each weapon slot, and one for the Manmelter's crit accumulation.
// The code was merged into one file for easier variable management, reduced lag when using Tick functions, and slightly better RAM usage.
// Requires modification of `weapons.nut` in order to function.


const PYRO_PRIMARY_OVERHEAL_MULT = 0.6

AddListener("setup_start", 1, function()
{
    // Delfite: These cvars control everything to do with the Thermal Thruster. Their values are set every time setup starts.
    // These cvars are also hidden in-game and considered cheats, but can still be set by VScript nonetheless.
    Convars.SetValue("tf_rocketpack_airborne_launch_absvelocity_preserved", 1)   // Default: 0
    Convars.SetValue("tf_rocketpack_cost", 50)                                   // Default: 50
    Convars.SetValue("tf_rocketpack_delay_launch", 0)                            // Default: 0
    Convars.SetValue("tf_rocketpack_impact_push_max", 300)                       // Default: 300
    Convars.SetValue("tf_rocketpack_impact_push_min", 100)                       // Default: 100
    Convars.SetValue("tf_rocketpack_launch_absvelocity_preserved", 1)            // Default: 0
    Convars.SetValue("tf_rocketpack_launch_delay", 0.35)                         // Default: 0.65
    Convars.SetValue("tf_rocketpack_launch_push", 250)                           // Default: 250
    Convars.SetValue("tf_rocketpack_refire_delay", 0.35)                         // Default: 1.2
    Convars.SetValue("tf_rocketpack_toggle_duration", -0.9)                      // Default: 1

    // printdev("tf_rocketpack_airborne_launch_absvelocity_preserved = " + Convars.GetFloat("tf_rocketpack_airborne_launch_absvelocity_preserved"))
    // printdev("tf_rocketpack_cost = " + Convars.GetFloat("tf_rocketpack_cost"))
    // printdev("tf_rocketpack_delay_launch = " + Convars.GetFloat("tf_rocketpack_delay_launch"))
    // printdev("tf_rocketpack_impact_push_max = " + Convars.GetFloat("tf_rocketpack_impact_push_max"))
    // printdev("tf_rocketpack_impact_push_min = " + Convars.GetFloat("tf_rocketpack_impact_push_min"))
    // printdev("tf_rocketpack_launch_absvelocity_preserved = " + Convars.GetFloat("tf_rocketpack_launch_absvelocity_preserved"))
    // printdev("tf_rocketpack_launch_delay = " + Convars.GetFloat("tf_rocketpack_launch_delay"))
    // printdev("tf_rocketpack_launch_push = " + Convars.GetFloat("tf_rocketpack_launch_push"))
    // printdev("tf_rocketpack_refire_delay = " + Convars.GetFloat("tf_rocketpack_refire_delay"))
    // printdev("tf_rocketpack_toggle_duration = " + Convars.GetFloat("tf_rocketpack_toggle_duration"))
});

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;
    weapon_secondary = null;
    weapon_melee = null;

    overheal_difference = 0;
    overheal_limit = 0;
    primary_damage_accumulated = 0;

    // Primary handles.
    Flamethrower = null;
    Backburner = null;
    Degreaser = null;
	Phlog = null;
	DragonsFury = null;

    // Secondary handles.
    Shotgun = null;
    Flaregun = null;
    Detonator = null;
    Jetpack = null;

    // Melee handles.
    Axtinguisher = null;

    lastHitWasPrimary = false;
    uberPenaltyApplied = false;
    lastHitWasShotgun = false;
    isDetonatorBuffApplied = false;
    playerIsDetonatorJumping = false;
    isJetpackBuffApplied = false;

    // prev_gas_passer_meter = 0;
    // cur_gas_passer_meter = 0;
    // isPlayerDoused = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        overheal_difference = player.GetMaxHealth() * 0.5

        // Primary definitions.
        if (WeaponIs(weapon_primary, "flamethrower"))
        {
            Flamethrower = weapon_primary;
			Flamethrower.AddAttribute("patient overheal penalty", PYRO_PRIMARY_OVERHEAL_MULT, -1);
			Flamethrower.AddAttribute("no primary ammo from dispensers while active", 1, -1);
        }
        else if (WeaponIs(weapon_primary, "backburner"))
        {
            Backburner = weapon_primary;
			weapon_primary.AddAttribute("patient overheal penalty", PYRO_PRIMARY_OVERHEAL_MULT, -1);
			weapon_primary.AddAttribute("no primary ammo from dispensers while active", 1, -1);
        }
        else if (WeaponIs(weapon_primary, "degreaser"))
        {
            Degreaser = weapon_primary;
			weapon_primary.AddAttribute("patient overheal penalty", PYRO_PRIMARY_OVERHEAL_MULT, -1);
			weapon_primary.AddAttribute("no primary ammo from dispensers while active", 1, -1);
        }
        else if (WeaponIs(weapon_primary, "phlog"))
        {
            Phlog = weapon_primary
        }
        else if (WeaponIs(weapon_primary, "dragons_fury"))
        {
            DragonsFury = weapon_primary
        }

        // Secondary definitions.
        if (WeaponIs(weapon_secondary, "shotgun"))
        {
            Shotgun = weapon_secondary;
            // Shotgun.AddAttribute("damage bonus" 1.40, -1);
            Shotgun.AddAttribute("weapon spread bonus", 0.70, -1);
            Shotgun.AddAttribute("reload time decreased", 0.85, -1);
        }
        else if (WeaponIs(weapon_secondary, "reserve_shooter"))
        {
            // weapon_secondary.AddAttribute("weapon spread bonus" 0.70, -1);
        }
        else if (WeaponIs(weapon_secondary, "panic_attack"))
        {
            weapon_secondary.AddAttribute("weapon spread bonus" 0.6, -1);
            weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
        }
        else if (WeaponIs(weapon_secondary, "flaregun"))
        {
            Flaregun = weapon_secondary
            Flaregun.AddAttribute("damage bonus", 2.0, -1);
            Flaregun.AddAttribute("single wep deploy time decreased", 0.7, -1);
            // Flaregun.AddAttribute("Projectile speed increased", 2.0, -1);
        }
        else if (WeaponIs(weapon_secondary, "detonator"))
        {
            Detonator = weapon_secondary
            Detonator.AddAttribute("maxammo primary reduced" 0.5, -1);
            Detonator.AddAttribute("blast dmg to self increased" 0.0, -1);
            // Detonator.AddAttribute("damage penalty" 1.0, -1);
            Detonator.AddAttribute("Blast radius increased", 1.35, -1);
            Detonator.AddAttribute("fire rate bonus", 0.30, -1);
            // Detonator.AddAttribute("increased air control", 3, -1);
            Detonator.AddAttribute("boots falling stomp", 1, -1);
        }
        else if (WeaponIs(weapon_secondary, "gas_passer"))
        {
            weapon_secondary.AddAttribute("explode_on_ignite", 1, -1);
            weapon_secondary.AddAttribute("item_meter_charge_rate", 50, -1);
            weapon_secondary.AddAttribute("single wep deploy time decreased", 0.7, -1);
            weapon_secondary.AddAttribute("switch from wep deploy time decreased", 0.7, -1);
            weapon_secondary.AddAttribute("dmg penalty vs players", 0.7, -1);
            weapon_secondary.AddAttribute("item_meter_damage_for_full_charge", 600, -1);
        }
        else if (WeaponIs(weapon_secondary, "thermal_thruster"))
        {
            Jetpack = weapon_secondary
            // weapon_primary.AddAttribute("damage bonus", 1.1, -1);
            Jetpack.AddAttribute("thermal_thruster_air_launch", 1, -1);
            Jetpack.AddAttribute("holster_anim_time", 0.25, -1);
            Jetpack.AddAttribute("single wep deploy time decreased", 0.7, -1);
            Jetpack.AddAttribute("switch from wep deploy time decreased", 0.7, -1);
            Jetpack.AddAttribute("item_meter_charge_type", 3, -1);
            Jetpack.AddAttribute("item_meter_charge_rate", 20, -1);
            Jetpack.AddAttribute("item_meter_damage_for_full_charge", 800, -1);
        }

        // Melee definitions.
        if (WeaponIs(weapon_melee, "fire_axe"))
        {
            weapon_melee.AddAttribute("heal on kill", 0, -1)
        }
        else if (WeaponIs(weapon_melee, "powerjack"))
        {
            weapon_melee.AddAttribute("heal on kill", 0, -1)
            weapon_melee.AddAttribute("dmg taken increased", 1, -1)
            weapon_melee.AddAttribute("damage penalty", 0.40, -1)
            // weapon_melee.AddAttribute("mult_player_movespeed_active", 1.3, -1);

            weapon_melee.AddAttribute("move speed bonus", 1.3, -1)
            weapon_melee.AddAttribute("provide on active", 1, -1)
        }
        else if (WeaponIs(weapon_melee, "axtinguisher"))
        {
            Axtinguisher = weapon_melee
        }
        player.Regenerate(true);
        RunWithDelay2(this, 0.1, OnApply01Delay)
    }

    function OnApply01Delay()
    {
        // Delfite: If you want to define the player's max overheal for a specific weapon/combination of weapons, do it here.
        // The purpose of this is to reduce calls to C++ functions for performance reasons. That includes stuff like GetMaxHealth.
        if (weapon_primary == (Flamethrower || Backburner || Degreaser))
            overheal_limit = overheal_difference * PYRO_PRIMARY_OVERHEAL_MULT + player.GetMaxHealth()
        else
            overheal_limit = overheal_difference + player.GetMaxHealth()
    }

	function OnFrameTickAlive()
    {
        if (weapon_primary == (Phlog || DragonsFury))
        {
            local patient_health = player.GetHealth()
            if (patient_health == overheal_limit)
            {
                if (uberPenaltyApplied)
                    return;

                player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
                uberPenaltyApplied = true
            }
            else if (patient_health <= overheal_limit - 2)
            {
                if (!uberPenaltyApplied)
                    return;

                player.RemoveCustomAttribute("ubercharge rate bonus for healer")
                uberPenaltyApplied = false
            }
        }
	}

    function OnTickAlive(timeDelta)
    {
        //     gas_passer_meter = GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1);
        //     printdev(gas_passer_meter)
        if (weapon_secondary == Detonator)
            DetonatorSlowThink()
        if (weapon_secondary == Jetpack)
            JetpackSlowThink()
    }

    function OnDamageDealt(victim, params)
	{
		if (weapon_secondary == Shotgun)
			lastHitWasShotgun = params.weapon == Shotgun;

        // Delfite: Restore half of the player's max health if they land a burning hit with the Axtinguisher.
        if (params.weapon == Axtinguisher)
        {
            if (victim.InCond(TF_COND_BURNING))
            {
                local new_health = player.GetHealth() + player.GetMaxHealth() / 2.0;
                player.SetHealth(clampCeiling(new_health, overheal_limit));
            }
        }

        if (params.weapon == weapon_primary)
            lastHitWasPrimary = true;
	}

	function OnHurtDealtEvent(victim, params)
	{
        // Delfite: Heal the player when they deal damage with the Shotgun.
        // Healing ratio: 2 damage : 1 health
		if (lastHitWasShotgun)
		{
			local damage_dealt = params.damageamount
            player.SetHealth(clampCeiling(overheal_limit, player.GetHealth() + (damage_dealt / 2)))
		}

        if (lastHitWasPrimary)
        {
            primary_damage_accumulated += params.damageamount;
            while (primary_damage_accumulated >= 200)
            {
                AddPropInt(player, "m_Shared.m_iRevengeCrits", 2);
                primary_damage_accumulated -= 200;
            }
        }
	}

    function OnDamageTaken(attacker, params)
    {
        if (params.weapon == Detonator && params.attacker == player)
        {
            local deltaVector = player.GetCenter() - params.inflictor.GetOrigin();
            deltaVector.Norm();
            player.Yeet(deltaVector * 600);
            params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;

            if (playerIsDetonatorJumping)
                return;

            player.AddCondEx(TF_COND_BLASTJUMPING, -1, params.attacker)
            // printdev("Vector applied.")
        }
        else if (Jetpack != null || Detonator != null)
        {
            // Delfite: Normally, we could just add the `cancel falling damage` attribute to a weapon if we wanted to remove fall damage from the player.
            // However, that ended up removing the ability to stomp Hale while in flight.
            // This code lets us do both, although you'll still take 1 damage when stomping Hale.

            // Make sure that the entity damaging us isn't null, otherwise we'll get an error in console when Hale hits us with one of his abilities.
            if (GetPropEntity(player, "m_hGroundEntity") != null)
            {
                // If the entity we're landing on isn't a player, then we can negate the fall damage.
                if (!GetPropEntity(player, "m_hGroundEntity").IsPlayer() && params.damage_type & (DMG_FALL))
                {
                    params.damage *= 0.0;
                    // printdev(GetPropEntity(player, "m_hGroundEntity"))
                    // printdev("Fall damage negated.")
                }
            }
        }
    }

    // Delfite: Failed abomination of an attempt at fixing the Gas Passer gaining its meter from its own explosion.
    // Neither me nor Brad could figure this out. Consider us defeated, at least for now.

    // function OnDamageDealt(victim, params)
    // {
    //     // if (WeaponIs(weapon_secondary, "gas_passer") && params.damage_custom == TF_DMG_CUSTOM_BURNING)
    //     // {
    //     //     prev_gas_passer_meter = GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1);
    //     //     isPlayerDoused = true;
    //     //     printdev(prev_gas_passer_meter)
    //     // }

    //     if (WeaponIs(weapon_secondary, "gas_passer"))
    //         prev_gas_passer_meter = GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1);
    // }

    // function OnFrameTickAlive()
    // {
    //     if (WeaponIs(weapon_secondary, "gas_passer"))
    //         cur_gas_passer_meter = GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1);
    // }

    // function OnGasIgniteEvent(victim, params)
    // {
    //     // prev_gas_passer_meter = GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1);
    //     // isPlayerDoused = true;
    //     // printdev(prev_gas_passer_meter)

    //     cur_gas_passer_meter = SetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", prev_gas_passer_meter, 1)
    // }


    // function OnHurtDealtEvent(victim, params)
    // {
    //     // printdev("OnHurtDealtEvent triggered.")
    //     // printdev("Damage dealt: " + params.damageamount)
    //     // printdev("Previous Gas Passer meter: " + prev_gas_passer_meter)
    //     // printdev("Current Gas Passer meter: " + GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1))
    //     // if (isPlayerDoused && params.custom == TF_DMG_CUSTOM_BURNING)
    //     // {
    //     //     SetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", prev_gas_passer_meter, 1);
    //     //     isPlayerDoused = false;
    //     //     printdev("Reset.")
    //     // }
    //     // local active_weapon = player.GetActiveWeapon()
    //     // printdev(active_weapon)
    // }

    function DetonatorSlowThink()
    {
        playerIsDetonatorJumping = player.InCond(TF_COND_BLASTJUMPING) && !player.IsOnGround();

        if (playerIsDetonatorJumping)
        {
            if (isDetonatorBuffApplied)
                return;

            player.AddCustomAttribute("increased air control", 3.0, -1)
            isDetonatorBuffApplied = true;
        }
        else
        {
            if (!isDetonatorBuffApplied)
                return;

            player.RemoveCustomAttribute("increased air control")
            isDetonatorBuffApplied = false;
        }
    }

    function JetpackSlowThink()
    {
        local playerIsJetpacking = player.InCond(TF_COND_ROCKETPACK) && !player.IsOnGround();
        if (playerIsJetpacking)
        {
            SetPropBool(weapon_secondary, "m_bEnabled", true)
            if (isJetpackBuffApplied)
                return;

            player.AddCustomAttribute("increased air control", 5.0, -1);
            player.RemoveCondEx(TF_COND_STUNNED, true)
            isJetpackBuffApplied = true;
        }
        else
        {
            if (!isJetpackBuffApplied)
                return;

            player.RemoveCustomAttribute("increased air control")
            isJetpackBuffApplied = false;
        }
        // printdev("playerIsJetpacking: " + playerIsJetpacking + " | " + "isJetpackBuffApplied: " + isJetpackBuffApplied)
    }

    function OnDiscard()
    {
        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("heal on kill");
            weapon_melee.RemoveAttribute("move speed bonus");
            weapon_melee.RemoveAttribute("dmg taken increased");
            weapon_melee.RemoveAttribute("damage penalty");
            weapon_melee.RemoveAttribute("provide on active");
        }

        if (weapon_secondary && weapon_secondary.IsValid())
        {
            // weapon_secondary.RemoveAttribute("increased air control");
        }
    }
});

// Uncomment print line to make sure script is functioning if edits are made.
//printdev ("pyro_primaries.nut loaded.\n");
