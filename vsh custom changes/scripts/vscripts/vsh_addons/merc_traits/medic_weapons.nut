// Script by: Senni, Delfite.
// With assistance from: Bradasparky.
// This script handles everything to do with Medic's melees.
// Requires modification of `weapons.nut` in order to function.

PrecacheScriptSound("HealthKit.Touch")
PrecacheScriptSound("WeaponMedigun.Charged")
PrecacheScriptSound("Medic.AutoChargeReady01")
PrecacheScriptSound("Medic.AutoChargeReady02")
PrecacheScriptSound("Medic.AutoChargeReady03")
PrecacheScriptSound("DemoCharge.ChargeCritOn")
PrecacheScriptSound("DemoCharge.ChargeCritOff")

::auto_charge_ready_array <- [
    "Medic.AutoChargeReady01",
    "Medic.AutoChargeReady02",
    "Medic.AutoChargeReady03"
]

characterTraitsClasses.push(class extends CharacterTrait
{
    active_weapon = null;
    weapon_primary = null;
    weapon_secondary = null;
    weapon_melee = null;

    // Primary handles.
    SyringeGun = null;
    Crossbow = null;

    // Secondary handles.
    Medigun = null;
    Kritzkrieg = null;
    QuickFix = null;
    Vaccinator = null;

    // Melee handles.
    Amputator = null;
    Solemn_Vow = null;
    Ubersaw = null;
    Vitasaw = null;

    medic_mag = 0;
    medic_reserve = 0;
    primary_mag = 0;
    primary_reserve = 0;
    patient_primary_reserve = 0;
    patient_secondary_reserve = 0;
    patient_primary_mag = 0;
    patient_secondary_mag = 0;
    overheal_penalty = 0;

    chargedHealingActive = false;
    healerDebuffApplied = false;
    kritzChargeActive = false;
    kritzSFXPlaybackRunning = false;
    medicMagIsStored = false;
    medicReserveIsStored = false;
    primaryMagIsStored = false;
    secondaryMagIsStored = false;
    primaryReserveIsStored = false;
    secondaryReserveIsStored = false;

    crossbowPenaltyApplied = false;
    // Delfite: Set chargedSFXPlayed to true on round start so hitting Hale doesn't immediately play the sequence.
    chargedSFXPlaybackRunning = true;
    chargedSFXPlayed = true;
    chargeReleased = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_MEDIC;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        // Primary definitions.
        if (!WeaponIs(weapon_primary, "crusaders_crossbow"))
        {
            // Delfite: Only god knows why, but the "Projectile speed increased" attribute doesn't work on Syringe Guns. Damn you Valve!
            weapon_primary.AddAttribute("fire rate bonus", 0.70, -1)
            weapon_primary.AddAttribute("reload time decreased", 0.60, -1)
            weapon_primary.AddAttribute("maxammo primary increased", 2.0, -1)
            // weapon_primary.AddAttribute("weapon spread bonus", 0.0, -1)
            // weapon_primary.AddAttribute("Projectile speed increased", 3.0, -1)
            if (WeaponIs(weapon_primary, "syringe_gun"))
            {
                SyringeGun = weapon_primary;
                SyringeGun.AddAttribute("add uber charge on hit", 0.008, -1)
                SyringeGun.AddAttribute("damage bonus", 1.50, -1)
            }
            else if (WeaponIs(weapon_primary, "overdose"))
            {
                // Delfite: Removing the old active movement speed bonus and replacing it with the passive version.
                weapon_primary.AddAttribute("move speed bonus resource level", 1.0, -1)
                weapon_primary.AddAttribute("damage penalty", 0.8, -1)
                if (WeaponIs(weapon_melee, "vitasaw"))
                    weapon_primary.AddAttribute("move speed bonus", 1.10, -1)
                else
                    weapon_primary.AddAttribute("move speed bonus", 1.20, -1)
            }
            else if (WeaponIs(weapon_primary, "blutsauger"))
            {
                weapon_primary.AddAttribute("heal on hit for rapidfire", 5, -1)
                // weapon_primary.AddAttribute("clip size penalty", 0.75, -1)
            }
        }
        else if (WeaponIs(weapon_primary, "crusaders_crossbow"))
        {
            Crossbow = weapon_primary
        }

        // Secondary definitions.
        weapon_secondary.AddAttribute("ubercharge rate bonus", weapon_secondary.GetAttribute("ubercharge rate bonus", 1.0) + 2, -1);
        if (WeaponIs(weapon_secondary, "medigun"))
        {
            Medigun = weapon_secondary
        }
        else if (WeaponIs(weapon_secondary, "kritzkrieg"))
        {
            weapon_secondary.AddAttribute("uber duration bonus", 2, -1)
            Kritzkrieg = weapon_secondary
        }
        else if (WeaponIs(weapon_secondary, "quick_fix"))
        {
            weapon_secondary.AddAttribute("uber duration bonus", 4, -1)
            QuickFix = weapon_secondary
        }
        else if (WeaponIs(weapon_secondary, "vaccinator"))
        {
            Vaccinator = weapon_secondary
        }
        overheal_penalty = weapon_secondary.GetAttribute("overheal penalty", 1.0)

        // Melee definitions.
		if (WeaponIs(weapon_melee, "bonesaw"))
		{
            weapon_melee.AddAttribute("mult_player_movespeed_active", 1.25, -1)
			// SetPropBool(player, "m_bInPowerPlay", true)
		}
		else if (WeaponIs(weapon_melee, "amputator"))
		{
			// Delfite: Regen: 3 -> 8
            weapon_melee.AddAttribute("health regen", 8, -1)
            Amputator = weapon_melee

			// weapon_melee.AddAttribute("active health regen", 10, -1)
			// Delfite: Unused attribute that overheals with no limit.
			// Not recommended for use in VSH, or anywhere really.
		}
		else if (WeaponIs(weapon_melee, "solemn_vow"))
		{
            weapon_melee.AddAttribute("fire rate penalty", 1.0, -1)
            Solemn_Vow = weapon_melee
		}
		else if (WeaponIs(weapon_melee, "ubersaw"))
		{
            weapon_melee.AddAttribute("fire rate penalty", 1.0, -1)
            weapon_melee.AddAttribute("add uber charge on hit", 0.20, -1)
            Ubersaw = weapon_melee
		}
		else if (WeaponIs(weapon_melee, "vitasaw"))
		{
            Vitasaw = weapon_melee
            // Delfite: "lunchbox adds minicrits" controls the organ spawning mechanic on the Vita-Saw when you hit someone.
            // Setting it to anything other than 2 just disables the mechanic.
            // weapon_melee.AddAttribute("lunchbox adds minicrits", 2, -1)
		}
        RunWithDelay2(this, 0.0, OnApply0Delay)
        player.Regenerate(true)
    }

    function OnApply0Delay()
    {
        SetPropFloat(weapon_secondary, "m_flChargeLevel", 1.0)
    }

    function OnFrameTickAlive()
    {
        active_weapon = player.GetActiveWeapon()

        ChargedSFXPlaybackThink()
        ChargedHealing()

        if (QuickFix == weapon_secondary)
            QuickFixThink()
        if (Kritzkrieg == weapon_secondary)
            KritzkriegThink()

        if (chargedSFXPlayed && GetPropFloat(weapon_secondary, "m_flChargeLevel") < 1.0)
            chargedSFXPlayed = false;
    }

    function OnTickAlive(timeDelta)
    {
        chargeReleased = GetPropBool(weapon_secondary, "m_bChargeRelease")

        if (weapon_primary == Crossbow)
            CrossbowSlowThink()

        if (weapon_melee == Ubersaw)
            UbersawTauntSlowThink()
    }

    function OnDamageDealt(victim, params)
    {
        if ((weapon_melee == Ubersaw || weapon_primary == SyringeGun) && IsValidBoss(victim))
        {
            RunWithDelay2(this, 0.1, function ()
            {
                // printdev("First succeeded.")
                if (player.IsAlive() && active_weapon == (Ubersaw || SyringeGun) && !chargedSFXPlaybackRunning && !chargedSFXPlayed)
                {
                    // printdev("Second succeeded.")
                    if (!WeaponIs(weapon_secondary, "vaccinator") && GetPropFloat(weapon_secondary, "m_flChargeLevel") == 1.0)
                        MedigunChargeSFX()
                    else if (WeaponIs(weapon_secondary, "vaccinator") && GetPropFloat(weapon_secondary, "m_flChargeLevel") >= 0.25)
                        MedigunChargeSFX()
                }
            })
        }

        if (params.weapon == Vitasaw)
        {
            local organs = GetPropInt(player, "m_Shared.m_iDecapitations");
            // printdev(organs)
            if (player.IsAlive())
            {
                local move_speed_bonus = player.GetCustomAttribute("move speed bonus", 1.0)
                local max_health_bonus = player.GetCustomAttribute("max health additive bonus", 0)
                if (organs < 5)
                {
                    player.AddCustomAttribute("move speed bonus", move_speed_bonus + 0.075, -1)
                    player.AddCustomAttribute("max health additive bonus", max_health_bonus + 15, -1)
                }

                if (player.GetHealth() > player.GetMaxHealth())
                    return;

                player.SetHealth(clampCeiling(player.GetMaxHealth(), player.GetHealth() + 15))
            }
        }
    }

    function OnDamageTaken(attacker, params)
    {
        if (weapon_melee == Solemn_Vow && !player.IsInvulnerable() && IsValidBoss(attacker))
        {
            player.AddCondEx(TF_COND_SPEED_BOOST, 8, null)
            RunWithDelay2(this, 1.5, function ()
            {
                if (!player.IsAlive())
                    return;

                if (!(player.GetHealth() > player.GetMaxHealth()))
                    player.SetHealth(clampCeiling(player.GetMaxHealth(), player.GetHealth() + 75))
                EmitSoundOn("HealthKit.Touch", player)
            })
        }
    }

    function MedigunChargeSFX()
    {
        EmitSoundOn("WeaponMedigun.Charged", player)
        chargedSFXPlaybackRunning = true;
        chargedSFXPlayed = true;
        RunWithDelay2(this, 0.2, function ()
        {
            if (!player.IsAlive())
                return;

            local auto_charge_ready = auto_charge_ready_array[RandomInt(0, 2)];
            EmitSoundEx(
            {
                sound_name = auto_charge_ready
                volume = 1.0
                entity = player
            })
        })
    }

    function CrossbowSlowThink()
    {
        if (player.IsCritBoosted())
        {
            if (crossbowPenaltyApplied)
                return;

            Crossbow.AddAttribute("dmg penalty vs players", 0.4, -1)
            crossbowPenaltyApplied = true;
        }
        else
        {
            if (!crossbowPenaltyApplied)
                return;

            Crossbow.RemoveAttribute("dmg penalty vs players")
            crossbowPenaltyApplied = false;
        }
    }

    function UbersawTauntSlowThink()
    {
        if (Ubersaw)
        {
            if (active_weapon == Ubersaw && player.InCond(TF_COND_TAUNTING))
                Ubersaw.AddAttribute("add uber charge on hit", 0.25, -1)
            else
                Ubersaw.AddAttribute("add uber charge on hit", 0.20, -1)
        }
    }

    function ChargedSFXPlaybackThink()
    {
        if (chargedSFXPlaybackRunning)
        {
            if (WeaponIs(active_weapon, "any_medigun"))
            {
                // Delfite: This sound effect loops forever. Stop it manually when we switch to our secondary so the sounds don't stack.
                StopSoundOn("WeaponMedigun.Charged", player)
                chargedSFXPlaybackRunning = false;
            }
        }
    }

    function ChargedHealing()
    {
        if (player.IsAlive())
        {
            // printdev("Healing active.")
            if (chargeReleased && (active_weapon == Medigun && player.IsInvulnerable()) || (Kritzkrieg && player.InCond(TF_COND_CRITBOOSTED)))
            {
                player.SetHealth(clampCeiling(player.GetMaxHealth() * 1.5, player.GetHealth() + 1))
                chargedHealingActive = true;
            }
            // Delfite: Disabling the Vaccinator changes for now until I can figure out how to stop other medics from triggering the heal with their ubers.
            // else if ((player.InCond(TF_COND_MEDIGUN_UBER_BULLET_RESIST) || player.InCond(TF_COND_MEDIGUN_UBER_BLAST_RESIST) || player.InCond(TF_COND_MEDIGUN_UBER_FIRE_RESIST)) && active_weapon == Vaccinator)
            // {
            //     player.SetHealth(clampCeiling(player.GetMaxHealth() * 1.5, player.GetHealth() + 1))
            //     chargedHealingActive = true;
            // }
            else
                chargedHealingActive = false;
        }

        // Delfite: Since we're being healed by our ubercharge, we should nerf the healing received from other medics so it doesn't become stupidly strong.
        if (chargedHealingActive)
        {
            if (healerDebuffApplied)
                return;

            weapon_secondary.AddAttribute("mult_health_fromhealers_penalty_active", 0.1, -1)
            healerDebuffApplied = true;

            if (Kritzkrieg)
            {
                weapon_primary.AddAttribute("mult_health_fromhealers_penalty_active", 0.1, -1)
                weapon_melee.AddAttribute("mult_health_fromhealers_penalty_active", 0.1, -1)
            }
        }
        else if (!chargedHealingActive)
        {
            if (!healerDebuffApplied)
                return;

            weapon_secondary.RemoveAttribute("mult_health_fromhealers_penalty_active")
            weapon_primary.RemoveAttribute("mult_health_fromhealers_penalty_active")
            weapon_melee.RemoveAttribute("mult_health_fromhealers_penalty_active")
            healerDebuffApplied = false;
        }
    }

    // Delfite: This function is responsible for the Quick-Fix's overheal cap adjustment.
    function QuickFixThink()
    {
        if (QuickFix)
        {
            if (chargeReleased)
            {
                if (extraOverhealApplied)
                    return;

                QuickFix.AddAttribute("overheal penalty", 1.0, -1)
                QuickFix.AddAttribute("overheal bonus", 2.0, -1)
                extraOverhealApplied = true;
            }
            else
            {
                if (!extraOverhealApplied)
                    return;

                QuickFix.AddAttribute("overheal penalty", overheal_penalty, -1)
                QuickFix.RemoveAttribute("overheal bonus")
                extraOverhealApplied = false;
            }
        }
    }

    // Delfite: This function is responsible for the Kritzkrieg's infinite ammo and self-kritz for the Medic.
    function KritzkriegThink()
    {
        // printdev("Previous Charge: " + previous_charge + " | Current Charge: " + current_charge)
        // printdev("chargeReleased: " + chargeReleased)

        if (Kritzkrieg)
        {
            // printdev("chargeReleased: " + chargeReleased)
            if (chargeReleased)
            {
                // Delfite: Not sure why, but if we don't set the Medic's condition every few seconds, the crits will fade when they're not supposed to.
                // I'm just gonna set the condition every tick. There isn't really a point in adding a timer here, and adding a RunWithDelay2 inside this
                // tick function will cause a server crash within a few minutes, even IF the delay is super tiny (0.0001, etc.)
                player.AddCondEx(TF_COND_CRITBOOSTED, -1, player)
                kritzChargeActive = true;
            }
            else if (kritzChargeActive && !chargeReleased)
            {
                player.RemoveCondEx(TF_COND_CRITBOOSTED, true)
                EmitSoundOn("DemoCharge.ChargeCritOff", player)
                kritzChargeActive = false;
            }

            if (kritzChargeActive && active_weapon == weapon_primary)
            {
                if (medic_mag == 0)
                    medic_mag = (weapon_primary.Clip1() + 1)
                else if (!medicMagIsStored)
                {
                    medic_mag = weapon_primary.Clip1()

                    if (medic_mag > 0)
                        medicMagIsStored = true;
                }
                else if (medic_mag > 0)
                    weapon_primary.SetClip1(medic_mag)


                if (medic_reserve == 0)
                    medic_reserve = SetPropInt(player, "m_iAmmo.001", GetPropInt(player, "m_iAmmo.001") + 1)
                else if (!medicReserveIsStored)
                {
                    medic_reserve = GetPropInt(player, "m_iAmmo.001")

                    if (medic_reserve > 0)
                        medicReserveIsStored = true;
                }
                else if (medic_reserve > 0)
                    SetPropInt(player, "m_iAmmo.001", medic_reserve)
            }
            else
            {
                medic_mag = 0;
                medic_reserve = 0;
                medicMagIsStored = false;
                medicReserveIsStored = false;
            }
        }

        local patient = player.GetHealTarget()
        if (patient == null)
        {
            patient_primary_mag = null;
            patient_secondary_mag = null;
            patient_primary_reserve = null;
            patient_secondary_reserve = null;
            primaryMagIsStored = false;
            secondaryMagIsStored = false;
            primaryReserveIsStored = false;
            secondaryReserveIsStored = false;
            return;
        }

        local patient_active_weapon = patient.GetActiveWeapon()
        local patient_primary = patient.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY)
        local patient_secondary = patient.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY)

        if (patient_active_weapon == null)
            return;

        if (patient_active_weapon == patient_primary)
        {
            if (patient.InCond(TF_COND_CRITBOOSTED))
            {
                if (patient_primary_mag == 0)
                    patient_primary_mag = (patient_primary.Clip1() + 1)
                else if (!primaryMagIsStored)
                {
                    patient_primary_mag = patient_primary.Clip1()

                    if (patient_primary_mag > 0)
                        primaryMagIsStored = true;
                }
                else if (patient_primary_mag > 0)
                    patient_primary.SetClip1(patient_primary_mag)


                if (patient_primary_reserve == 0)
                    patient_primary_reserve = SetPropInt(patient, "m_iAmmo.001", GetPropInt(patient, "m_iAmmo.001") + 1)
                else if (!primaryReserveIsStored)
                {
                    patient_primary_reserve = GetPropInt(patient, "m_iAmmo.001")

                    if (patient_primary_reserve > 0)
                        primaryReserveIsStored = true;
                }
                else if (patient_primary_reserve > 0)
                    SetPropInt(patient, "m_iAmmo.001", patient_primary_reserve)
            }
            else
            {
                patient_primary_mag = null;
                patient_primary_reserve = null;
                primaryMagIsStored = false;
                primaryReserveIsStored = false;
            }
        }
        else if (patient_active_weapon == patient_secondary)
        {
            if (patient.InCond(TF_COND_CRITBOOSTED))
            {
                if (patient_secondary_mag == 0)
                    patient_secondary_mag = (patient_secondary.Clip1() + 1)
                else if (!secondaryMagIsStored)
                {
                    patient_secondary_mag = patient_secondary.Clip1()

                    if (patient_secondary_mag > 0)
                        secondaryMagIsStored = true;
                }
                else if (patient_secondary_mag > 0)
                    patient_secondary.SetClip1(patient_secondary_mag)


                if (patient_secondary_reserve == 0)
                    patient_secondary_reserve = SetPropInt(patient, "m_iAmmo.002", GetPropInt(patient, "m_iAmmo.002") + 1)
                else if (!secondaryReserveIsStored)
                {
                    patient_secondary_reserve = GetPropInt(patient, "m_iAmmo.002")

                    if (patient_secondary_reserve > 0)
                        secondaryReserveIsStored = true;
                }
                else if (patient_secondary_reserve > 0)
                    SetPropInt(patient, "m_iAmmo.002", patient_secondary_reserve)
            }
            else
            {
                patient_secondary_mag = null;
                patient_secondary_reserve = null;
                secondaryMagIsStored = false;
                secondaryReserveIsStored = false;
            }
        }
    }

    function OnDeath(attacker, params)
    {
        StopSoundOn("WeaponMedigun.Charged", player)
    }

    function OnDiscard()
    {
        StopSoundOn("WeaponMedigun.Charged", player)
        player.RemoveCond(TF_COND_CRITBOOSTED)

        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("mult_health_fromhealers_penalty_active");
            weapon_primary.RemoveAttribute("dmg penalty vs players");
        }

        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("mult_health_fromhealers_penalty_active");
            weapon_secondary.RemoveAttribute("ubercharge rate bonus");
        }

        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("mult_health_fromhealers_penalty_active");
        }
    }
});