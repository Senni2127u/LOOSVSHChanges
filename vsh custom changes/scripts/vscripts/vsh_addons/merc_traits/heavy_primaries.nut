//Copyright Delfite, Senni, Bradasparky
// Handles Heavy's spin down time being reduced.
// No required modification to base gamemode files.

PrecacheScriptSound("Player.ResistanceMedium")
PrecacheScriptSound("Player.ResistanceHeavy")

characterTraitsClasses.push(class extends CharacterTrait
{
    // active_weapon = null;
    // weapon_primary = null;

    Brass_Beast = null;
    Natascha = null;

    primaryIsSpunUp = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS;
    }

    function OnApply()
    {
        // weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "minigun"))
        {
            // weapon_primary.AddAttribute("damage penalty", 0.8, -1);
            weapon_primary.AddAttribute("fire rate bonus", 0.85, -1);
            // weapon_primary.AddAttribute("bullets per shot bonus", 1.5, -1);
            // weapon_primary.AddAttribute("aiming movespeed increased", 1.2, -1);
        }
        if (WeaponIs(weapon_primary, "tomislav"))
        {
            // weapon_primary.AddAttribute("fire rate penalty", 1.1, -1);
            // weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1);
        }
        if (WeaponIs(weapon_primary, "huo_long_heater"))
        {
            weapon_primary.AddAttribute("damage penalty", 1.0, -1);
            weapon_primary.AddAttribute("damage bonus vs burning", 1.0, -1);
            weapon_primary.AddAttribute("uses ammo while aiming", 0, -1);
        }
        if (WeaponIs(weapon_primary, "brass_beast"))
        {
            weapon_primary.AddAttribute("damage bonus", 1.0, -1);
            // weapon_primary.AddAttribute("fire rate bonus", 0.85, -1);
            weapon_primary.AddAttribute("patient overheal penalty", 0.5, -1);
            weapon_primary.AddAttribute("spunup_damage_resistance", 1.0, -1);
            weapon_primary.AddAttribute("aiming movespeed decreased", 0.8, -1);

            Brass_Beast = weapon_primary
        }
        if (WeaponIs(weapon_primary, "natascha"))
        {
            weapon_primary.AddAttribute("damage penalty", 1.0, -1);
            weapon_primary.AddAttribute("spunup_damage_resistance", 1.0, -1);
            weapon_primary.AddAttribute("aiming movespeed decreased", 1.0, -1);
            weapon_primary.AddAttribute("slow enemy on hit", 0.15, -1);

            Natascha = weapon_primary
        }
    }

    function OnFrameTickAlive()
    {
        // Checking value of Idle netprop.
        active_weapon = player.GetActiveWeapon()

        if (active_weapon == weapon_primary)
        {
            if (GetPropInt(weapon_primary, "m_iWeaponState") == 0)
            {
                SetPropFloat(weapon_primary, "m_flTimeWeaponIdle", 0.0)
                //local value = NetProps.GetPropFloat(weapon_primary, "m_flTimeWeaponIdle");
                primaryIsSpunUp = false;
            }
            else
                primaryIsSpunUp = true;
        }
        //printl(value);
    }

    function OnDamageDealt(victim, params)
    {
        if (params.weapon == weapon_primary && params.damage_type == DMG_ACID)
        {
            params.damage *= 0.7;
            printl("Damage: " + params.damageamount)
        }
    }

    // function OnHurtDealtEvent(victim, params)
    // {
    //     printl(params.weaponid + " | " + weapon_primary.GetClassname())
    //     if (params.weaponid == TF_WEAPON_MINIGUN && params.bonuseffect == kBonusEffect_Crit)
    //     {
    //         params.damage *= 0.7;
    //         printl("Damage reduced.")
    //     }
    // }

    // function OnFrameTickAlive()
    // {
    //     if (primaryIsPhlog || primaryIsDragonsFury)
    //         return;

    //     local patient_health = player.GetHealth()
    //     // Fixes an issue with the "patient overheal penalty" attribute where Medic gets increased ubercharge rate
    //     // due to the patient's overheal not technically being "full."
    //     if (patient_health == 260 && !isUberRatePenaltyApplied)
    //     {
    //         player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
    //         isUberRatePenaltyApplied = true
    //         //printl("Pyro's HP is at 260, reducing charge rate for Medic.") //Debug.
    //     }
    //     else if (patient_health <= 258 && isUberRatePenaltyApplied)
    //     {
    //         player.AddCustomAttribute("ubercharge rate bonus for healer", 1, -1)
    //         isUberRatePenaltyApplied = false
    //         //printl("Pyro's HP at 258 or below, returning charge rate to normal.") //Another debug.
    //     }
    //     // printl(player.GetAttribute("ubercharge rate bonus for healer", 1.0))
	// }

    function OnDamageTaken(attacker, params)
    {
        // printl("m_iWeaponState: " + GetPropInt(weapon_primary, "m_iWeaponState") + " | " + "primaryIsSpunUp: " + primaryIsSpunUp)
        if (Brass_Beast)
        {
            if (primaryIsSpunUp)
            {
                params.damage *= 0.7;

                if (!player.InCond(TF_COND_DEFENSEBUFF))
                    EmitSoundOnClient("Player.ResistanceHeavy", player)
            }
        }
        else if (Natascha)
        {
            if (primaryIsSpunUp)
            {
                params.damage *= 0.7

                if (!player.InCond(TF_COND_DEFENSEBUFF))
                    EmitSoundOnClient("Player.ResistanceMedium", player)
            }
        }
    }
});