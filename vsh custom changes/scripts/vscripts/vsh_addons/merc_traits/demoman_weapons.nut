// Script by: Senni, Delfite, LizardOfOz.
// With assistance from: Bradasparky, Dice.
// This script handles everything to do with Demoman's weapons.
// Requires modification of `weapons.nut` to function.


PrecacheArbitrarySound("vsh_sfx.shield_break");
PrecacheArbitrarySound("demo.shield")
PrecacheArbitrarySound("demo.shield_lowhp")

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;
	weapon_secondary = null;
	weapon_melee = null;
	wearable = null;

    // Primary handles.


    // Secondary handles.


    // Melee handles.
    Katana = null;
    Eyelander = null;
    ClaidMor = null;
    Caber = null;

    // Wearable handles.
    Boots = null;
    Shield = null;
    Tideturner = null;
    SplendidScreen = null;

    // caberRechargeActive = false;
    // caber_recharge_timestamp = 0;

    caberTimer = 0;
    timer = 0;
    caberChecked = false;

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

        // Primary definitions.
        weapon_primary.AddAttribute("Projectile speed increased", weapon_primary.GetAttribute("Projectile speed increased", 1.0) + 0.35, -1)
        // Delfite: Projectiles are remarkably slow by default, and Hale is pretty dang fast. A little projectile speed should help bridge the gap.
        //printdev("Generic Demoman primary stats applied.")
        if (WeaponIs(weapon_primary, "grenade_launcher"))
        {
            weapon_primary.AddAttribute("clip size bonus", 1.5, -1)
            weapon_primary.AddAttribute("maxammo primary increased", 1.5, -1)
            weapon_primary.AddAttribute("Reload time decreased", 0.8, -1)
            weapon_primary.AddAttribute("fire rate bonus", 0.85, -1)
            //printdev("Grenade Launcher stats applied.")
        }
        // Purpose: Strengthen the Iron Bomber's identity as a pseudo-jumper weapon, at the cost of some of its damage output.
        //
        if (WeaponIs(weapon_primary, "iron_bomber"))
        {
            weapon_primary.AddAttribute("Blast radius increased", 1.35, -1)
            weapon_primary.AddAttribute("Projectile speed increased", 1.15, -1)
            weapon_primary.AddAttribute("fuse bonus", 0.3, -1)
            // Fuse time: From -30% -> -80%. Still lets you hit Hale at medium range while decreasing the interval between jumps to a reasonable level.
            weapon_primary.AddAttribute("rocket jump damage reduction", 0.0, -1)
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
            weapon_primary.AddAttribute("damage bonus", 1.2, -1)
            // Delfite:	Hale isn't a building. As funny as that sounds out loud, we still need to give the Loch-n-Load a damage bonus.
            weapon_primary.AddAttribute("fire rate bonus", 0.8, -1)
            //printdev("Loch-n-Load stats applied.")
        }
        // else if (WeaponIs(weapon_primary, "loose_cannon"))
        // {
        // 	weapon_primary.AddAttribute("", 0, -1)
        // 	weapon_primary.AddAttribute("damage penalty", weapon_primary.GetAttribute("damage bonus", 1.0) - 0.15, -1)
        // }

        // Secondary definitions.
        weapon_secondary.AddAttribute("Projectile speed increased", 1.20, -1)
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
        // Delfite: The Scottish Resistance benefits from being able to set up multiple traps. Paired with Engineer buildings, it can be an incredibly
        // powerful weapon, but on its own it's not very strong due to how long it takes to set up each trap, as well as requiring both the user to be
        // smart enough to take advantage of the weapon's unique attribute and Hale to lack the awareness needed to spot the player's traps.
        // With these downsides in mind, I decided to make the weapon a little more agile by making it reload faster, but nerfing its damage slightly
        // to compensate, since stacking 14 stickies in one trap still does an enormous amount of damage and knockback to Hale.
        else if (WeaponIs(weapon_secondary, "scottish_resistance"))
        {
            weapon_secondary.AddAttribute("damage penalty", 0.9, -1)
            weapon_secondary.AddAttribute("Reload time decreased", 0.85, -1)
        }
        // Delfite: The quickiebomb launcher, due to its short arm time, is generally better as an offensive implement than a trapping tool.
        // As a result, I decided to buff its blast radius to make hitting Hale with the explosions easier.
        else if (WeaponIs(weapon_secondary, "quickiebomb_launcher"))
        {
            weapon_secondary.AddAttribute("Blast radius increased", 1.5, -1)
            weapon_secondary.AddAttribute("clip size penalty", 0.75, -1)
            weapon_secondary.AddAttribute("max pipebombs decreased", -2, -1)
        }
        else if (WeaponIs(weapon_secondary, "base_jumper_demoman"))
        {
            weapon_secondary.AddAttribute("max health additive bonus", 25, -1)
            weapon_secondary.AddAttribute("rocket jump damage reduction", 0.40, -1)
        }

        // Melee definitions.
        if (WeaponIs(weapon_melee, "bottle"))
        {

        }
        else if (WeaponIs(weapon_melee, "half_zatoichi"))
        {
            Katana = weapon_melee;
            // printdev("Half-Zatoichi stats applied.")
        }
        else if (WeaponIs(weapon_melee, "eyelander"))
        {
            Eyelander = weapon_melee;
            Eyelander.AddAttribute("max health additive penalty", 0, -1)
            // printdev("Eyelander stats applied.")
        }
        else if (WeaponIs(weapon_melee, "claidheamh_mor"))
        {
            ClaidMor = weapon_melee;
            ClaidMor.AddAttribute("dmg taken increased" 1.0, -1);
            // printdev("Claidheamh Mor stats applied.")
        }
        else if (WeaponIs(weapon_melee, "scotsman_skullcutter"))
        {
            weapon_melee.AddAttribute("move speed penalty" 1.0, -1);
            // printdev("Skullcutter stats applied.")
        }
        else if (WeaponIs(weapon_melee, "ullapool_caber"))
        {
            Caber = weapon_melee;
            Caber.AddAttribute("rocket jump damage reduction", 0.75, -1)
            Caber.AddAttribute("item_meter_charge_type", 3, -1)
            Caber.AddAttribute("mult_item_meter_charge_rate", 3, -1)
            Caber.AddAttribute("item_meter_damage_for_full_charge", 300, -1)
            // printdev("Caber stats applied.")
        }

        // Wearable definitions.
        RunWithDelay2(this, 0.1, function() // Delfite: Adding a delay here to apply the attributes, otherwise there's a chance they won't.
        {
            while (wearable = FindByClassname(wearable, "tf_wear*"))
            {
                printdev("Searching through Demoman's wearables...")
                if (wearable.GetOwner() == player)
				{
                    if (WeaponIs(wearable, "any_demo_boots"))
                    {
                        // printdev("Boots found.")
                        // Remove the speed boost currently on the boots.
                        Boots = wearable;
                        Boots.AddAttribute("max health additive bonus", 0, -1)
                        Boots.AddAttribute("move speed bonus shield required", 1.0, -1)
                        Boots.AddAttribute("cancel falling damage", 1, -1)
                        Boots.AddAttribute("rocket jump damage reduction", 0.4, -1)

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
                            Boots.AddAttribute("move speed bonus", 1.15, -1)
                        bootsAttributesApplied = true;
                    }

                    // Delfite: Don't put an `else` here. You can have a shield and boots equipped at the same time, after all.
                    if (WeaponIs(wearable, "any_shield"))
                    {
                        Shield = wearable;
                        Shield.EnableDraw();
                        if (WeaponIs(wearable, "tideturner"))
                        {
                            Tideturner = wearable;
                        }
                        else if (WeaponIs(wearable, "chargin_targe"))
                        {
                            wearable.AddAttribute("rocket jump damage reduction", 0.4, -1)
                            wearable.AddAttribute("dmg taken from blast reduced", 0.5, -1)
                        }
                        else if (WeaponIs(wearable, "splendid_screen"))
                        {
                            SplendidScreen = wearable;
                        }
                        shieldAttributesApplied = true;
                    }
                }
                else
                    break;
                // Delfite: Stop iterating through wearables if we've applied our stats to both.
                if (bootsAttributesApplied && shieldAttributesApplied)
                    break;
            }
        })
        player.Regenerate(true)
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
        if (weapon_melee == Caber)
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
    }

    // Delfite: Instead of applying the "charge on hit" attribute to demo's current melee, we'll just add charge via NetProps.
    function OnDamageDealt(victim, params)
    {
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
                // printdev("Charge added via boots.")
            }
        }

        // Delfite: Half-Zatoichi heal-on-hit code.
        if (params.weapon == Katana)
        {
            local newHealth = player.GetHealth() + player.GetMaxHealth() / 2.0;
            local maxOverheal = player.GetMaxHealth() * 1.5
            player.SetHealth(clampCeiling(newHealth, maxOverheal));
			SetPropInt(params.weapon, "m_bIsBloody", 1);
			AddPropInt(player, "m_Shared.m_iKillCountSinceLastDeploy", 1);
        }
    }

    function OnDamageTaken(attacker, params)
    {
		if (!Shield)
			return;

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

        local wearable = null;
        while (wearable = FindByClassname(wearable, "tf_wearable_demo*"))
            if (wearable.GetOwner() == player)
            {
                wearable.DisableDraw();
                break;
            }

        local deltaVector = player.GetCenter() - attacker.GetCenter();
        deltaVector.z = 0;
        deltaVector.Norm();
        player.Yeet(deltaVector * 600 + Vector(0, 0, 450));

        EmitSoundOn("vsh_sfx.shield_break", player);
        EmitPlayerVODelayed(player, params.inflictor == custom_dmg_saxton_punch ? "shield_lowhp" : "shield", 1);
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
            weapon_melee.RemoveAttribute("dmg taken increased");
            weapon_melee.RemoveAttribute("rocket jump damage reduction");
        }
    }
});