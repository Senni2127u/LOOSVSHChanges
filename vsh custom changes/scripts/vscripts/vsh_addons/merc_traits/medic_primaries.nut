//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
    // weapon_primary = null;

    Crossbow = null;

    crossbowPenaltyApplied = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_MEDIC;
    }

    function OnApply()
    {
        // weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        local weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        if (!WeaponIs(weapon_primary, "crusaders_crossbow"))
        {
            // Delfite: Only god knows why, but the "projectile speed increased" attribute doesn't work on Syringe Guns. Damn you Valve!
            weapon_primary.AddAttribute("fire rate bonus", 0.70, -1)
            weapon_primary.AddAttribute("reload time decreased", 0.60, -1)
            weapon_primary.AddAttribute("maxammo primary increased", 2.0, -1)
            weapon_primary.AddAttribute("weapon spread bonus", 0.0, -1)
            // weapon_primary.AddAttribute("Projectile speed increased", 10.0, -1)
            if (WeaponIs(weapon_primary, "syringe_gun"))
            {
                weapon_primary.AddAttribute("add uber charge on hit", 0.008, -1)
                weapon_primary.AddAttribute("damage bonus", 1.50, -1)
                // weapon_primary.AddAttribute("weapon spread bonus", 0.0, -1)
            }
            if (WeaponIs(weapon_primary, "overdose"))
            {
                // Delfite: Removing the old active movement speed bonus and replacing it with the passive version.
                weapon_primary.AddAttribute("move speed bonus resource level", 1.0, -1)
                weapon_primary.AddAttribute("damage penalty", 0.8, -1)

                if (WeaponIs(weapon_melee, "vitasaw"))
                    weapon_primary.AddAttribute("move speed bonus", 1.10, -1)
                else
                    weapon_primary.AddAttribute("move speed bonus", 1.20, -1)
            }
            if (WeaponIs(weapon_primary, "blutsauger"))
            {
                weapon_primary.AddAttribute("heal on hit for rapidfire", 5, -1)
                // weapon_primary.AddAttribute("clip size penalty", 0.75, -1)
            }
        }
        else if (WeaponIs(weapon_primary, "crusaders_crossbow"))
        {
            Crossbow = weapon_primary
        }
        player.Regenerate(true)
    }

    function OnFrameTickAlive()
    {
        if (Crossbow && player.IsCritBoosted())
        {
            if (crossbowPenaltyApplied)
                return;

            Crossbow.AddAttribute("dmg penalty vs players", 0.4, -1)
            crossbowPenaltyApplied = true;
        }
        else if (Crossbow && crossbowPenaltyApplied)
        {
            Crossbow.RemoveAttribute("dmg penalty vs players")
            crossbowPenaltyApplied = false;
        }

        // Delfite: BEWARE OF JANK: While this code *does* have the intended effect of making syringes more consistent to hit by making them faster,
        // it comes at the downside of desyncing the syringes since they're client-sided. I do not recommend enabling this code.
        // if (!Crossbow)
        // {
        //     local projectile = null;
        //     while (projectile = FindByClassname(projectile, "tf_projectile_syringe"))
        //     {
        //         if (projectile.GetOwner() == player) // projectile is a class object, aka an "instance".
        //         {
        //             projectile.ValidateScriptScope()
        //             local projectileScope = projectile.GetScriptScope();
        //             if (!("CHECKED" in projectileScope))
        //             {
        //                 // projectile.SetGravity(0)
        //                 projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3)
        //                 // printl(projectile + " | " + projectile.GetAbsVelocity())
        //                 projectileScope["CHECKED"] <- null;
        //             }
        //         }
        //     }
        // }
    }

    function OnPatientHealed(healer, params)
    {
        if (params.patient == healer)
        {
            local patient = GetPlayerFromUserID(params.patient)
            if (patient.GetPlayerClass() == TF_CLASS_MEDIC)
                patient.SetHealth(patient.GetHealth() - params.amount)
        }
    }

    function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("Projectile speed increased")
            weapon_primary.RemoveAttribute("move speed bonus resource level");
            weapon_primary.RemoveAttribute("move speed bonus");
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("damage penalty");
            weapon_primary.RemoveAttribute("fire rate bonus");
            weapon_primary.RemoveAttribute("heal on hit for rapidfire");
            weapon_primary.RemoveAttribute("clip size penalty");
            weapon_primary.RemoveAttribute("reload time decreased");
            weapon_primary.RemoveAttribute("maxammo primary increased");
            weapon_primary.RemoveAttribute("dmg penalty vs players");
        }
    }
});