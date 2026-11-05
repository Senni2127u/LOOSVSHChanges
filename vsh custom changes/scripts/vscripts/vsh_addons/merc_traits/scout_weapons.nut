// Script by: Senni, Delfite.
// With assistance from: Bradasparky.
// Script handles everything to do with Scout's weapons.
// All code in this script was previously split into 3 different scripts, one for each weapon slot.
// The code was merged into one file for easier variable management, reduced lag when using Tick functions, and slightly better RAM usage.
// Requires modification of `weapons.nut` to function.

totalHealthKits <- 0;

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;
    weapon_secondary = null;
    weapon_melee = null;

    overheal_quotient = 0;
    overheal_limit = 0;

    //Primary handles.
    Shortstop = null;
    ForceANature = null;

    //Secondary handles.
    Guillotine = null;

    // Melee handles.
    BostonBasher = null;
    CandyCane = null;

    lastTimeApplied = 0;

    victim_late = null;
    lastHitWasCandyCane = false;
    damage_accumulated = 0;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        // Primary definitions.
        if (WeaponIs(weapon_primary, "scattergun"))
        {
            // Delfite: The Scattergun fires 10 pellets per shot. Keep that in mind when changing the damage and pellet count.
            weapon_primary.AddAttribute("damage bonus", 1.40, -1);
            weapon_primary.AddAttribute("weapon spread bonus", 0.85, -1);
            weapon_primary.AddAttribute("fire rate bonus", 0.9, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.9, -1);
            // weapon_primary.AddAttribute("maxammo primary increased", 1.5, -1);
        }
        if (WeaponIs(weapon_primary, "force_a_nature"))
        {
            ForceANature = weapon_primary;
            weapon_primary.AddAttribute("damage penalty", 1.0, -1);
            weapon_primary.AddAttribute("bullets per shot bonus", 2, -1);
            weapon_primary.AddAttribute("maxammo primary reduced", 0.5, -1);
            weapon_primary.AddAttribute("fixed_shot_pattern", 1, -1);
        }
        if (WeaponIs(weapon_primary, "backscatter"))
        {
            // weapon_primary.AddAttribute("spread penalty", 1.0, -1);
            weapon_primary.AddAttribute("minicrits become crits", 1, -1);
            weapon_primary.AddAttribute("bullets per shot bonus", 1.5, -1);
            // weapon_primary.AddAttribute("maxammo primary increased", 1.5, -1);
        }
        if (WeaponIs(weapon_primary, "shortstop"))
        {
            Shortstop = weapon_primary;
            // Delfite: The Shortstop fires 4 pellets per shot, hence why the damage bonus is higher than stock.
            weapon_primary.AddAttribute("damage bonus", 1.5, -1);
            weapon_primary.AddAttribute("fire rate bonus", 0.85, -1);
            weapon_primary.AddAttribute("weapon spread bonus", 0.35, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.85, -1);
            weapon_primary.AddAttribute("maxammo primary increased", 1.5, -1);
        }

        // Secondary definitions.
        if (WeaponIs(weapon_secondary, "pistol"))
        {
            // RunWithDelay2(this, 0.1, function ()
            // {
                weapon_secondary.AddAttribute("maxammo secondary increased", 4.0, -1);
                SetPropInt(player, "m_iAmmo.002", 144)
                // Delfite: Failed attempt at assigning a damage type to a weapon.
                // SetPropInt(weapon_secondary, "m_nDamageType", TF_DMG_CUSTOM_PENETRATE_MY_TEAM)
                // printdev(GetPropInt(weapon_secondary, "m_nDamageType"))
                weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1);
                weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1);
                weapon_secondary.AddAttribute("damage bonus", 1.25, -1);

                // printdev("Pistol stats applied.")
            // })
        }
        if (WeaponIs(weapon_secondary, "pbpp"))
        {
            weapon_secondary.AddAttribute("maxammo secondary increased", 4.0, -1);
            SetPropInt(player, "m_iAmmo.002", 144)
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1);
            weapon_secondary.AddAttribute("heal on hit for rapidfire", 5, -1); // Decimals get rounded to the nearest whole number.
            weapon_secondary.AddAttribute("projectile penetration", 1, -1);
            // Delfite: So, it turns out `player.Regenerate` is hard-coded to only restore
            // 36 reserve ammo to the PBPP SPECIFICALLY. My bewilderment is immeasurable.
			// printdev("PBPP stats applied.")
        }
        if (WeaponIs(weapon_secondary, "winger"))
        {
            weapon_secondary.AddAttribute("maxammo secondary increased", 4.0, -1);
            SetPropInt(player, "m_iAmmo.002", 144)
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1);
            weapon_secondary.AddAttribute("projectile penetration", 1, -1);
			// printdev("Winger stats applied.")
        }
		if (WeaponIs(weapon_secondary, "bonk_atomic_punch"))
        {
            weapon_secondary.AddAttribute("effect bar recharge rate increased", 0.65, -1);
			// printdev("Bonk stats applied.")
        }
		if (WeaponIs(weapon_secondary, "crit_a_cola"))
        {
            weapon_secondary.AddAttribute("mod_mark_attacker_for_death", 0, -1);
            weapon_secondary.AddAttribute("effect bar recharge rate increased", 0.65, -1);
			// printdev("Crit-a-cola stats applied.")
        }
		if (WeaponIs(weapon_secondary, "flying_guillotine"))
        {
            Guillotine = weapon_secondary;
            // Delfite: 225 damage crit, accounting for bleed.
            weapon_secondary.AddAttribute("minicrits become crits", 1, -1);
            // weapon_secondary.AddAttribute("dmg penalty vs players", 0.65, -1);
            // Delfite: Recharge time: 5 seconds -> 8 seconds (+60%)
            // To compensate for the crit damage, we'll make the cleaver take a little longer to recharge.
            // weapon_secondary.AddAttribute("effect bar recharge rate increased", 1.6, -1);
            weapon_secondary.AddAttribute("bleeding duration", 10, -1);
			// printdev("Guillotine stats applied.")
        }

        // Melee definitions.
        if (WeaponIs(weapon_melee, "bat"))
        {
            weapon_melee.AddAttribute("damage bonus", 1.86, -1);
            // printdev("Bat stats applied.")
        }
        if (WeaponIs(weapon_melee, "atomizer"))
        {
            weapon_melee.AddAttribute("deploy time increased", 1.25, -1);
            // printdev("Atomizer stats applied.")
        }
        if (WeaponIs(weapon_melee, "boston_basher"))
        {
            BostonBasher = weapon_melee;
            // weapon_melee.AddAttribute("damage bonus", 1.5, -1);
            weapon_melee.AddAttribute("bleeding duration", 10, -1);
            // printdev("Boston Basher stats applied.")
        }
        if (WeaponIs(weapon_melee, "candy_cane"))
        {
            CandyCane = weapon_melee;
            weapon_melee.AddAttribute("dmg taken from blast increased", 1.0, -1);
            // printdev("Candy Cane stats applied.")
        }

        RunWithDelay2(this, 0.0, OnApply0Delay)
        RunWithDelay2(this, 0.05, OnApply05Delay)
    }

    function OnApply0Delay()
    {
        // Delfite: The Shortstop uses the `provide on active` attribute for its stats, so
        // we need to apply the max health bonus as a player attribute instead.
        if (weapon_primary == Shortstop)
            player.AddCustomAttribute("max health additive bonus", 25, -1);
    }

    function OnApply05Delay()
    {
        // Delfite: If you want to define the player's max overheal for a specific weapon/combination of weapons, do it here.
        // The purpose of this is to reduce calls to C++ functions for performance reasons. That includes stuff like GetMaxHealth.
		overheal_quotient = player.GetMaxHealth() / 2
        switch (weapon_primary)
        {
            default:
                overheal_limit = player.GetMaxOverheal()
            break;
        }
    }

    // function OnAmmoPickup(index, params)
    // {
    //     printdev("OnAmmoPickup fired.")
    //     printdev("Index: " + index)
    //     if (weapon_primary == ForceANature && index == 1)
    //         if (params.amount < 8)
    //         {
    //             SetPropInt(player, "m_iAmmo.001", 8)
    //             printdev("Amount: " + params.amount + " | Ammo: " + GetPropInt(player, "m_iAmmo.001"))
    //         }

    // }

    function OnDamageDealt(victim, params)
    {
        lastHitWasCandyCane = params.weapon == CandyCane;

        if (params.weapon == ForceANature)
            ForceANatureKnockback(victim, params)

        // Delfite: This code controls the Boston Basher's "air-climbing" behavior, as well as its self-bleed removal.
        if (params.weapon == BostonBasher && victim == player)
        {
            player.RemoveCond(TF_COND_BLEEDING)
            if (params.damage_type & DMG_CLUB)
            {
                // Delfite: Give the player some extra height when they hit themselves with the Boston Basher.
                local deltaVector = player.GetCenter() - params.inflictor.GetOrigin();
                deltaVector.Norm();
                player.Yeet(deltaVector * 400);
                params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
                // printdev("Player launched.")
            }
        }

        if (params.inflictor == Guillotine)
        {

        }

        if (weapon_melee == BostonBasher)
        {
            if (params.inflictor == Guillotine)
                return;
            if (params.damage_custom & TF_DMG_CUSTOM_BLEEDING)
            {
                params.damage_type = params.damage_type | DMG_ACID;
                // printdev("Bleed damage dealt.")
            }
        }
    }

    // Delfite: This code controls the Force-a-Nature's enhanced knockback.
    function ForceANatureKnockback(victim, params)
    {
        if (Time() - lastTimeApplied < 0.1)
            return;

        params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
        local deltaVector = victim.GetOrigin() - player.GetOrigin();
        deltaVector.z = 100;
        local distance = deltaVector.Norm();
        if (distance < 600)
            // TODO: Nerf knockback dealt by the FAN while by Kritz'd by a Medic.
            if (!player.InCond(TF_COND_CRITBOOSTED))
                victim.Yeet(deltaVector * (300 - distance / 2));
    }

    function OnHurtDealtEvent(victim, params)
    {
        // Delfite: This code has dominion over the Candy Cane's medkit spawning mechanic.
        if (weapon_melee == CandyCane)
        {
            victim_late = victim;

            if (vsh_vscript.totalHealthKits > 30)
                return;

            damage_accumulated += params.damageamount;
            if (damage_accumulated >= 150)
            {
                damage_accumulated -= 150;
                SpawnMedkit()
            }
            else if (lastHitWasCandyCane)
                SpawnMedkit()
        }
    }

    function SpawnMedkit()
    {
        local healthKit = SpawnEntityFromTable("item_healthkit_small",
        {
            "OnPlayerTouch": "!self,Kill,,0,-1",
        });
        vsh_vscript.totalHealthKits++;
        healthKit.SetMoveType(Constants.EMoveType.MOVETYPE_FLYGRAVITY, Constants.EMoveCollide.MOVECOLLIDE_FLY_BOUNCE);
        healthKit.SetAbsOrigin(victim_late.GetCenter());
        healthKit.SetVelocity(Vector(RandomFloat(-80, 80), RandomFloat(-80, 80), 200));
        RunWithDelay2(this, 30, function(healthKit)
        {
            vsh_vscript.totalHealthKits--;
            if (healthKit != null && healthKit.IsValid())
                healthKit.Kill();
        }, healthKit);
    }

    function OnDiscard()
	{
		// Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("weapon spread bonus");
            weapon_primary.RemoveAttribute("reload time decreased");
            //printdev("Secondary attributes discarded.")
        }
	}
});