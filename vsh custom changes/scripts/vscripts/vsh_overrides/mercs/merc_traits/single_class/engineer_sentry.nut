//=========================================================================
//Copyright LizardOfOz.
//
//Credits:
//  LizardOfOz - Programming, game design, promotional material and overall development. The original VSH Plugin from 2010.
//  Maxxy - Saxton Hale's model imitating Jungle Inferno SFM; Custom animations and promotional material.
//  Velly - VFX, animations scripting, technical assistance.
//  JPRAS - Saxton model development assistance and feedback.
//  MegapiemanPHD - Saxton Hale and Gray Mann voice acting.
//  James McGuinn - Mercenaries voice acting for custom lines.
//  Yakibomb - give_tf_weapon script bundle (used for Hale's first-person hands model).
//  Phe - game design assistance.
//=========================================================================

PrecacheScriptSound("Powerup.PickUpTemp.Crit")
PrecacheScriptSound("Building_Sentry.Damage")

AddListener("setup_start", 1, function()
{
	// Delfite: These cvars control everything to do with Sentry Guns. Their values are set every time setup starts.
	// These cvars are also hidden in-game and considered dev commands, but can still be set by VScript nonetheless.
	// Most of these commands aren't super useful within the context of VSH, but I thought putting them here would be
	// good as a means of documenting their existence. Plus, the ammo cheat comes in handy for testing.
	Convars.SetValue("tf_sentrygun_ammocheat", 0)                                                   // Default: 0
	Convars.SetValue("tf_sentrygun_notarget", 0)                                                    // Default: 0
	Convars.SetValue("tf_sentrygun_damage", 16)                                                     // Default: 16
	Convars.SetValue("tf_sentrygun_kill_after_redeploy_time_achievement", 10)                       // Default: 10
	Convars.SetValue("tf_sentrygun_max_absorbed_damage_while_controlled_for_achievement", 500)      // Default: 500
	Convars.SetValue("tf_sentrygun_metal_per_rocket", 2)                                            // Default: 2
	Convars.SetValue("tf_sentrygun_metal_per_shell", 1)                                             // Default: 1
	Convars.SetValue("tf_sentrygun_mini_damage", 8)                                                 // Default: 8
	Convars.SetValue("tf_sentrygun_newtarget_dist", 200)                                            // Default: 200

	// printdev("tf_sentrygun_ammocheat = " + Convars.GetFloat("tf_sentrygun_ammocheat"))
	// printdev("tf_sentrygun_notarget = " + Convars.GetFloat("tf_sentrygun_notarget"))
	// printdev("tf_sentrygun_damage = " + Convars.GetFloat("tf_sentrygun_damage"))
	// printdev("tf_sentrygun_kill_after_redeploy_time_achievement = " + Convars.GetFloat("tf_sentrygun_kill_after_redeploy_time_achievement"))
	// printdev("tf_sentrygun_max_absorbed_damage_while_controlled_for_achievement = " + Convars.GetFloat("tf_sentrygun_max_absorbed_damage_while_controlled_for_achievement"))
	// printdev("tf_sentrygun_metal_per_rocket = " + Convars.GetFloat("tf_sentrygun_metal_per_rocket"))
	// printdev("tf_sentrygun_metal_per_shell = " + Convars.GetFloat("tf_sentrygun_metal_per_shell"))
	// printdev("tf_sentrygun_mini_damage = " + Convars.GetFloat("tf_sentrygun_mini_damage"))
	// printdev("tf_sentrygun_newtarget_dist = " + Convars.GetFloat("tf_sentrygun_newtarget_dist"))
});

AddListener("object_hurt", 1, function(attacker, object, params)
{
    if (!IsValidBoss(attacker))
        return;
    local building_type = GetPropInt(object, "m_iObjectType")
    if (building_type != 2)
        return;
    // printdev("Sentry took damage.")
    local soundlevel = (40 + (20 * log10(radius / 36.0))).tointeger();
    EmitSoundEx(
        sound_name = "Building_Sentry.Damage"
        volume = 1.0
        sound_level = soundLevel
        entity = object
    )
    EmitSoundOn("Building_Sentry.Damage", object)
});

characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;
	weapon_secondary = null;
	weapon_melee = null;
	Pistol = null;
    sentrygun = null;
	sentryDamageAccumulated = 0;

    sentry_level_limit = 2
    dispenser_level_limit = 2
    teleporter_level_limit = 2

    teleporter_entrance = null;
    teleporter_exit = null;

	lastHitSentry = null;
    sentryCritsActive = false;
	primaryIsFrontierJustice = false;
	usingMiniSentry = false;

    you = null;


	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

    // TODO: Implement "Building_Sentrygun.ShaftLaserPass" as a ScriptSound that plays when Hale gets spotted by a wrangled sentry.
    function OnApply()
    {
        you = player;
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        if (WeaponIs(weapon_primary, "frontier_justice"))
            primaryIsFrontierJustice = true;
        if (WeaponIs(weapon_secondary, "pistol"))
            Pistol = weapon_secondary
        if (WeaponIs(weapon_melee, "gunslinger"))
            usingMiniSentry = true;
    }

    function OnDamageDealt(victim, params)
    {
        if (params.inflictor != null && params.inflictor.GetClassname() == "obj_sentrygun" && player != victim)
        {
            // Delfite: As it would turn out, sentries (without a damage nerf), do a LOT of damage, and even more while the Engie is under Mini-crits.
            // They also do a lot of knockback. So much knockback that even with a 50% damage penalty, a single Level 2 Sentry can easily stuff a Brave Jump
            // from Hale, making map traversal much more annoying for him and creating a not-so-fun-to-fight-against situation for him. This, combined with
            // multiple sentries often being in play, necessitated a solution. Sentries now inflict SUBSTANTIALLY less knockback on Hale, but sentries will
            // be easier to build in order to compensate. Hopefully this rework makes Engineer more fun to play as and against.

            if (player.IsAlive())
            {
                params.damage_type = DMG_PREVENT_PHYSICS_FORCE;
                foreach (player in GetAliveMercs())
                {
                    if (player.GetPlayerClass() == TF_CLASS_MEDIC && player.GetHealTarget() == you)
                    {
                        local chargeReleased = GetPropBool(weapon_secondary, "m_bChargeRelease")
                        if (player.chargeReleased)
                            params.damage_type = DMG_PREVENT_PHYSICS_FORCE | Constants.FDmgType.DMG_ACID;
                    }
                }
            }
            else
                params.damage_type = DMG_PREVENT_PHYSICS_FORCE;

            params.damage *= usingMiniSentry ? 0.8 : 0.5;
            lastHitSentry = params.inflictor;
            // printdev("Sentrygun dealt damage!")
            // printdev(params.damage_type + " | " + params.inflictor)
            local deltaVector = victim.GetCenter() - params.inflictor.GetOrigin();
            deltaVector.Norm();
            victim.Yeet(deltaVector * 5);
            // printdev(lastHitSentry)



            // Delfite: This code assumes there will only ever be one sentry active at a time, per player.
            // if (!usingMiniSentry)
            // {
            //     local sentry_metal = GetPropInt(lastHitSentry, "m_iUpgradeMetal")
            //     local sentry_metal_required = GetPropInt(lastHitSentry, "m_iUpgradeMetalRequired")
            //     local sentry_level = GetPropInt(lastHitSentry, "m_iUpgradeLevel")

            //     // if (sentry_metal == sentry_metal_required)
            //     // {
            //     //     if (sentry_level == 0 || sentry_level == 1)
            //     //         lastHitSentry.TakeDamageCustom(player, player, wrench, Vector(0, 0, 0), Vector(0, 0, 0), 1, 0, DMG_CLUB)
            //     // }
            //     if (sentry_metal >= 0 && sentry_level < 3)
            //         SetPropInt(lastHitSentry, "m_iUpgradeMetal", clampCeiling(sentry_metal_required, sentry_metal + 2))

            //     // printdev("Sentry Upgrade Metal: " + GetPropInt(lastHitSentry, "m_iUpgradeMetal"))
            // }

            foreach (building in PlayerBuildings[player])
            {
                local building_type = GetPropInt(building, "m_iObjectType")
                switch(building_type)
                {
                    case 0:
                        local dispenser_metal = GetPropInt(building, "m_iUpgradeMetal")
                        local dispenser_metal_required = GetPropInt(building, "m_iUpgradeMetalRequired")
                        local dispenser_level = GetPropInt(building, "m_iUpgradeLevel")
                        SetPropInt(building, "m_iUpgradeMetal", clampCeiling(dispenser_metal_required, dispenser_metal + 2))
                            break;
                    case 1:
                        local teleporter_metal = GetPropInt(building, "m_iUpgradeMetal")
                        local teleporter_metal_required = GetPropInt(building, "m_iUpgradeMetalRequired")
                        local teleporter_level = GetPropInt(building, "m_iUpgradeLevel")
                        SetPropInt(building, "m_iUpgradeMetal", clampCeiling(teleporter_metal_required, teleporter_metal + 2))
                            break;
                    case 2:
                        if (usingMiniSentry)
                            break;

                        local sentry_metal = GetPropInt(building, "m_iUpgradeMetal")
                        local sentry_metal_required = GetPropInt(building, "m_iUpgradeMetalRequired")
                        local sentry_level = GetPropInt(building, "m_iUpgradeLevel")
                        SetPropInt(building, "m_iUpgradeMetal", clampCeiling(sentry_metal_required, sentry_metal + 2))
                            break;
                    default:
                        printdev("Unknown ObjectType found: " + building_type + " | " + building)
                            break;
                }
            }

            /*
            == PlayerBuildings visualization ==

            Table: PlayerBuildings
            {
                Array: building | Builder: player <- For each building in PlayerBuildings[player], do X, Y, and Z.
                [
                    i: sentry
                    i: dispenser
                    i: teleporter
                    i: teleporter
                ]
            }
            */
        }
        else
            lastHitSentry = null;
    }

    function OnHurtDealtEvent(victim, params)
    {
        local active_weapon = player.GetActiveWeapon()
        if (primaryIsFrontierJustice)
        {
            if (lastHitSentry != null)
            {
                // printdev(GetPropInt(player, "m_Shared.m_iRevengeCrits"));
                //Frontier Justice crits.
                sentryDamageAccumulated += params.damageamount;
                while (sentryDamageAccumulated >= 120)
                {
                    // AddPropInt(lastHitSentry, "SentrygunLocalData.m_iAssists", 1);
                    AddPropInt(player, "m_Shared.m_iRevengeCrits", 1);
                    sentryDamageAccumulated -= 120;

                    if (GetPropInt(player, "m_Shared.m_iRevengeCrits") == 1)
                        EmitSoundOnClient("Powerup.PickUpTemp.Crit", player)
                }
            }

            // Delfite: If the player is already holding the Frontier Justice, the crits won't appear until they switch weapons.
            // This code fixes that by simply critboosting the player when those conditions are met, then letting the game
            // handle removing the critboost like normal.
            if (WeaponIs(active_weapon, "frontier_justice") && GetPropInt(player, "m_Shared.m_iRevengeCrits") >= 1)
            {
                if (player.IsCritBoosted())
                    return;

                player.AddCondEx(TF_COND_CRITBOOSTED, -1, null)
            }
        }
    }

    function OnFrameTickAliveOrDead()
    {
        if (!(player in PlayerBuildings))
            return;

        local projectile = null;
        while (projectile = FindByClassname(projectile, "tf_projectile_sentryrocket"))
        {
            // printdev("Projectile Owner: " + projectile.GetOwner())
            if (projectile.GetOwner() == sentrygun) // projectile is a class object, aka an "instance".
            {
                projectile.ValidateScriptScope()
                local projectileScope = projectile.GetScriptScope();
                if (!("CHECKED" in projectileScope))
                {
                    projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 2)
                    // printdev(projectile + " | " + projectile.GetAbsVelocity())
                    projectileScope["CHECKED"] <- null;
                }
            }
        }

        local entrance = null;
        local exit = null;
        local entrance_level = 0;
        local exit_level = 0;

        foreach (building in PlayerBuildings[player])
        {
            if (GetPropInt(building, "m_iObjectType") == 1)
            {
                // Delfite: To trigger the game's building upgrade routine, increase a building's level and set the metal to 0.
                if (GetPropInt(building, "m_iObjectMode") == 0)
                {
                    entrance = building
                    entrance_level = GetPropInt(entrance, "m_iUpgradeLevel")
                    // printdev("Found an Entrance.")
                }
                else if (GetPropInt(building, "m_iObjectMode") == 1)
                {
                    exit = building
                    exit_level = GetPropInt(exit, "m_iUpgradeLevel")
                    // printdev("Found an Exit.")
                }
            }
        }
        if (entrance && exit)
        {
            if (exit_level < entrance_level)
            {
                SetPropInt(exit, "m_iUpgradeMetal", 0)
                SetPropInt(exit, "m_iUpgradeLevel", entrance_level)
                // printdev("Trying upgrade on Exit.")
            }
            if (entrance_level < exit_level)
            {
                SetPropInt(entrance, "m_iUpgradeMetal", 0)
                SetPropInt(entrance, "m_iUpgradeLevel", exit_level)
                // printdev("Trying upgrade on Entrance.")
            }
        }
    }

    //This is how we keep Engineer Buildings during Sudden Death - we turn Sudden Death off until the end of the frame.
    function OnDeath(attacker, params)
    {
        SetPropInt(tf_gamerules, "m_iRoundState", 0);
        RunWithDelay("SetPropInt(tf_gamerules, `m_iRoundState`, 7)", null, 0);
    }
});