// Script by Senni, Delfite, with assistance from Bradasparky, Horiuchi.
// This script handles almost everything to do with Pyro's secondaries.
// This script requires modification of weapons.nut to function.


AddListener("setup_start", 0, function()
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

    // printl("tf_rocketpack_airborne_launch_absvelocity_preserved = " + Convars.GetFloat("tf_rocketpack_airborne_launch_absvelocity_preserved"))
    // printl("tf_rocketpack_cost = " + Convars.GetFloat("tf_rocketpack_cost"))
    // printl("tf_rocketpack_delay_launch = " + Convars.GetFloat("tf_rocketpack_delay_launch"))
    // printl("tf_rocketpack_impact_push_max = " + Convars.GetFloat("tf_rocketpack_impact_push_max"))
    // printl("tf_rocketpack_impact_push_min = " + Convars.GetFloat("tf_rocketpack_impact_push_min"))
    // printl("tf_rocketpack_launch_absvelocity_preserved = " + Convars.GetFloat("tf_rocketpack_launch_absvelocity_preserved"))
    // printl("tf_rocketpack_launch_delay = " + Convars.GetFloat("tf_rocketpack_launch_delay"))
    // printl("tf_rocketpack_launch_push = " + Convars.GetFloat("tf_rocketpack_launch_push"))
    // printl("tf_rocketpack_refire_delay = " + Convars.GetFloat("tf_rocketpack_refire_delay"))
    // printl("tf_rocketpack_toggle_duration = " + Convars.GetFloat("tf_rocketpack_toggle_duration"))
});

characterTraitsClasses.push(class extends CharacterTrait
{
    // prev_gas_passer_meter = 0;
    // cur_gas_passer_meter = 0;
    Flaregun = null;
    Detonator = null;
    Jetpack = null;

    // isPlayerDoused = false;
    isDetonatorBuffApplied = false;
    playerIsDetonatorJumping = false;
    isJetpackBuffApplied = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        if (WeaponIs(weapon_secondary, "shotgun"))
        {
            weapon_secondary.AddAttribute("damage bonus" 1.40, -1);
            weapon_secondary.AddAttribute("weapon spread bonus", 0.70, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.85, -1);
        }
        if (WeaponIs(weapon_secondary, "reserve_shooter"))
        {
            // weapon_secondary.AddAttribute("weapon spread bonus" 0.70, -1);
        }
        if (WeaponIs(weapon_secondary, "panic_attack"))
        {
            weapon_secondary.AddAttribute("weapon spread bonus" 0.6, -1);
            weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
        }
        if (WeaponIs(weapon_secondary, "flaregun"))
        {
            weapon_secondary.AddAttribute("damage bonus", 2.0, -1);
            // weapon_secondary.AddAttribute("Projectile speed increased", 2.0, -1);
            Flaregun = weapon_secondary
        }
        if (WeaponIs(weapon_secondary, "detonator"))
        {
            weapon_secondary.AddAttribute("blast dmg to self increased" 0.0, -1);
            // weapon_secondary.AddAttribute("damage penalty" 1.0, -1);
            weapon_secondary.AddAttribute("Blast radius increased", 1.35, -1);
            weapon_secondary.AddAttribute("fire rate bonus", 0.30, -1);
            // weapon_secondary.AddAttribute("increased air control", 3, -1);
            weapon_secondary.AddAttribute("boots falling stomp", 1, -1);
            Detonator = weapon_secondary
        }
        if (WeaponIs(weapon_secondary, "gas_passer"))
        {
            weapon_secondary.AddAttribute("explode_on_ignite", 1, -1);
            weapon_secondary.AddAttribute("single wep deploy time decreased", 0.75, -1);
            weapon_secondary.AddAttribute("switch from wep deploy time decreased", 0.75, -1);
            weapon_secondary.AddAttribute("dmg penalty vs players", 0.5, -1);
            weapon_secondary.AddAttribute("item_meter_damage_for_full_charge", 600, -1);
        }
        if (WeaponIs(weapon_secondary, "thermal_thruster"))
        {
            // weapon_primary.AddAttribute("damage bonus", 1.1, -1);
            weapon_secondary.AddAttribute("thermal_thruster_air_launch", 1, -1);
            weapon_secondary.AddAttribute("holster_anim_time", 0.25, -1);
            weapon_secondary.AddAttribute("single wep deploy time decreased", 0.7, -1);
            weapon_secondary.AddAttribute("switch from wep deploy time decreased", 0.7, -1);
            weapon_secondary.AddAttribute("item_meter_charge_type", 3, -1);
            weapon_secondary.AddAttribute("item_meter_charge_rate", 20, -1);
            weapon_secondary.AddAttribute("item_meter_damage_for_full_charge", 800, -1);
            Jetpack = weapon_secondary
        }
    }

    function OnFrameTickAlive()
    {
    //     gas_passer_meter = GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1);
    //     printl(gas_passer_meter)
        local playerIsJetpacking = player.InCond(TF_COND_ROCKETPACK) && !player.IsOnGround();
        playerIsDetonatorJumping = player.InCond(TF_COND_BLASTJUMPING) && !player.IsOnGround();

        if (Detonator)
        {
            local projectile = null;
            while (projectile = FindByClassname(projectile, "tf_projectile_flare"))
            {
                if (projectile.GetOwner() == player) // projectile is a class object, aka an "instance".
                {
                    projectile.ValidateScriptScope()
                    local projectileScope = projectile.GetScriptScope();
                    if (!("CHECKED" in projectileScope))
                    {
                        projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 1.25)
                        // printl(projectile + " | " + projectile.GetAbsVelocity())
                        projectileScope["CHECKED"] <- null;
                    }
                }
            }

            if (playerIsDetonatorJumping)
            {
                if (isDetonatorBuffApplied)
                    return;

                weapon_secondary.AddAttribute("increased air control", 3.0, -1)
                isDetonatorBuffApplied = true;
            }
            else
            {
                if (!isDetonatorBuffApplied)
                    return;

                weapon_secondary.RemoveAttribute("increased air control")
                isDetonatorBuffApplied = false;
            }
        }

        if (Jetpack)
        {
            if (playerIsJetpacking)
            {
                SetPropBool(weapon_secondary, "m_bEnabled", true)
                if (isJetpackBuffApplied)
                    return;

                weapon_secondary.AddAttribute("increased air control", 5.0, -1);
                player.RemoveCondEx(TF_COND_STUNNED, true)
                isJetpackBuffApplied = true;
            }
            else
            {
                if (!isJetpackBuffApplied)
                    return;

                weapon_secondary.RemoveAttribute("increased air control")
                isJetpackBuffApplied = false;
            }
            // printl("playerIsJetpacking: " + playerIsJetpacking + " | " + "isJetpackBuffApplied: " + isJetpackBuffApplied)
        }

        if (Flaregun)
        {
            // printl(projectile.GetAbsVelocity())
            local projectile = null;
            while (projectile = FindByClassname(projectile, "tf_projectile_flare"))
            {
                if (projectile.GetOwner() == player) // projectile is a class object, aka an "instance".
                {
                    projectile.ValidateScriptScope()
                    local projectileScope = projectile.GetScriptScope();
                    if (!("CHECKED" in projectileScope))
                    {
                        projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 1.5)
                        // printl(projectile + " | " + projectile.GetAbsVelocity())
                        projectileScope["CHECKED"] <- null;
                    }
                }
            }
        }
    }

    function OnDamageTaken(attacker, params)
    {
        if (Detonator && params.attacker == player)
        {
            if (params.weapon != weapon_secondary)
                return;

            local deltaVector = player.GetCenter() - params.inflictor.GetOrigin();
            deltaVector.Norm();
            player.Yeet(deltaVector * 600);
            params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;

            if (playerIsDetonatorJumping)
                return;

            player.AddCondEx(TF_COND_BLASTJUMPING, -1, params.attacker)
            // printl("Vector applied.")
        }

        if (Jetpack || Detonator)
        {
            // Delfite: Normally, we could just add the `cancel falling damage` attribute to a weapon if we wanted to remove fall damage from the player.
            // However, that ended up removing the ability to stomp Hale while in flight.
            // This code lets us do both, although you'll still take 1 damage when stomping Hale.

            // Make sure that the entity damaging us isn't null, otherwise we'll get an error in console when Hale hits us with an ability of his.
            if (GetPropEntity(player, "m_hGroundEntity") != null)
            {
                // If the entity we're landing on isn't a player, then we can negate the fall damage.
                if (!GetPropEntity(player, "m_hGroundEntity").IsPlayer() && params.damage_type & (DMG_FALL))
                {
                    params.damage *= 0.0;
                    // printl(GetPropEntity(player, "m_hGroundEntity"))
                    // printl("Fall damage negated.")
                }
            }
        }
    }

    function OnDiscard()
    {
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("reload time decreased");
            weapon_secondary.RemoveAttribute("Projectile speed increased");
            weapon_secondary.RemoveAttribute("damage bonus");
            weapon_secondary.RemoveAttribute("increased air control");
            weapon_secondary.RemoveAttribute("weapon spread bonus");
            weapon_secondary.RemoveAttribute("damage penalty");
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
    //     //     printl(prev_gas_passer_meter)
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
    //     // printl(prev_gas_passer_meter)

    //     cur_gas_passer_meter = SetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", prev_gas_passer_meter, 1)
    // }


    // function OnHurtDealtEvent(victim, params)
    // {
    //     // printl("OnHurtDealtEvent triggered.")
    //     // printl("Damage dealt: " + params.damageamount)
    //     // printl("Previous Gas Passer meter: " + prev_gas_passer_meter)
    //     // printl("Current Gas Passer meter: " + GetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", 1))
    //     // if (isPlayerDoused && params.custom == TF_DMG_CUSTOM_BURNING)
    //     // {
    //     //     SetPropFloatArray(player, "m_Shared.m_flItemChargeMeter", prev_gas_passer_meter, 1);
    //     //     isPlayerDoused = false;
    //     //     printl("Reset.")
    //     // }
    //     // local active_weapon = player.GetActiveWeapon()
    //     // printl(active_weapon)
    // }
});