// Script by: Senni, Delfite, LizardOfOz.
// With assistance from: Bradasparky, Dice.
// This script handles everything to do with Demoman's weapons.
// Requires modification of `weapons.nut` to function.


const DEMO_EYELANDER_OVERHEAL_MULT = 0.35

PrecacheArbitrarySound("vsh_sfx.shield_break")
PrecacheArbitrarySound("demo.shield")
PrecacheArbitrarySound("demo.shield_lowhp")
PrecacheArbitrarySound("demo.special_01")

PrecacheSound("items/powerup_pickup_team_revenge.wav")

PrecacheSound("vo/demoman_laughevil01.mp3")
PrecacheSound("vo/demoman_laughevil02.mp3")
PrecacheSound("vo/demoman_laughevil03.mp3")

PrecacheSound("vo/taunts/demoman_taunts01.mp3")
PrecacheSound("vo/taunts/demoman_taunts02.mp3")
PrecacheSound("vo/taunts/demoman_taunts03.mp3")
PrecacheSound("vo/taunts/demoman_taunts04.mp3")
PrecacheSound("vo/taunts/demoman_taunts05.mp3")
PrecacheSound("vo/taunts/demoman_taunts06.mp3")
PrecacheSound("vo/taunts/demoman_taunts07.mp3")
PrecacheSound("vo/taunts/demoman_taunts08.mp3")
PrecacheSound("vo/taunts/demoman_taunts09.mp3")
PrecacheSound("vo/taunts/demoman_taunts10.mp3")
PrecacheSound("vo/taunts/demoman_taunts11.mp3")
PrecacheSound("vo/taunts/demoman_taunts12.mp3")
PrecacheSound("vo/taunts/demoman_taunts13.mp3")
PrecacheSound("vo/taunts/demoman_taunts14.mp3")
PrecacheSound("vo/taunts/demoman_taunts15.mp3")
PrecacheSound("vo/taunts/demoman_taunts16.mp3")
PrecacheSound("vo/taunts/demoman_taunts17.mp3")

PrecacheSound("vo/sword_idle01.mp3")
PrecacheSound("vo/sword_idle02.mp3")
PrecacheSound("vo/sword_idle03.mp3")
PrecacheSound("vo/sword_idle04.mp3")
PrecacheSound("vo/sword_idle05.mp3")
PrecacheSound("vo/sword_idle06.mp3")
PrecacheSound("vo/sword_idle07.mp3")
PrecacheSound("vo/sword_idle08.mp3")
PrecacheSound("vo/sword_idle09.mp3")
PrecacheSound("vo/sword_idle10.mp3")
PrecacheSound("vo/sword_idle11.mp3")
PrecacheSound("vo/sword_idle12.mp3")
PrecacheSound("vo/sword_idle13.mp3")
PrecacheSound("vo/sword_idle14.mp3")
PrecacheSound("vo/sword_idle15.mp3")

::demoman_vo_laughevil_array <- [
    "vo/demoman_laughevil01.mp3",
    "vo/demoman_laughevil02.mp3",
    "vo/demoman_laughevil03.mp3"
    // Delfite: Excluding 04 and 05 since they don't fit the feel of what I'm going for.
]

::demoman_vo_taunts_array <- [
    // "vo/taunts/demoman_taunts01.mp3",
    // "vo/taunts/demoman_taunts02.mp3",
    "vo/taunts/demoman_taunts03.mp3",
    "vo/taunts/demoman_taunts04.mp3",
    "vo/taunts/demoman_taunts05.mp3",
    // "vo/taunts/demoman_taunts06.mp3",
    "vo/taunts/demoman_taunts07.mp3",
    "vo/taunts/demoman_taunts08.mp3",
    "vo/taunts/demoman_taunts09.mp3",
    "vo/taunts/demoman_taunts10.mp3",
    "vo/taunts/demoman_taunts11.mp3",
    // "vo/taunts/demoman_taunts12.mp3",
    "vo/taunts/demoman_taunts13.mp3",
    "vo/taunts/demoman_taunts14.mp3",
    // "vo/taunts/demoman_taunts15.mp3",
    "vo/taunts/demoman_taunts16.mp3",
    // "vo/taunts/demoman_taunts17.mp3"
]

::eyelander_vo_idle_array <- [
    "vo/sword_idle01.mp3",
    "vo/sword_idle02.mp3",
    "vo/sword_idle03.mp3",
    "vo/sword_idle04.mp3",
    "vo/sword_idle05.mp3",
    "vo/sword_idle06.mp3",
    "vo/sword_idle07.mp3",
    "vo/sword_idle08.mp3",
    "vo/sword_idle09.mp3",
    "vo/sword_idle10.mp3",
    "vo/sword_idle11.mp3",
    "vo/sword_idle12.mp3",
    "vo/sword_idle13.mp3",
    "vo/sword_idle14.mp3",
    "vo/sword_idle15.mp3"
]

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;
	weapon_secondary = null;
	weapon_melee = null;
	wearable = null;
    player_scope = null;

    // overheal_quotient = 0;
    // overheal_limit = 0;

    // Primary handles.
    AnyGrenadeLauncher = null;

    // Secondary handles.
    AnyStickybombLauncher = null;

    // Melee handles.
    Bottle = null;
    Katana = null;
    Eyelander = null;
    ClaidMor = null;
    Caber = null;

    // Wearable handles.
    Boots = null;
    Shield = null;
    Targe = null;
    Tideturner = null;
    SplendidScreen = null;

    // Caber variables.
    caberTimer = 0;
    timer = 0;
    caberChecked = false;
    // caberRechargeActive = false;
    // caber_recharge_timestamp = 0;

    // Bottle variables.
    // bottleTauntPlaying = false;

    // Eyelander variables.
    lastHitWasEyelander = false;
    lastTimeSoundPlayed = 0;
    heads = 0;
    nearHale = false;
    eyelanderDialogueRan = false;
    eyelanderCritSequencePlayed = false;

    // Wearable variables.
    destroyShield = false;
    shieldBroken = false;
    bootsAttributesApplied = false;
    shieldAttributesApplied = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        // BeginScriptDebug()
        // ScriptDebugAddTrace()
        // ScriptDebugAddWatch()
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        player_scope = player.GetScriptScope()

        // Primary definitions.
        if (weapon_primary != null)
        {
            //printdev("Generic Demoman primary stats applied.")
            if (WeaponIs(weapon_primary, "any_grenade_launcher"))
                AnyGrenadeLauncher = weapon_primary
            if (WeaponIs(weapon_primary, "grenade_launcher"))
            {
                weapon_primary.AddAttribute("clip size bonus", 1.5, -1)
                weapon_primary.AddAttribute("maxammo primary increased", 1.5, -1)
                weapon_primary.AddAttribute("Reload time decreased", 0.75, -1)
                weapon_primary.AddAttribute("fire rate bonus", 0.85, -1)
                weapon_primary.AddAttribute("grenade no bounce", 1, -1)
                //printdev("Grenade Launcher stats applied.")
            }
            // Purpose: Strengthen the Iron Bomber's identity as a pseudo-jumper weapon, at the cost of some of its damage output.
            //
            if (WeaponIs(weapon_primary, "iron_bomber"))
            {
                weapon_primary.AddAttribute("Blast radius increased", 1.35, -1)
                weapon_primary.AddAttribute("Projectile speed increased", 1.15, -1)
                weapon_primary.AddAttribute("fuse bonus", 0.2, -1)
                // Fuse time: From -30% -> -80%. Still lets you hit Hale at medium range while decreasing the interval between jumps to a reasonable level.
                weapon_primary.AddAttribute("rocket jump damage reduction", 0.25, -1)
                weapon_primary.AddAttribute("self dmg push force increased", 1.20, -1)
                weapon_primary.AddAttribute("maxammo primary increased", 1.5, -1)
                // weapon_primary.AddAttribute("self dmg push force increased", weapon_primary.GetAttribute("self dmg push force increased", 1.0) + 0.20, -1)
                weapon_primary.AddAttribute("damage penalty", 0.80, -1)
                //printdev("Iron Bomber stats applied.")
            }
            // Purpose: Strengthen the Loch'n'load's identity as a hard-hitting, high-speed grenade launcher.
            // The main drawback of this item, that being the 3 grenades it has, now has a bigger gap due to the stock GL getting 6.
            if (WeaponIs(weapon_primary, "loch_n_load"))
            {
                // Delfite: I would've removed the attributes already on the weapon, but since they're static, we can't do that. Argh!
                // Hale isn't a building. As funny as that sounds out loud, we still need to give the Loch-n-Load a proper damage bonus.
                weapon_primary.AddAttribute("damage bonus", 1.2, -1)
                weapon_primary.AddAttribute("fire rate bonus", 0.8, -1)
                weapon_primary.AddAttribute("reload time decreased", 0.8, -1)
                weapon_primary.AddAttribute("clip size penalty", 1.0, -1)
                //printdev("Loch-n-Load stats applied.")
            }
            // if (WeaponIs(weapon_primary, "loose_cannon"))
            // {
            // 	weapon_primary.AddAttribute("", 0, -1)
            // 	weapon_primary.AddAttribute("damage penalty", weapon_primary.GetAttribute("damage bonus", 1.0) - 0.15, -1)
            // }
            // Delfite: Projectiles are remarkably slow by default, and Hale is pretty dang fast. A little projectile speed should help bridge the gap.
            weapon_primary.AddAttribute("Projectile speed increased", weapon_primary.GetAttribute("Projectile speed increased", 1.0) + 0.35, -1)
        }

        // Secondary definitions.
        if (weapon_secondary != null)
        {
            weapon_secondary.AddAttribute("Projectile speed increased", 1.20, -1)
            if (WeaponIs(weapon_secondary, "any_stickybomb_launcher"))
                AnyStickybombLauncher = weapon_secondary;
            if (WeaponIs(weapon_secondary, "stickybomb_launcher"))
            {
                // Delfite: I originally gave the stock launcher a damage bonus to make its damage similar to the SR, but it turns out even a 10% bonus
                // significantly increases the amount of damage those 8 stickies can deal, especially if critboosted. Due to this, I realized that the
                // damage bonus wasn't really necessary and didn't cover any weakness the stock launcher had. All it really needed was some agility.
                // weapon_secondary.AddAttribute("damage bonus", 1.10, -1)
                weapon_secondary.AddAttribute("Blast radius increased", 1.2, -1)
                weapon_secondary.AddAttribute("fire rate bonus", 0.75, -1)
                // printdev("Stickybomb Launcher stats applied.")
            }
            // Delfite: The Scottish Resistance benefits from being able to set up multiple traps. Paired with Engineer buildings, it can be an
            // incredibly powerful weapon, but on its own it's not very strong due to how long it takes to set up each trap, as well as requiring
            // both the user to be smart enough to take advantage of the weapon's unique attribute and Hale to lack the awareness needed to spot
            // the player's traps. With these downsides in mind, I decided to make the weapon a little more agile by making it reload faster,
            // but nerfing its damage slightly to compensate, since stacking 14 stickies in one trap still does an enormous amount of damage and
            // knockback to Hale.
            if (WeaponIs(weapon_secondary, "scottish_resistance"))
            {
                weapon_secondary.AddAttribute("damage penalty", 0.9, -1)
                weapon_secondary.AddAttribute("Reload time decreased", 0.85, -1)
            }
            // Delfite: The quickiebomb launcher, due to its short arm time, is generally better as an offensive implement than a trapping tool.
            // As a result, I decided to buff its blast radius to make hitting Hale with the explosions easier.
            if (WeaponIs(weapon_secondary, "quickiebomb_launcher"))
            {
                weapon_secondary.AddAttribute("Blast radius increased", 1.5, -1)
                weapon_secondary.AddAttribute("clip size penalty", 0.75, -1)
                weapon_secondary.AddAttribute("max pipebombs decreased", -2, -1)
            }
            if (WeaponIs(weapon_secondary, "sticky_jumper"))
            {
                weapon_secondary.AddAttribute("maxammo secondary increased", 0.5, -1);
                weapon_secondary.AddAttribute("max pipebombs decreased", -7, -1);
                // SetPropInt(player, "m_iAmmo.002", 12)
            }
            if (WeaponIs(weapon_secondary, "base_jumper_demoman"))
            {
                weapon_secondary.AddAttribute("max health additive bonus", 25, -1)
                weapon_secondary.AddAttribute("rocket jump damage reduction", 0.40, -1)
            }
        }

        // Melee definitions.
        if (WeaponIs(weapon_melee, "bottle"))
        {
            Bottle = weapon_melee;
            Bottle.AddAttribute("mult_player_movespeed_active", 1.20, -1);
        }
        if (WeaponIs(weapon_melee, "half_zatoichi"))
        {
            Katana = weapon_melee;
            // printdev("Half-Zatoichi stats applied.")
        }
        if (WeaponIs(weapon_melee, "eyelander"))
        {
            Eyelander = weapon_melee;
            Eyelander.AddAttribute("max health additive penalty", 0, -1)
            // Eyelander.AddAttribute("damage penalty", 0.35, -1)
            Eyelander.AddAttribute("patient overheal penalty", DEMO_EYELANDER_OVERHEAL_MULT, -1)
            // printdev("Eyelander stats applied.")
        }
        if (WeaponIs(weapon_melee, "claidheamh_mor"))
        {
            ClaidMor = weapon_melee;
            ClaidMor.AddAttribute("dmg taken increased" 1.0, -1);
            // printdev("Claidheamh Mor stats applied.")
        }
        if (WeaponIs(weapon_melee, "scotsman_skullcutter"))
        {
            weapon_melee.AddAttribute("move speed penalty" 1.0, -1);
            weapon_melee.AddAttribute("damage bonus" 1.4, -1);
            // printdev("Skullcutter stats applied.")
        }
        if (WeaponIs(weapon_melee, "ullapool_caber"))
        {
            Caber = weapon_melee;
            Caber.AddAttribute("rocket jump damage reduction", 0.75, -1)
            // Delfite: Can't assign item meters to weapons that don't use them by default. Sadness.
            // Caber.AddAttribute("item_meter_charge_type", 3, -1)
            // Caber.AddAttribute("mult_item_meter_charge_rate", 3, -1)
            // Caber.AddAttribute("item_meter_damage_for_full_charge", 300, -1)
            // printdev("Caber stats applied.")
        }

        // Wearable definitions.
        RunWithDelay2(this, 0.0, function() // Delfite: Apply our attributes at the end of the frame so our move speed bonus actually works.
        {
            while (wearable = FindByClassname(wearable, "tf_wear*"))
            {
                // printdev("Searching through Demoman's wearables...")
                if (wearable.GetOwner() == player)
				{
                    if (WeaponIs(wearable, "any_demo_boots"))
                    {
                        // printdev("Boots found.")
                        // Remove the speed boost currently on the boots.
                        Boots = wearable;
                        Boots.AddAttribute("max health additive bonus", 25, -1)
                        Boots.AddAttribute("move speed bonus shield required", 1.0, -1)
                        Boots.AddAttribute("cancel falling damage", 1, -1)
                        Boots.AddAttribute("rocket jump damage reduction", 0.1, -1)

                        // Delfite: Apparently, the game finishes any math you give it before OnDiscard runs.
                        // This resulted in the old rocket jump damage reduction code subtracting from the attribute every time you changed loadouts.
                        // printdev("Rocket jump damage reduction: " + wearable.GetAttribute("rocket jump damage reduction", 1.0))
                        // if (WeaponIs(weapon_secondary, "any_stickybomb_launcher") && !WeaponIs(weapon_secondary, "sticky_jumper"))
                        // {
                        //     // printdev("Secondary is a stickybomb launcher.")
                        // }
                        // if (weapon_melee == Eyelander && WeaponIs(weapon_secondary, "any_stickybomb_launcher"))
                        // {
                        //     Boots.AddAttribute("move speed bonus", 1.10, -1)
                        //     // Delfite: Only give this speed bonus if you don't have an eyelander and stickybomb launcher equipped.
                        //     // Delfite: Failing to do this will result in demomen that are not only faster than a scout, but also highly resistant to their own bombs.
                        // }
                        // else
                            Boots.AddAttribute("move speed bonus", 1.1, -1)
                        bootsAttributesApplied = true;
                        // printdev("Boot Attributes: " + bootsAttributesApplied)
                    }

                    // Delfite: Don't put an `else` here. You can have a shield and boots equipped at the same time, after all.
                    if (WeaponIs(wearable, "any_shield"))
                    {
                        Shield = wearable;
                        Shield.EnableDraw();
                        if (WeaponIs(wearable, "tideturner"))
                        {
                            Tideturner = wearable;
                            Tideturner.AddAttribute("dmg taken from blast reduced", 0.8, -1)
                            Tideturner.AddAttribute("dmg taken from fire reduced", 0.8, -1)
                        }
                        if (WeaponIs(wearable, "chargin_targe"))
                        {
                            Targe = wearable;
                            wearable.AddAttribute("rocket jump damage reduction", 0.4, -1)
                            wearable.AddAttribute("dmg taken from blast reduced", 0.4, -1)
                            wearable.AddAttribute("mult charge turn control", 2.0, -1)
                        }
                        if (WeaponIs(wearable, "splendid_screen"))
                        {
                            SplendidScreen = wearable;
                            SplendidScreen.AddAttribute("dmg taken from blast reduced", 0.7, -1)
                            SplendidScreen.AddAttribute("dmg taken from fire reduced", 0.7, -1)
                            SplendidScreen.AddAttribute("mult charge turn control", 3.5, -1)
                            SplendidScreen.AddAttribute("charge meter on hit", 0.2, -1)
                        }
                        shieldAttributesApplied = true;
                        // printdev("Shield Attributes: " + shieldAttributesApplied)
                    }
                }
                else
                    continue;
                // Delfite: Stop iterating through wearables if we've applied our stats to both.
                if (bootsAttributesApplied && shieldAttributesApplied)
                    break;
            }
        })
    }

    // Delfite: (Arguably) Less efficient version of Senni's OnTickAlive method for the Caber's recharge.
    // I couldn't notice a difference between the two in-game, so Senni's method stays.
    // function OnFrameTickAlive()
    // {
    //     if (weapon_melee == Caber)
    //     {
    //         local caberDetonated = GetPropInt(Caber, "m_iDetonated")
    //         if (caberDetonated == 0)
    //             return;

    //         // Delfite: Caber recharged!
    //         if (caber_recharge_timestamp == Time())
    //         {
    //             SetPropInt(Caber, "m_iDetonated", 0);
    //             EmitSoundOnClient("TFPlayer.ReCharged", player);
    //             EmitPlayerVO(player, "sticky_trap"); // Playing the sticky trap voiceline so the player is more aware of the recharge.
    //             caberRechargeActive = false;
    //             return;
    //         }
    //         else if (caberRechargeActive)
    //             return;

    //         caber_recharge_timestamp = Time() + 12
    //         caberRechargeActive = true;
    //     }
    // }

    function OnTickAlive(timeDelta)
    {
        local active_weapon = player.GetActiveWeapon()
        if (weapon_melee == Caber)
            CaberRecharge(timeDelta)

        // if (active_weapon == Bottle)
        //     BottleTaunt()

        // if (weapon_melee == Eyelander)
        // {
        //     // local boss = GetBossPlayers()[0]
        //     // local your_center = player.GetCenter()
        //     // local distance_to_boss = (boss.GetCenter() - your_center).Length()
        //     // nearHale = distance_to_boss < 200
        // }
    }

    // Delfite: Instead of applying the "charge on hit" attribute to demo's current melee, we'll just add charge via NetProps.
    function OnDamageDealt(victim, params)
    {
        lastHitWasEyelander = params.weapon == Eyelander && params.weapon != null

        // Delfite: 128 correlates to DMG_CLUB. While it's technically faster to use integers instead of their respective enums,
        // we're talking about a difference in what is likely in the order of microseconds, if not smaller.
        // In other words: It shouldn't matter which one you use.
        if (params.damage_type & 128)
        {
            if (params.weapon == ClaidMor)
            {
                SetPropFloat(player, "m_Shared.m_flChargeMeter", clampCeiling(100.0, GetPropFloat(player, "m_Shared.m_flChargeMeter") + 25.0))
                // printdev("Charge added by Claidheamh Mor.")
            }

            if (Shield == Tideturner && params.weapon == weapon_melee)
            {
                SetPropFloat(player, "m_Shared.m_flChargeMeter", clampCeiling(100.0, GetPropFloat(player, "m_Shared.m_flChargeMeter") + 75.0))
                // printdev("Charge added by Tideturner.")
            }

            if (Boots != null && params.weapon == weapon_melee)
            {
                SetPropFloat(player, "m_Shared.m_flChargeMeter", clampCeiling(100.0, GetPropFloat(player, "m_Shared.m_flChargeMeter") + 25.0))
                // printdev("Charge added by boots.")
            }
        }

        // Delfite: Half-Zatoichi heal-on-hit code.
        if (params.weapon == Katana)
        {
            // local newHealth = player.GetHealth() + player.GetMaxHealth() / 2.0;
            // local maxOverheal = player.GetMaxHealth() * 1.5
            // player.SetHealth(clampCeiling(newHealth, maxOverheal));
            player.SetHealth(clampCeiling(player.GetMaxOverheal(), player.GetHealth() + (player.GetMaxHealth() / 2)))
			SetPropInt(params.weapon, "m_bIsBloody", 1);
			AddPropInt(player, "m_Shared.m_iKillCountSinceLastDeploy", 1);
        }

        if (lastHitWasEyelander)
        {
            heads = GetPropInt(player, "m_Shared.m_iDecapitations");
            // Delfite: Give the player some more health whenever they land a hit.
            player.SetHealth(clampCeiling(player.GetMaxOverheal(DEMO_EYELANDER_OVERHEAL_MULT), player.GetHealth() + 40))
            SetPropInt(player, "m_Shared.m_iDecapitations", heads + 1);
            // RunWithDelay2(this, 0.1, function ()
            // {
            //     if (eyelanderDialogueRan || heads < 19 || !player.IsAlive())
            //         return;

            //     RunEyelanderDialogueSequence()

            //     // local boss = GetBossPlayers()[0]
            //     // local boss_health_as_percent = boss.GetHealth().tofloat() / boss.GetMaxHealth().tofloat()
            //     // printdev(boss_health_as_percent)
            // })
        }
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (lastHitWasEyelander)
        {
            player.AddCond(TF_COND_DEMO_BUFF);
            // Delfite: Used to update the stats gained from the first 4 heads.
            player.AddCustomAttribute("mult_spread_scale_first_shot", 1, 0.01)
            // if (player.GetHealth() <= 300)
            //     player.SetHealth(player.GetHealth() + 15);

            if (heads > 1 && Time() > lastTimeSoundPlayed + 20 && RandomInt(0, 4) == 0)
            {
                lastTimeSoundPlayed = Time();
                EmitPlayerVODelayed(player, "special_01", 0.2);
            }

            // if (heads == 19)
            // {
            //     // if (!eyelanderCritSequencePlayed)
            //     //     RunEyelanderCritSequence()
            // }

            // local eyelander_max_health = player.GetCustomAttribute("max health additive bonus", 0)
            // local eyelander_move_speed = player.GetCustomAttribute("move speed bonus", 1.0)
            // local eyelander_damage = Eyelander.GetAttribute("damage bonus", 1.0)

            // player.GetMaxOverheal(DEMO_EYELANDER_OVERHEAL_MULT)
            // if (heads < 5)
            // {
            //     player.AddCustomAttribute("max health additive bonus", eyelander_max_health - 10, -1)
            //     player.AddCustomAttribute("move speed bonus", eyelander_move_speed + 0.025, -1)
            // }
            // else if (heads >= 5 && heads < 10)
            // {
            //     player.AddCustomAttribute("max health additive bonus", eyelander_max_health + 5, -1)
            //     Eyelander.AddAttribute("damage bonus", eyelander_damage + 0.15, -1)
            // }
            // printdev("Health Bonus: " + eyelander_max_health + " | Movement Mult: " + eyelander_move_speed + " | Damage Mult: " + eyelander_damage)

            // local eyelander_damage_penalty = Eyelander.GetAttribute("damage penalty", 1.0)
            // local eyelander_damage_bonus = Eyelander.GetAttribute("damage bonus", 1.0)
            // local eyelander_movespeed_bonus = player.GetCustomAttribute("move speed bonus", 1.0)

            // // Delfite: This block controls the Eyelander's bonus curves.
            // // Total Damage Mult: 2.04 or +104%
            // // Total Move Speed Mult: 1.24 or +24%
            // if (heads < 9 && !(heads > 9))
            // {
            //     Eyelander.AddAttribute("damage penalty", eyelander_damage_penalty + 0.05, -1)
            //     printdev("Damage Mult: x" + (eyelander_damage_penalty + 0.05))
            // }
            // else if (heads < 11 && !(heads > 11))
            // {
            //     Eyelander.AddAttribute("damage penalty", eyelander_damage_penalty + 0.1, -1)
            //     printdev("Damage Mult: x" + (eyelander_damage_penalty + 0.1))
            // }
            // else if (heads < 13 && !(heads > 13))
            // {
            //     Eyelander.AddAttribute("damage bonus", eyelander_damage_bonus + 0.1, -1)
            //     printdev("Damage Mult: x" + (eyelander_damage_bonus + 0.1))
            // }
            // else if (heads < 20)
            // {
            //     Eyelander.AddAttribute("damage bonus", eyelander_damage_bonus + 0.12, -1)
            //     printdev("Damage Mult: x" + (eyelander_damage_bonus + 0.12))
            // }

            // if (heads > 4 && heads < 16)
            // {
            //     player.AddCustomAttribute("move speed bonus", eyelander_movespeed_bonus + 0.02, -1)
            //     // printdev("Move Speed Mult: x" + (eyelander_movespeed_bonus + 0.02))
            // }
        }
    }

    function OnDamageTaken(attacker, params)
    {
		if (!Shield)
			return;

        if (Shield == Targe && Shield != null)
        {
            if (params.damage_type & DMG_CLUB)
                params.damage *= 0.8;
        }

        destroyShield = false;
        if (shieldBroken || !IsValidBoss(attacker) || player.InCond(TF_COND_INVULNERABLE))
            return;

        if ((params.damage_type == 1 || params.damage_type == DMG_BLAST) && params.damage < player.GetHealth())
            return;

        // Delfite: Saxton Punch!'s collateral WILL be resisted. Removing Lizard's extra-extra resistance because we merged Saxton Punch
        // into a single damage event instead of the usual 2 damage events it would normally do.
        params.damage *= 0.5;
        destroyShield = true;
    }

    function OnDamageTakenPost(attacker, params)
    {
		if (!Shield)
			return;

        if (!destroyShield)
            return;

        shieldBroken = true;
        player.AddCondEx(TF_COND_PREVENT_DEATH, 0, null);

        Shield.DisableDraw();

        // local deltaVector = player.GetCenter() - attacker.GetCenter();
        // deltaVector.z = 0;
        // deltaVector.Norm();
        // player.Yeet(deltaVector * 800 + Vector(0, 0, 450));

        EmitSoundOn("vsh_sfx.shield_break", player);
        EmitPlayerVODelayed(player, params.inflictor == custom_dmg_saxton_punch ? "shield_lowhp" : "shield", 1);
    }

    function CaberRecharge(timeDelta)
    {
        if (!caberChecked)
        {
            if (GetPropInt(weapon_melee, "m_iDetonated"))
            {
                timer = 12;
                caberChecked = true;
            }
            return;
        }

        timer -= timeDelta;

        if (timer < 0)
        {
            timer = 0;
            caberChecked = false;
            SetPropInt(weapon_melee, "m_iDetonated", 0);
            EmitSoundOnClient("TFPlayer.ReCharged", player);
            return EmitPlayerVO(player, "sticky_trap"); // Playing the sticky trap voiceline so player is more aware about the recharge.
        }
    }

    // Delfite: This function is responsible for granting mini-crits to any Demoman that taunts with their stock melee.
    // You cannot gain the buff with any taunt other than the stock Bottle taunt.
    // "By the power of Grayskull... And this beer I found!"
    function BottleTaunt()
    {
        if (player.IsTaunting())
        {
            if (bottleTauntPlaying)
                return;

            for (local scene; scene = Entities.FindByClassname(scene, "instanced_scripted_scene");)
            {
                if (bottleTauntPlaying)
                    break;

                local owner = GetPropEntity(scene, "m_hOwner")
                if (owner != player)
                    continue;

                local name = GetPropString(scene, "m_szInstanceFilename")
                // printdev("Active scene: " + name)
                if (name.find("taunt03_v3") == false)
                    continue;

                bottleTauntPlaying = true;
                RunWithDelay2(this, 3.5, function ()
                {
                    // Delfite: Make sure the player is still taunting after the delay. For all we know,
                    // Hale could've killed the Demoman or sent him flying out of the taunt.
                    if (player.IsTaunting())
                    {
                        player.SetHealth(clampCeiling(overheal_limit, player.GetHealth() + 100))
                        // Delfite: If the Demo is wearing boots and a shield, give them the Conch's effects after taunting.
                        if ((Boots && Shield) != null)
                        {
                            player.AddCondEx(TF_COND_REGENONDAMAGEBUFF, 31, player)
                            player.AddCondEx(TF_COND_SPEED_BOOST, 31, player)
                        }
                        // Delfite: Otherwise, give them mini-crits.
                        else
                            player.AddCondEx(TF_COND_OFFENSEBUFF, 21, player)
                    }
                })
                break;
            }
        }
        else
        {
            if (!bottleTauntPlaying)
                return;

            bottleTauntPlaying = false;
        }
    }

    function RunEyelanderDialogueSequence()
    {
        // printdev("Running dialogue sequence...")
        eyelanderDialogueRan = true;
        local boss = GetBossPlayers()[0]
        local boss_health_as_percent = boss.GetHealth().tofloat() / boss.GetMaxHealth().tofloat()

        RunWithDelay2(this, 2.0, function ()
        {
            if (boss_health_as_percent > 0.2 && GetAliveMercCount() == 1)
            {
                switch (RandomInt(0, 1))
                {
                    default:
                        PlayEyelanderIdleVO()
                        ClientPrint(player, 3, "\x0773a86d     AHHHH! I'M UP! I'M UP! WHAT DID I MISS?!")
                        RunEyelanderCritSequence()
                        RunWithDelay2(this, 2.25, function ()
                        {
                            PlayEyelanderIdleVO()
                            ClientPrint(player, 3, "\x0773a86d     Wait, are we..? Oh god, no!")
                            RunWithDelay2(this, 1.8, function ()
                            {
                                PlayEyelanderIdleVO()
                                ClientPrint(player, 3, "\x0773a86d     No! No! NO! Everyone else is dead! We've lost!")
                                RunWithDelay2(this, 2.4, function ()
                                {
                                    PlayEyelanderIdleVO()
                                    ClientPrint(player, 3, "\x0773a86d     Man, I sure hope you've got a plan Demo...")
                                    RunWithDelay2(this, 1.5, function ()
                                    {
                                        PlayEyelanderIdleVO()
                                        if (player.IsAlive())
                                            ClientPrint(player, 3, "\x0773a86d     'CAUSE I DON'T THINK I'M GONNA CUT IT THIS TIME!")
                                        else
                                        {
                                            ClientPrint(player, 3, "\x0773a86d     'Aaaaand I spoke too soon. Great.")
                                            RunWithDelay2(this, 1.6, function ()
                                            {
                                                PlayEyelanderIdleVO()
                                                ClientPrint(player, 3, "\x0773a86d     Guess it's back to the SMITHSONIAN for me.")
                                            })
                                        }
                                    })
                                })
                            })
                        })
                    break;
                }
            }
            else if (boss_health_as_percent < 0.2 && boss.GetMaxHealth() > 10000 && GetAliveMercCount() > 1 && GetAliveMercCount() < 4)
            {
                switch (RandomInt(0, 1))
                {
                    default:
                        PlayEyelanderIdleVO()
                        ClientPrint(player, 3, "\x0773a86d     Oh! Woah woah woah- wait!")
                        RunWithDelay2(this, 1.5, function ()
                        {
                            PlayEyelanderIdleVO()
                            ClientPrint(player, 3, "\x0773a86d     Demo! That overgrown oaf is almost dead!")
                            RunWithDelay2(this, 1.5, function ()
                            {
                                PlayEyelanderIdleVO()
                                ClientPrint(player, 3, "\x0773a86d     Take these crits and kick his ass!")
                                RunEyelanderCritSequence()
                                RunWithDelay2(this, 1.3, function ()
                                {
                                    PlayEyelanderIdleVO()
                                    ClientPrint(player, 3, "\x0773a86d     Someone's gotta teach that guy to put a shirt on, and that someone's gonna be you!")
                                })
                            })
                        })
                    break;
                }
            }
            else
            {
                switch (RandomInt(0, 3))
                {
                    case 0:
                        PlayEyelanderIdleVO()
                        ClientPrint(player, 3, "\x0773a86d     Oh, finally! I was gettin' bored!")
                        RunWithDelay2(this, 2.0, function ()
                        {
                            PlayEyelanderIdleVO()
                            ClientPrint(player, 3, "\x0773a86d     Here, you can have your crits back.")
                            RunWithDelay2(this, 1.0, function ()
                            {
                                RunEyelanderCritSequence()
                            })
                            RunWithDelay2(this, 2.0, function ()
                            {
                                PlayEyelanderIdleVO()
                                ClientPrint(player, 3, "\x0773a86d     I ended up not needin' 'em anyway.")
                            })
                        })
                    break;
                    case 1:
                        PlayEyelanderIdleVO()
                        ClientPrint(player, 3, "\x0773a86d     zzzzZZ- Wha- huh?")
                        RunWithDelay2(this, 1.2, function ()
                        {
                            PlayEyelanderIdleVO()
                            ClientPrint(player, 3, "\x0773a86d     Oh, right, your crits!")
                            RunWithDelay2(this, 1.0, function ()
                            {
                                RunEyelanderCritSequence()
                                RunWithDelay2(this, 1.0, function ()
                                {
                                    PlayEyelanderIdleVO()
                                    ClientPrint(player, 3, "\x0773a86d     Heh heh, sorry about that! I would've gotten 'em to ya' sooner except...")
                                    RunWithDelay2(this, 2.2, function ()
                                    {
                                        PlayEyelanderIdleVO()
                                        ClientPrint(player, 3, "\x0773a86d     Well... HEADS and all that.")
                                    })
                                })
                            })
                        })
                    break;
                    case 2:
                        PlayEyelanderIdleVO()
                        ClientPrint(player, 3, "\x0773a86d     *Yawn* Wha? Somethin' happen?")
                        RunWithDelay2(this, 1.4, function ()
                        {
                            PlayEyelanderIdleVO()
                            ClientPrint(player, 3, "\x0773a86d     Oh, hey, you got all my heads back!")
                            RunWithDelay2(this, 2.0, function ()
                            {
                                PlayEyelanderIdleVO()
                                ClientPrint(player, 3, "\x0773a86d     Alright. I GUESS you can have your precious ''melee crits''.")
                                RunWithDelay2(this, 2.0, function ()
                                {
                                    PlayEyelanderIdleVO()
                                    ClientPrint(player, 3, "\x0773a86d     UHH! Since I'm so... Magnanimous and all!")
                                    RunWithDelay2(this, 1.7, function ()
                                    {
                                        PlayEyelanderIdleVO()
                                        ClientPrint(player, 3, "\x0773a86d     Just don't make a stink to the devil if you end up")
                                        ClientPrint(player, 3, "\x0773a86d     dyin' with 'em, pancakes! I hate that guy...")
                                        RunEyelanderCritSequence()
                                    })
                                })
                            })
                        })
                    break;
                    case 3:
                        PlayEyelanderIdleVO()
                        ClientPrint(player, 3, "\x0773a86d     *Ding*")
                        RunWithDelay2(this, 1.8, function ()
                        {
                            PlayEyelanderIdleVO()
                            ClientPrint(player, 3, "\x0773a86d     Oh, my heads are ready!")
                            RunWithDelay2(this, 1.8, function ()
                            {
                                PlayEyelanderIdleVO()
                                ClientPrint(player, 3, "\x0773a86d     Alright Demo, you held up your end, now it's my turn.")
                                RunWithDelay2(this, 1.8, function ()
                                {
                                    PlayEyelanderIdleVO()
                                    ClientPrint(player, 3, "\x0773a86d     Go go gizmo critical hits!")
                                    RunEyelanderCritSequence()
                                })
                            })
                        })
                    break;
                }
            }
        })
    }

    function RunEyelanderCritSequence()
    {
        eyelanderCritSequencePlayed = true;
        player_scope.eyelanderCritsEnabled = true;
        player_scope.allowWallclimbVOs = false;
        RunWithDelay2(this, 12.0, function ()
        {
            player_scope.allowWallclimbVOs = true;
        })
        ClientPrint(player, 3, "   * Your stats were maxed out.")
        ClientPrint(player, 3, "      You became stronger.")
        EmitSoundEx(
        {
            sound_name = "items/powerup_pickup_team_revenge.wav"
            entity = player
            // filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
            volume = 1.0
        })
        RunWithDelay2(this, 1.5, function ()
        {
            if (!player.IsAlive())
                return;

            EmitSoundEx(
            {
                sound_name = demoman_vo_laughevil_array[RandomInt(0, 2)]
                entity = player
                volume = 1.0
                sound_level = 95
            })
            RunWithDelay2(this, 2.5, function ()
            {
                if (!player.IsAlive())
                    return;

                EmitSoundEx(
                {
                    sound_name = demoman_vo_taunts_array[RandomInt(0, 10)]
                    entity = player
                    volume = 1.0
                    sound_level = 110
                })
            })
        })
    }

    function PlayEyelanderIdleVO()
    {
        EmitSoundEx(
        {
            sound_name = eyelander_vo_idle_array[RandomInt(0, 14)]
            entity = player
            filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
            volume = 1.0
        })
    }

    function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("Projectile speed increased");
        }

        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("Projectile speed increased");
        }

        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("damage bonus");
            weapon_melee.RemoveAttribute("damage penalty");
            weapon_melee.RemoveAttribute("dmg taken increased");
            weapon_melee.RemoveAttribute("rocket jump damage reduction");
        }
    }
});