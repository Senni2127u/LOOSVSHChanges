//Copyright: Delfite

PrecacheScriptSound("HealthKit.Touch")
PrecacheScriptSound("WeaponMedigun.Charged")
PrecacheScriptSound("Medic.AutoChargeReady01")
PrecacheScriptSound("Medic.AutoChargeReady02")
PrecacheScriptSound("Medic.AutoChargeReady03")

::auto_charge_ready_array <- [
    "Medic.AutoChargeReady01",
    "Medic.AutoChargeReady02",
    "Medic.AutoChargeReady03"
]

characterTraitsClasses.push(class extends CharacterTrait
{
    active_weapon = null;
    // weapon_primary = null;
    // weapon_secondary = null;
    // weapon_melee = null;

    Amputator = null;
    Solemn_Vow = null;
    Ubersaw = null;
    Vitasaw = null;

    chargedSFXPlaybackRunning = false;
    chargedSFXPlayed = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_MEDIC;
    }

    function OnApply()
    {
        // weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        // weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        // weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

		if (WeaponIs(weapon_melee, "bonesaw"))
		{
            weapon_melee.AddAttribute("mult_player_movespeed_active", 1.25, -1)
			// SetPropBool(player, "m_bInPowerPlay", true)
		}
		if (WeaponIs(weapon_melee, "amputator"))
		{
			// Delfite: Regen: 3 -> 8
            weapon_melee.AddAttribute("health regen", 8, -1)
            Amputator = weapon_melee

			// weapon_melee.AddAttribute("active health regen", 10, -1)
			// Delfite: Unused attribute that overheals with no limit.
			// Not recommended for use in VSH, or anywhere really.
		}
		if (WeaponIs(weapon_melee, "solemn_vow"))
		{
            weapon_melee.AddAttribute("fire rate penalty", 1.0, -1)
            Solemn_Vow = weapon_melee
		}
		if (WeaponIs(weapon_melee, "ubersaw"))
		{
            weapon_melee.AddAttribute("fire rate penalty", 1.0, -1)
            weapon_melee.AddAttribute("add uber charge on hit", 0.20, -1)
            Ubersaw = weapon_melee
		}
		if (WeaponIs(weapon_melee, "vitasaw"))
		{
            // Delfite: "lunchbox adds minicrits" controls the organ spawning mechanic on the Vita-Saw when you hit someone.
            // Setting it to anything other than 2 just disables the mechanic, so pretend it doesn't exist.
            // weapon_melee.AddAttribute("lunchbox adds minicrits", 2, -1)
            Vitasaw = weapon_melee
		}
        player.Regenerate(true)
    }

    function OnFrameTickAlive()
    {
        active_weapon = player.GetActiveWeapon()

        if (Ubersaw)
        {
            if (active_weapon == Ubersaw && player.InCond(TF_COND_TAUNTING))
                Ubersaw.AddAttribute("add uber charge on hit", 0.25, -1)
            else
                Ubersaw.AddAttribute("add uber charge on hit", 0.20, -1)
        }

        if (chargedSFXPlaybackRunning)
        {
            if (WeaponIs(active_weapon, "any_medigun"))
            {
                // Delfite: This sound effect loops forever. Stopping it manually when we switch to our secondary stops the sounds from stacking.
                StopSoundOn("WeaponMedigun.Charged", player)
                chargedSFXPlaybackRunning = false;
            }
        }

        if (!chargedSFXPlayed)
            return;

        if (GetPropFloat(weapon_secondary, "m_flChargeLevel") < 1.0)
        {
            chargedSFXPlayed = false;
        }
    }

    function OnDamageDealt(victim, params)
    {
        if ((Ubersaw || WeaponIs(weapon_primary, "syringe_gun")) && IsValidBoss(victim))
        {
            RunWithDelay2(this, 0.1, function ()
            {
                // printl("First succeeded.")
                if (player.IsAlive() && (WeaponIs(active_weapon, "ubersaw") || WeaponIs(active_weapon, "syringe_gun")) && !chargedSFXPlaybackRunning && !chargedSFXPlayed)
                {
                    // printl("Second succeeded.")
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
            // printl(organs)
            if (player.IsAlive())
            {
                local move_speed_bonus = player.GetCustomAttribute("move speed bonus", 1.0)
                local max_health_bonus = player.GetCustomAttribute("max health additive bonus", 0)
                if (organs < 5)
                {
                    player.AddCustomAttribute("move speed bonus", move_speed_bonus + 0.07, -1)
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
        if (Solemn_Vow && !player.IsInvulnerable() && IsValidBoss(attacker))
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

    function OnDiscard()
    {
        StopSoundOn("WeaponMedigun.Charged", player)

        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("move speed bonus");
            weapon_melee.RemoveAttribute("max health additive bonus");
            weapon_melee.RemoveAttribute("damage bonus");
            weapon_melee.RemoveAttribute("damage penalty");
            weapon_melee.RemoveAttribute("fire rate bonus");
            weapon_melee.RemoveAttribute("heal on hit for rapidfire");
            weapon_melee.RemoveAttribute("clip size penalty");
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
});