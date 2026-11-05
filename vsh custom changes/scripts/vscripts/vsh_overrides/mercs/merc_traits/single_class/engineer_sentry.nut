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
PrecacheSound(")weapons/sentry_damage1.wav")
PrecacheSound(")weapons/sentry_damage2.wav")
PrecacheSound(")weapons/sentry_damage3.wav")
PrecacheSound(")weapons/sentry_damage4.wav")
PrecacheSound(")weapons/sentry_scan.wav")
PrecacheSound(")weapons/sentry_scan2.wav")
PrecacheSound(")weapons/sentry_scan3.wav")
PrecacheSound(")weapons/medi_shield_deploy.wav")
PrecacheSound(")weapons/medi_shield_retract.wav")
PrecacheSound(")weapons/sentry_shaft_laser_pass.wav")

// ::sentry_damage_sound_array <- [
//     "weapons/sentry_damage1.wav",
//     "weapons/sentry_damage2.wav",
//     "weapons/sentry_damage3.wav",
//     "weapons/sentry_damage4.wav"
// ]

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


local next_hurt_time = 0;

// Delfite: This listener implements the unused sound effects for when a sentry takes damage, because why not.
// Presentation matters, people!
AddListener("object_hurt", 1, function(attacker, object, params)
{
    SentryHurtSFX(attacker, object, params)
});

function SentryHurtSFX(attacker, object, params)
{
    if (!IsValidBoss(attacker))
        return;

    // Delfite: Only play the SFX if the sentry is still alive.
    if (!object.IsAlive())
        return;

    // Delfite: Stop the damage SFX from getting spammed by Sweeping Charge.
    local hurt_time = Time()
    if (next_hurt_time > hurt_time)
        return;
    next_hurt_time = hurt_time + 0.15

    local building_type = GetPropInt(object, "m_iObjectType")
    if (building_type != 2)
        return;
    // printdev("Sentry took damage.")

    local sfx_pitch = 30;
    local isMiniSentry = GetPropBool(object, "m_bMiniBuilding")
    // Delfite: Change the pitch of the damage SFX if the sentry is a mini.
    if (!isMiniSentry)
        sfx_pitch = 100
    else
        sfx_pitch = 120

    // Delfite: Don't delete these copies of EmitSoundEx! The sounds themselves are really quiet by default, so we play it
    // multiple times in the same tick to make it louder. Probably the dumbest solution to a problem I've had to use so far,
    // but it works.
    switch (RandomInt(0, 3))
    {
        case 0:
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage1.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage1.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage1.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage1.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
        break;

        case 1:
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage2.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage2.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage2.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage2.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
        break;

        case 2:
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage3.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage3.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage3.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage3.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
        break;

        case 3:
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage4.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage4.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage4.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
            EmitSoundEx(
            {
                sound_name = ")weapons/sentry_damage4.wav"
                entity = object
                volume = 1.0
                sound_level = 80
                pitch = sfx_pitch
            })
        break;

        default:
        break;
    }
}

characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;
	weapon_secondary = null;
	weapon_melee = null;
	Pistol = null;
    sentrygun = null;
	damageAccumulatedForRevenge = 0;

    sentry_level_limit = 2
    dispenser_level_limit = 2
    teleporter_level_limit = 2

    teleporter_entrance = null;
    teleporter_exit = null;

    lastHitWasSecondary = null;
	lastHitSentry = null;
    sentryCritsActive = false;
	primaryIsFrontierJustice = false;
	usingMiniSentry = false;

    you = null;

    engineerIsKritzd = false;

    shieldSFXPlayed = false;

    next_scan_time = 0;
    next_shaft_laser_pass_time = 0;


	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

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

    function OnObjectBuilt(builder, building, params)
    {
        local building_type = GetPropInt(building, "m_iObjectType")
        if (building_type != 2)
            return;

        sentrygun = building;
    }

    function OnDamageDealt(victim, params)
    {
        lastHitWasSecondary = params.weapon == weapon_secondary;

        if (params.inflictor != null && params.inflictor.GetClassname() == "obj_sentrygun" && player == victim)
            params.damage *= 0.1

        if (params.inflictor != null && params.inflictor.GetClassname() == "obj_sentrygun" && player != victim)
        {
            // Delfite: As it would turn out, sentries (without a damage nerf), do a LOT of damage, and even more while the Engie is under Mini-crits.
            // They also do a lot of knockback. So much knockback that even with a 50% damage penalty, a single Level 2 Sentry can easily stuff a
            // Brave Jump from Hale, making map traversal much more annoying for him and creating a not-so-fun-to-fight-against situation for him.
            // This, combined with multiple sentries often being in play, necessitated a solution. Sentries now inflict SUBSTANTIALLY less
            // knockback on Hale, but sentries will be easier to build in order to compensate. Hopefully this rework makes Engineer more
            // fun to play as and against.

            params.damage *= usingMiniSentry ? 0.8 : 0.5;
            lastHitSentry = params.inflictor;
            local deltaVector = victim.GetCenter() - lastHitSentry.GetOrigin();
            deltaVector.Norm();
            victim.Yeet(deltaVector * 8);
            // printdev("OnePlayerRemaining: " + OnePlayerRemaining)
            if (OnePlayerRemaining || player.InCond(TF_COND_CRITBOOSTED_BONUS_TIME))
            {
                params.damage_type = DMG_PREVENT_PHYSICS_FORCE | DMG_ACID;
                // Delfite: You may think that giving sentries the ability to ignore Hale's crit resistance would be OP, but
                // there's a lot of factors working against sentries. They're relatively easy to destroy, only deal 192 DPS
                // - by comparison, Heavy's Minigun (even with a 30% damage penalty) - still deals ~300 DPS at mid-range with crits,
                // and sentries still have limited range and a slow turning speed. Overall, still very easy to counter as Hale.
                params.damage *= 1.2;
            }
            else if (!OnePlayerRemaining)
            {
                params.damage_type = DMG_PREVENT_PHYSICS_FORCE;
                if (engineerIsKritzd)
                {
                    params.damage_type = DMG_PREVENT_PHYSICS_FORCE | DMG_ACID;
                    params.damage *= 1.2;
                }
            }



            // printdev("Sentrygun dealt damage!")
            // printdev(params.damage_type + " | " + params.inflictor)

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
                        local Building = GetPropBool(building, "m_bBuilding")
                        local Carrying = GetPropBool(building, "m_bCarried")
                        local Deploying = GetPropBool(building, "m_bCarryDeploy")
                        if (!(params.damage_type & DMG_ACID))
                            SetPropInt(building, "m_iUpgradeMetal", clampCeiling(dispenser_metal_required, dispenser_metal + 2))
                        else
                        {
                            if (dispenser_metal == dispenser_metal_required && dispenser_level < 3 && !Building && !Carrying && !Deploying)
                            {
                                SetPropInt(building, "m_iHighestUpgradeLevel", clampCeiling(3, dispenser_level + 1))
                                SetPropInt(building, "m_iUpgradeMetal", 0)
                            }
                            else
                                SetPropInt(building, "m_iUpgradeMetal", clampCeiling(dispenser_metal_required, dispenser_metal + 6))
                        }
                    break;
                    case 1:
                        local teleporter_metal = GetPropInt(building, "m_iUpgradeMetal")
                        local teleporter_metal_required = GetPropInt(building, "m_iUpgradeMetalRequired")
                        local teleporter_level = GetPropInt(building, "m_iUpgradeLevel")
                        local Building = GetPropBool(building, "m_bBuilding")
                        local Carrying = GetPropBool(building, "m_bCarried")
                        local Deploying = GetPropBool(building, "m_bCarryDeploy")
                        if (!(params.damage_type & DMG_ACID))
                            SetPropInt(building, "m_iUpgradeMetal", clampCeiling(teleporter_metal_required, teleporter_metal + 2))
                        else
                        {
                            if (teleporter_metal == teleporter_metal_required && teleporter_level < 3 && !Building && !Carrying && !Deploying)
                            {
                                SetPropInt(building, "m_iHighestUpgradeLevel", clampCeiling(3, teleporter_level + 1))
                                SetPropInt(building, "m_iUpgradeMetal", 0)
                            }
                            else
                                SetPropInt(building, "m_iUpgradeMetal", clampCeiling(teleporter_metal_required, teleporter_metal + 6))
                        }
                    break;
                    case 2:
                        if (usingMiniSentry)
                            break;

                        local sentry_metal = GetPropInt(building, "m_iUpgradeMetal")
                        local sentry_metal_required = GetPropInt(building, "m_iUpgradeMetalRequired")
                        local sentry_level = GetPropInt(building, "m_iUpgradeLevel")
                        local Building = GetPropBool(building, "m_bBuilding")
                        local Carrying = GetPropBool(building, "m_bCarried")
                        local Deploying = GetPropBool(building, "m_bCarryDeploy")
                        if (!(params.damage_type & DMG_ACID))
                            SetPropInt(building, "m_iUpgradeMetal", clampCeiling(sentry_metal_required, sentry_metal + 2))
                        else
                        {
                            if (sentry_metal == sentry_metal_required && sentry_level < 3 && !Building && !Carrying && !Deploying)
                            {
                                SetPropInt(building, "m_iHighestUpgradeLevel", clampCeiling(3, sentry_level + 1))
                                SetPropInt(building, "m_iUpgradeMetal", 0)
                            }
                            else
                                SetPropInt(building, "m_iUpgradeMetal", clampCeiling(sentry_metal_required, sentry_metal + 6))
                        }
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
            if (lastHitSentry != null || lastHitWasSecondary)
            {
                // printdev(GetPropInt(player, "m_Shared.m_iRevengeCrits"));
                //Frontier Justice crits.
                damageAccumulatedForRevenge += params.damageamount;
                while (damageAccumulatedForRevenge >= 150)
                {
                    // AddPropInt(lastHitSentry, "SentrygunLocalData.m_iAssists", 1);
                    // Delfite: Attempting to add crits beyond 35 just results in the counter setting itself to 35 - 1 every time.
                    if (GetPropInt(player, "m_Shared.m_iRevengeCrits") < 35)
                        AddPropInt(player, "m_Shared.m_iRevengeCrits", 1);
                    damageAccumulatedForRevenge -= 150;

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

    function OnTickAlive(timeDelta)
    {
        EngineerKritzThink()

        SentryShieldSFX()
        SentryControlSFX()
        // SentryTargetSFX()
    }

    function EngineerKritzThink()
    {
        if (GetPropInt(player, "m_Shared.m_nNumHealers") > 0)
        {
            // Delfite: Only run this `foreach` if the Engineer has at least 1 Medic healing them.
            foreach (player in GetAliveMercs())
            {
                if (player.GetPlayerClass() == TF_CLASS_MEDIC && player.GetHealTarget() == you)
                {
                    local your_healer = player
                    local healer_weapon_secondary = your_healer.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY)
                    if (!WeaponIs(healer_weapon_secondary, "kritzkrieg"))
                        continue;

                    local chargeReleased = GetPropBool(healer_weapon_secondary, "m_bChargeRelease")
                    if (chargeReleased)
                        engineerIsKritzd = true;
                    else
                        engineerIsKritzd = false;
                }
            }
        }
        else
        {
            if (!engineerIsKritzd)
                return;

            engineerIsKritzd = false;
        }
    }

    function SentryShieldSFX()
    {
        if (GetPropBool(sentrygun, "m_bPlayerControlled"))
        {
            if (shieldSFXPlayed)
                return;

            shieldSFXPlayed = true;
            EmitSoundEx(
            {
                sound_name = ")weapons/medi_shield_deploy.wav"
                entity = sentrygun
                filter_type = RECIPIENT_FILTER_GLOBAL
                volume = 1.0
                sound_level = 140
            })
        }
        else
        {
            if (!shieldSFXPlayed)
                return;

            shieldSFXPlayed = false;
            // EmitSoundEx(
            // {
            //     sound_name = ")weapons/medi_shield_retract.wav"
            //     sound_level = 86
            //     volume = 1.0
            //     filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
            //     entity = sentrygun
            // })
        }
    }

    function SentryControlSFX()
    {
        local sfx_pitch = 30;
        local isMiniSentry = GetPropBool(sentrygun, "m_bMiniBuilding")
        local sentry_target = GetPropEntity(sentrygun, "m_hAutoAimTarget")
        local boss = GetBossPlayers()[0]
        // Delfite: Change the pitch of the damage SFX if the sentry is a mini.
        if (!isMiniSentry)
            sfx_pitch = 107
        else
            sfx_pitch = 127

        if (GetPropBool(sentrygun, "m_bPlayerControlled"))
        {
            // printdev("Sentry Target: " + sentry_target)
            local scan_time = Time()
            if (!(next_scan_time > scan_time))
            {
                next_scan_time = isMiniSentry ? scan_time + 1.5 : scan_time + 2.0
                if (sentry_target == boss)
                    EmitSoundOnClient("Building_Sentrygun.ShaftLaserPass", boss)
                else
                    StopSoundOn("Building_Sentrygun.ShaftLaserPass", boss)

                local sentrygun_level = GetPropInt(sentrygun, "m_iUpgradeLevel")
                // printdev("Sentry level: " + sentrygun_level)
                switch (sentrygun_level)
                {
                    case 1:
                        StopSoundOn(")weapons/sentry_scan.wav", sentrygun)
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 1.0
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 1.0
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                    break;

                    case 2:
                        StopSoundOn(")weapons/sentry_scan2.wav", sentrygun)
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan2.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 1.0
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan2.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 1.0
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan2.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 0.3
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                    break;

                    case 3:
                        StopSoundOn(")weapons/sentry_scan3.wav", sentrygun)
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan3.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 1.0
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan3.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 1.0
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                        EmitSoundEx(
                        {
                            sound_name = ")weapons/sentry_scan3.wav"
                            entity = sentrygun
                            filter_type = RECIPIENT_FILTER_GLOBAL
                            volume = 0.6
                            sound_level = 84
                            pitch = sfx_pitch
                        })
                    break;

                    default:
                    break;
                }
            }

        }
        else
        {
            if (!(next_scan_time == 0))
            {
                StopSoundOn("Building_Sentrygun.ShaftLaserPass", boss)
                next_scan_time = 0;
            }
        }
    }

    function SentryTargetSFX()
    {
        local isMiniSentry = GetPropBool(sentrygun, "m_bMiniBuilding")
        local sentry_target = GetPropEntity(sentrygun, "m_hAutoAimTarget")
        local boss = GetBossPlayers()[0]
        if (GetPropBool(sentrygun, "m_bPlayerControlled"))
        {
            // printdev("Sentry Target: " + sentry_target)
            if (sentry_target == boss)
            {
                local shaft_laser_pass_time = Time()
                if (!(next_shaft_laser_pass_time > shaft_laser_pass_time))
                {
                    next_shaft_laser_pass_time = isMiniSentry ? shaft_laser_pass_time + 1.5 : shaft_laser_pass_time + 2.0
                    EmitSoundOn("Building_Sentrygun.ShaftLaserPass", boss)
                }

                // Delfite: Not sure why, but using the filename of this sound causes it to not obey StopSound and StopSoundOn.
                // Use the keyvalue instead.
                // EmitSoundOn(")weapons/sentry_shaft_laser_pass.wav", boss)
                // EmitSoundEx(
                // {
                //     sound_name = ")weapons/sentry_shaft_laser_pass.wav"
                //     entity = boss
                //     // filter_type = RECIPIENT_FILTER_GLOBAL
                //     volume = 1.0
                // })
            }
            else
            {
                if (!(next_shaft_laser_pass_time == 0))
                {
                    // StopSoundOn(")weapons/sentry_shaft_laser_pass.wav", boss)
                    StopSoundOn("Building_Sentrygun.ShaftLaserPass", boss)
                    next_shaft_laser_pass_time = 0;
                }
            }
        }
        else
        {
            if (!(next_shaft_laser_pass_time == 0))
            {
                // StopSoundOn(")weapons/sentry_shaft_laser_pass.wav", boss)
                StopSoundOn("Building_Sentrygun.ShaftLaserPass", boss)
                next_shaft_laser_pass_time = 0;
            }
        }
    }

    function OnTickAliveOrDead(timeDelta)
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
                local projectile_scope = projectile.GetScriptScope();
                // printdev(projectile_scope)
                if (!("CHECKED" in projectile_scope))
                {
                    projectile_scope["CHECKED"] <- null;

                    projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 2)
                    // printdev(projectile + " | " + projectile.GetAbsVelocity())

                    if (engineerIsKritzd || OnePlayerRemaining || player.InCond(TF_COND_CRITBOOSTED_BONUS_TIME))
                        SetPropBool(projectile, "m_bCritical", true)
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

    function OnDiscard()
    {
        local boss = GetBossPlayers()[0]
        StopSoundOn("Building_Sentrygun.ShaftLaserPass", boss)
    }
});