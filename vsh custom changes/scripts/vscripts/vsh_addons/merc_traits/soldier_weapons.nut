// Script by: Senni, Delfite.
// With assistance from: Bradasparky, Horiuchi.
// This script handles everything to do with Soldier's weapons, except `soldier_haste.nut` due to its massive size and complexity.
// All code in this script was previously split into 3 different scripts, one for each weapon slot.
// The code was merged into one file for easier variable management, reduced lag when using Tick functions, and slightly better RAM usage.
// This script requires modification of `weapons.nut` in order to function.


PrecacheSound("weapons/medigun_no_target.wav")
PrecacheSound("items/samurai/tf_conch.wav")
PrecacheScriptSound("Weapon_BuffBanner.HornRed")
PrecacheScriptSound("Weapon_BuffBanner.HornBlue")
PrecacheScriptSound("Weapon_BattalionsBackup.HornRed")
PrecacheScriptSound("Weapon_BattalionsBackup.HornBlue")
PrecacheArbitrarySound("soldier.gardened")
PrecacheArbitrarySound("vsh_sfx.gardened")

::banner_vo_array <- [
    "vo/taunts/soldier_taunts07.mp3",
    "vo/taunts/soldier_taunts08.mp3",
    "vo/taunts/soldier_taunts13.mp3",
    "vo/taunts/soldier_taunts14.mp3",
    "vo/taunts/soldier_taunts16.mp3",
    "vo/taunts/soldier_taunts17.mp3",
    "vo/taunts/soldier_taunts18.mp3",
    "vo/taunts/soldier_taunts19.mp3",
    "vo/taunts/soldier_taunts20.mp3",
]

AddListener("setup_start", 1, function()
{
	// Delfite: These cvars control everything to do with the Base Jumper. Their values are set every time setup starts.
	// These cvars are also hidden in-game and considered dev commands, but can still be set by VScript nonetheless.
	Convars.SetValue("tf_parachute_aircontrol", 2.5)                                                // Default: 2.5
	Convars.SetValue("tf_parachute_deploy_toggle_allowed", 0)                                       // Default: 0
	Convars.SetValue("tf_parachute_gravity", 0.2)                                                   // Default: 0.2
	Convars.SetValue("tf_parachute_maxspeed_onfire_z", -100)                                        // Default: -100
	Convars.SetValue("tf_parachute_maxspeed_xy", 300)                                               // Default: 300
	Convars.SetValue("tf_parachute_maxspeed_z", -100)                                               // Default: -100

	// printdev("tf_parachute_aircontrol = " + Convars.GetFloat("tf_parachute_aircontrol"))
	// printdev("tf_parachute_deploy_toggle_allowed = " + Convars.GetFloat("tf_parachute_deploy_toggle_allowed"))
	// printdev("tf_parachute_gravity = " + Convars.GetFloat("tf_parachute_gravity"))
	// printdev("tf_parachute_maxspeed_onfire_z = " + Convars.GetFloat("tf_parachute_maxspeed_onfire_z"))
	// printdev("tf_parachute_maxspeed_xy = " + Convars.GetFloat("tf_parachute_maxspeed_xy"))
	// printdev("tf_parachute_maxspeed_z = " + Convars.GetFloat("tf_parachute_maxspeed_z"))
});

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;
    weapon_secondary = null;
	weapon_melee = null;

    overheal_limit = 0;

	damage_accumulated = 0;

    you = null;

	// Primary handles.
    Airstrike = null;
    DirectHit = null;
    RocketJumper = null;

	// Secondary handles.
	Shotgun = null;
    Bison = null;
    BuffBanner = null;
    Batts = null;
    Conch = null;
    Gunboats = null;

	// Melee handles.
    EscapePlan = null;
    Equalizer = null;
    Katana = null;
    MarketGardener = null;

    // Banner variables.
    // prev_attack_time = 0;

    lastHitWasAirStrike = false;
	lastHitWasShotgun = false;
	lastHitWasKatana = false;
    lastHitTakenWasExplosive = false;
    lastHitTakenWasSaxtonPunch = false;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_SOLDIER
	}

	function OnApply()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
		weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
		you = player;

		// Primary definitions.
		if (WeaponIs(weapon_primary, "rocket_launcher"))
        {
            weapon_primary.AddAttribute("fire rate bonus" 0.9, -1);
            weapon_primary.AddAttribute("reload time decreased" 0.75, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.4, -1);
        }
        if (WeaponIs(weapon_primary, "black_box"))
        {
            weapon_primary.AddAttribute("health on radius damage" 50, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.4, -1);
        }
        if (WeaponIs(weapon_primary, "beggars_bazooka"))
        {
            weapon_primary.AddAttribute("projectile spread angle penalty" 0, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.4, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.75, -1);
        }
        if (WeaponIs(weapon_primary, "air_strike"))
        {
            Airstrike = weapon_primary;
            weapon_primary.AddAttribute("reload time decreased", 0.85, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.4, -1);
        }
        if (WeaponIs(weapon_primary, "liberty_launcher"))
        {
            // weapon_primary.AddAttribute("rocketjump attackrate bonus", 0.35, -1)
            // weapon_primary.AddAttribute("reload time decreased" 0.75, -1);
            weapon_primary.AddAttribute("self dmg push force increased", 1.20, -1)
            weapon_primary.AddAttribute("Projectile speed increased", 1.65, -1);
            weapon_primary.AddAttribute("rocket jump damage reduction", 0.0, -1);
        }
        if (WeaponIs(weapon_primary, "direct_hit"))
        {
            DirectHit = weapon_primary;
            weapon_primary.AddAttribute("Projectile speed increased", 1.0, -1)
            weapon_primary.AddAttribute("damage bonus", 1.15, -1)
        }
        if (WeaponIs(weapon_primary, "rocket_jumper"))
        {
            RocketJumper = weapon_primary;
            weapon_primary.AddAttribute("damage penalty", 1.0, -1);
            weapon_primary.AddAttribute("rocket jump damage reduction", 0.0, -1);
            weapon_primary.AddAttribute("no self blast dmg", 1, -1);
            weapon_primary.AddAttribute("maxammo primary increased", 1, -1);
            // SetPropInt(player, "m_iAmmo.001", 20)
        }

		// Secondary definitions.
		if (WeaponIs(weapon_secondary, "shotgun"))
        {
            Shotgun = weapon_secondary;
            weapon_secondary.AddAttribute("damage bonus" 1.10, -1);
            weapon_secondary.AddAttribute("weapon spread bonus", 0.70, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.85, -1);
            weapon_secondary.AddAttribute("single wep deploy time decreased", 0.8, -1);
        }
        if (WeaponIs(weapon_secondary, "reserve_shooter"))
        {
            // weapon_secondary.AddAttribute("weapon spread bonus" 0.70, -1);
        }
        if (WeaponIs(weapon_secondary, "panic_attack"))
		{
			weapon_secondary.AddAttribute("damage bonus", 1.25, -1);
			weapon_secondary.AddAttribute("weapon spread bonus", 0.6, -1);
			weapon_secondary.AddAttribute("reload time decreased", 0.6, -1);
			weapon_secondary.AddAttribute("fire rate bonus", 0.7, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
		}
        if (WeaponIs(weapon_secondary, "righteous_bison"))
        {
            Bison = weapon_secondary;
            weapon_secondary.AddAttribute("energy weapon penetration", 0, -1);
            weapon_secondary.AddAttribute("fire rate bonus", 0.80, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.80, -1);
            weapon_secondary.AddAttribute("dmg penalty vs players", 1.5, -1);
        }
        if (WeaponIs(weapon_secondary, "base_jumper_soldier"))
        {
            weapon_secondary.AddAttribute("rocket jump damage reduction", 0.40, -1);
        }
        if (WeaponIs(weapon_secondary, "buff_banner"))
        {
            BuffBanner = weapon_secondary;
            weapon_secondary.AddAttribute("increase buff duration", 1.5, -1);
        }
        if (WeaponIs(weapon_secondary, "battalions_backup"))
        {
            Batts = weapon_secondary;
            weapon_secondary.AddAttribute("increase buff duration", 1.5, -1);
        }
        if (WeaponIs(weapon_secondary, "concheror"))
        {
            Conch = weapon_secondary;
            weapon_secondary.AddAttribute("increase buff duration", 1.5, -1);
        }

		// Melee definitions.
		if (WeaponIs(weapon_melee, "shovel"))
		{
			weapon_melee.AddAttribute("damage bonus", 1.30, -1);
		}
		if (WeaponIs(weapon_melee, "escape_plan"))
		{
            EscapePlan = weapon_melee;
			weapon_melee.AddAttribute("self mark for death", 0, -1);
			weapon_melee.AddAttribute("mod shovel speed boost", 0, -1);
			weapon_melee.AddAttribute("move speed bonus", 1.20, -1);
			weapon_melee.AddAttribute("damage penalty", 0.65, -1);
			// Delfite: The escape plan already uses the "provide on active" attribute, so there's no need to include it here.
		}
		if (WeaponIs(weapon_melee, "equalizer"))
        {
            Equalizer = weapon_melee;
        }
		if (WeaponIs(weapon_melee, "half_zatoichi"))
		{
			Katana = weapon_melee;
		}
		if (WeaponIs(weapon_melee, "market_gardener"))
		{
			MarketGardener = weapon_melee;
            weapon_melee.AddAttribute("move speed penalty", 0.90, -1)
		}

		// Wearable definitions.
		RunWithDelay2(this, 0.0, function() //This delay is hopefully to prevent issues with it not applying. - Senni
        {
            local wearable = null;
            while (wearable = FindByClassname(wearable, "tf_wearable"))
            {
                if (wearable.GetOwner() == player && WeaponIs(wearable, "gunboats")) //Gunboats aren't considered a weapon, so this is a workaround. - Senni
                {
                    wearable.AddAttribute("cancel falling damage", 1, -1);
                    Gunboats = wearable;
                    break;
                }
            }
        })
	}

    function OnTickAlive(timeDelta)
    {
        if (weapon_secondary == (BuffBanner || Batts || Conch) && weapon_secondary != null)
        {
            // prev_attack_time = GetPropFloat(weapon_secondary, "m_flNextPrimaryAttack")
            BannerBuffControl()
        }
    }

	function OnFrameTickAlive()
    {
        if (weapon_secondary == (BuffBanner || Batts || Conch) && weapon_secondary != null)
        {
            RageThink()
            BannerControlThink()
        }
    }

    function OnDamageDealt(victim, params)
    {
        lastHitWasShotgun = params.weapon == Shotgun;
		lastHitWasAirStrike = player != victim && params.weapon == Airstrike;
        lastHitWasKatana = player != victim && params.weapon == Katana;

        if (lastHitWasAirStrike)
        {
            // Delfite: Run with a short delay to give OnHurtDealtEvent time to catch up and update our head count.
            RunWithDelay2(this, 0.05, function ()
            {
                local heads = GetPropInt(player, "m_Shared.m_iDecapitations");
                if (player.IsAlive())
                {
                    local reload_speed_bonus = player.GetCustomAttribute("reload time decreased", 1.0)
                    if (heads < 5)
                        player.AddCustomAttribute("reload time decreased", reload_speed_bonus - 0.05, -1)
                }
            })
        }

        // Delfite: This code makes the Rocket Jumper inflict no damage to Hale.
        if (params.weapon == RocketJumper && player != victim)
        {
            // printdev("Rocket Jumper hit someone.")
            local your_center = player.GetCenter();
            foreach (boss in GetAliveBossPlayers())
            {
                local distanceToBoss = (boss.GetCenter() - your_center).Length()
                if (distanceToBoss >= 180)
                    params.damage = 0.0;
                break;
            }
        }

        if (params.weapon == Bison)
        {
            if (params.damage_type & DMG_ACID)
                params.damage *= 0.67
        }

        // Delfite: Market Gardener damage calculation code.
        if (params.weapon == MarketGardener && player.InCond(TF_COND_BLASTJUMPING) && !player.IsOnGround())
        {
            params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5;
            EmitSoundOn("vsh_sfx.gardened", player);
            EmitPlayerVODelayed(player, "gardened", 0.3);
        }

        // Delfite: Half-Zatoichi heal-on-hit code.
        if (params.weapon == Katana)
        {
            // local new_health = player.GetHealth() + player.GetMaxHealth() / 2.0;
            // local maxOverheal = player.GetMaxHealth() * 1.5
            // player.SetHealth(clampCeiling(new_health, overheal_limit));
            player.SetHealth(clampCeiling(player.GetMaxOverheal(), player.GetHealth() + (player.GetMaxHealth() / 2)))
			SetPropInt(params.weapon, "m_bIsBloody", 1);
			AddPropInt(player, "m_Shared.m_iKillCountSinceLastDeploy", 1);
        }
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (lastHitWasAirStrike)
        {
            damage_accumulated += params.damageamount;
            while (damage_accumulated >= 180)
            {
                AddPropInt(player, "m_Shared.m_iDecapitations", 1);
                damage_accumulated -= 180;
            }
        }

		if (lastHitWasShotgun)
		{
			local damage_dealt = params.damageamount
			player.SetHealth(clampCeiling(player.GetMaxOverheal(), player.GetHealth() + (damage_dealt / 2)))
		}
    }

    function OnDamageTaken(attacker, params)
    {
        if (params.damage_type & DMG_BLAST)
            lastHitTakenWasExplosive = true;
        else
            lastHitTakenWasExplosive = false;
        lastHitTakenWasSaxtonPunch = params.inflictor == custom_dmg_saxton_punch;

        if (weapon_primary == RocketJumper && params.weapon == RocketJumper)
        {
            local your_center = player.GetCenter();
            foreach (boss in GetAliveBossPlayers())
            {
                local distanceToBoss = (boss.GetCenter() - your_center).Length()
                if (distanceToBoss < 180)
                    RocketJumper.AddAttribute("self dmg push force increased", 1.40, -1)
                else
                    RocketJumper.RemoveAttribute("self dmg push force increased");
                break;
            }
        }
    }

    function OnDamageTakenPost(attacker, params)
    {
        local active_weapon = player.GetActiveWeapon()
        if (active_weapon == (EscapePlan || Equalizer))
        {
            // printdev(lastHitTakenWasExplosive + " | " + lastHitTakenWasSaxtonPunch)
            if (!lastHitTakenWasExplosive || lastHitTakenWasSaxtonPunch)
                return;

            if (player.InCond(TF_COND_TAUNTING))
            {
                // Delfite: Let it be known that this condition ONLY prevents death if your health is greater than 1.
                // player.AddCondEx(TF_COND_PREVENT_DEATH, 0.2, null);
                player.AddCustomAttribute("no self blast dmg", 2, 0.05)
            }
        }
    }

	// Delfite: This function is responsible for adding Rage to every player's currently equipped banner.
    // Only runs if a banner is equipped.
    function RageThink()
    {
        local rage = player.GetRageMeter();

        if (rage < 100 && !player.IsRageDraining()) // Delfite: Stop charging the banner at 100% and while it's draining.
        {
            player.SetRageMeter(clampCeiling(100, rage + 0.02525252525252525252525252525253)); //Adding 0.025 to the meter to get 60 seconds - Senni
            //printdev(rage) //Debug
        }
    }

    // Delfite: This function controls each banner's buffs, their duration, and the range they're applied in.
    function BannerBuffControl()
    {
        if (!player.IsRageDraining())
            return;

        local your_center = you.GetCenter()
        foreach (player in GetAliveMercs())
        {
            local distance_from_you = (player.GetCenter() - your_center).Length()
            if (distance_from_you <= 700)
            {
                switch (weapon_secondary)
                {
                    case BuffBanner:
                        player.AddCondEx(TF_COND_OFFENSEBUFF, 0.11, you)
                        break;
                    case Batts:
                        player.AddCondEx(TF_COND_DEFENSEBUFF, 0.11, you)
                        break;
                    case Conch:
                        player.AddCondEx(TF_COND_REGENONDAMAGEBUFF, 0.11, you)
                        break;
                    default:
                        break;
                }
            }
        }
    }

    // Delfite: This function aims to address Soldier's banners preventing him from switching weapons until he's done blowing the horn.
    // This code, however, still has some issues that need to be fixed:
    // 1. The manner in which this code activates Soldier's rage causes the banner to not pop out of his backpack.
    // 2. After the player's rage is done draining, switching back to the banner causes it to trigger its "blowing" sequence again,
    // while also preventing you from switching weapons during the animation.

    // As a temporary (potentially permanent) fix to number 2, I've made it so you automatically activate your banner when you switch to it.
    // It might be a bit jarring for people to get used to at first, but I'm sure with time people will learn to play around it.
    function BannerControlThink()
    {
        local active_weapon = player.GetActiveWeapon()
        local last_weapon = player.GetLastWeapon()
        local attack_time = GetPropFloat(weapon_secondary, "m_flNextPrimaryAttack")
        local sequence = GetPropInt(weapon_secondary, "m_nSequence")
        local skin = GetPropInt(weapon_secondary, "m_nSkin")
        if (active_weapon == (BuffBanner || Batts || Conch))
        {
            // printdev(sequence)
            // printdev("Skin: " + skin)
            // if (sequence == 23 || sequence == 27)
            // if (attack_time > prev_attack_time)

            // Delfite: While the player's banner is active, skip over the banner and go to the next weapon slot.
            if (player.IsRageDraining() || player.GetRageMeter() < 100)
            {
                // printdev("Skin: " + skin)
                // weapon_secondary.RemoveAttribute("gesture speed increase")
                // player.RemoveCustomAttribute("gesture speed increase")
                // SetPropEntity(player, "m_hActiveWeapon", null)
                if (last_weapon == weapon_primary)
                    player.Weapon_Switch(weapon_melee)
                else
                    player.Weapon_Switch(weapon_primary)

                if (!player.IsRageDraining() && player.GetRageMeter() < 100)
                {
                    EmitSoundEx(
                    {
                        sound_name = "weapons/medigun_no_target.wav"
                        entity = player
                        filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
                        volume = 1.0
                        channel = 6
                    })
                }
            }
            else if (!player.IsRageDraining())
            {
                // printdev("Skin: " + skin)
                // weapon_secondary.AddAttribute("gesture speed increase", 1.5, -1)
                // player.AddCustomAttribute("gesture speed increase", 1.5, -1)
                if (player.GetRageMeter() == 100)
                {
                    SetPropBool(player, "m_Shared.m_bRageDraining", true)
                    switch (weapon_secondary)
                    {
                        case BuffBanner:
                            if (player.GetTeam() == TF_TEAM_RED)
                                EmitSoundOn("Weapon_BuffBanner.HornRed", player)
                            else
                                EmitSoundOn("Weapon_BuffBanner.HornBlue", player)
                            break;
                        case Batts:
                            if (player.GetTeam() == TF_TEAM_RED)
                                EmitSoundOn("Weapon_BattalionsBackup.HornRed", player)
                            else
                                EmitSoundOn("Weapon_BattalionsBackup.HornBlue", player)
                            break;
                        case Conch:
                            EmitSoundEx(
                            {
                                sound_name = "items/samurai/tf_conch.wav"
                                entity = player
                                filter_type = RECIPIENT_FILTER_DEFAULT
                                volume = 1.0
                                channel = 6
                            })
                            break;
                        default:
                            break;
                    }
                    SetPropEntity(player, "m_hActiveWeapon", null)
                    // Delfite: If our primary was the last weapon, make sure it has ammo before we switch back.
                    // Otherwise, switch to the player's melee.
                    player.Weapon_Switch(weapon_primary)
                    player.AcceptInput("SpeakResponseConcept", "TLK_PLAYER_BATTLECRY", null, null)
                    // EmitSoundOn(banner_vo_array[RandomInt(0, 8)], player)
                }
                // TODO: Play each merc's competitive mode victory lines when defeating Hale.
                // printdev(sequence)
            }

            // printdev("Sequence: " + sequence + " | Attack Time: " + attack_time + " | Prev. Attack Time: " + prev_attack_time)
        }
    }

	function OnDiscard()
    {
		if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("damage penalty");
            weapon_primary.RemoveAttribute("self dmg push force increased");
            weapon_primary.RemoveAttribute("reload time decreased");
            weapon_primary.RemoveAttribute("health on radius damage");
            weapon_primary.RemoveAttribute("projectile spread angle penalty");
        }

		if (weapon_secondary && weapon_secondary.IsValid())
        {
            // weapon_secondary.RemoveAttribute("gesture speed increase")
        }

        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("movement speed bonus");
        }
    }
});