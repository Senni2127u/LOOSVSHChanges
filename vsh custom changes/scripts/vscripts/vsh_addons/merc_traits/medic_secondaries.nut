//Script created by Senni, Assistance from Bradasparky.
//Script handles Medic starting with full ubercharge at the beginning of rounds.
// No required modifications to base gamemode files.

PrecacheScriptSound("DemoCharge.ChargeCritOn")
PrecacheScriptSound("DemoCharge.ChargeCritOff")

characterTraitsClasses.push(class extends CharacterTrait
{
    // weapon_primary = null;
    // weapon_secondary = null;
    // weapon_melee = null;
    Medigun = null;
    Kritzkrieg = null;
    Quick_Fix = null;
    Vaccinator = null;

    medic_mag = 0;
    medic_reserve = 0;
    primary_mag = 0;
    primary_reserve = 0;
    patient_primary_reserve = 0;
    patient_secondary_reserve = 0;
    patient_primary_mag = 0;
    patient_secondary_mag = 0;

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

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_MEDIC;
    }

    function OnApply()
    {
        // weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        // weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        // weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        weapon_secondary.AddAttribute("ubercharge rate bonus", weapon_secondary.GetAttribute("ubercharge rate bonus", 1.0) + 2, -1);
        SetPropFloat(weapon_secondary, "m_flChargeLevel", 1.0)

        if (WeaponIs(weapon_secondary, "medigun"))
        {
            Medigun = weapon_secondary
        }
        if (WeaponIs(weapon_secondary, "kritzkrieg"))
        {
            weapon_secondary.AddAttribute("uber duration bonus", 2, -1)
            // weapon_secondary.AddAttribute("cancel falling damage", 1, -1)
            Kritzkrieg = weapon_secondary
        }
        if (WeaponIs(weapon_secondary, "quick_fix"))
        {
            weapon_secondary.AddAttribute("overheal penalty", 1.0, -1)
            weapon_secondary.AddAttribute("uber duration bonus", 4, -1)
            Quick_Fix = weapon_secondary
        }
        if (WeaponIs(weapon_secondary, "vaccinator"))
        {
            Vaccinator = weapon_secondary
        }
        // TODO: Make the Frontier Justice fire slugs instead of buckshot.
    }

    function OnFrameTickAlive()
    {
        local active_weapon = player.GetActiveWeapon()
        local chargeReleased = GetPropBool(weapon_secondary, "m_bChargeRelease")
        // printl("Previous Charge: " + previous_charge + " | Current Charge: " + current_charge)
        // printl("chargeReleased: " + chargeReleased)

        ChargedHealing()

        // Delfite: This block is responsible for the Kritzkrieg's infinite ammo and self-kritz for the Medic.
        if (Kritzkrieg)
        {
            // printl("chargeReleased: " + chargeReleased)
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

    function OnDiscard()
    {
        StopSoundOn("DemoCharge.ChargeCritOn", player)
        player.RemoveCond(TF_COND_CRITBOOSTED)

        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("mult_health_fromhealers_penalty_active")
        }

        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("mult_health_fromhealers_penalty_active")
            weapon_secondary.RemoveAttribute("ubercharge rate bonus")
        }

        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("mult_health_fromhealers_penalty_active")
        }
    }

    function ChargedHealing()
    {
        local active_weapon = player.GetActiveWeapon()
        local chargeReleased = GetPropBool(weapon_secondary, "m_bChargeRelease")

        if (player.IsAlive())
        {
            // printl("Healing active.")
            if ((player.IsInvulnerable() && active_weapon == Medigun) || (player.InCond(TF_COND_CRITBOOSTED) && Kritzkrieg) && chargeReleased)
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
});