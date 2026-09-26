// Script by: Senni, Delfite.
// With assistance from: Bradasparky, Horiuchi.
// This script handles everything to do with Soldier's weapons, except `soldier_haste.nut` due to its massive size and complexity.
// All code in this script was previously split into 3 different scripts, one for each weapon slot.
// The code was merged into one file for easier variable management, reduced lag when using Tick functions, and slightly better RAM usage.
// This script requires modification of `weapons.nut` in order to function.


PrecacheScriptSound("Player.ResistanceMedium")

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

	damageAccumulated = 0;

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

    lastHitWasAirStrike = false;
	lastHitWasShotgun = false;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_SOLDIER
	}

	function OnApply()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
		weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
		you = player

		// Primary definitions.
		if (WeaponIs(weapon_primary, "rocket_launcher"))
        {
            weapon_primary.AddAttribute("fire rate bonus" 0.85, -1);
            weapon_primary.AddAttribute("reload time decreased" 0.75, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
        }
        else if (WeaponIs(weapon_primary, "black_box"))
        {
            weapon_primary.AddAttribute("health on radius damage" 50, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
        }
        else if (WeaponIs(weapon_primary, "beggars_bazooka"))
        {
            weapon_primary.AddAttribute("projectile spread angle penalty" 0, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.75, -1);
        }
        else if (WeaponIs(weapon_primary, "air_strike"))
        {
            Airstrike = weapon_primary
            Airstrike.AddAttribute("reload time decreased", 0.85, -1);
            Airstrike.AddAttribute("Projectile speed increased", 1.4, -1);
        }
        else if (WeaponIs(weapon_primary, "liberty_launcher"))
        {
            // weapon_primary.AddAttribute("rocketjump attackrate bonus", 0.35, -1)
            // weapon_primary.AddAttribute("reload time decreased" 0.75, -1);
            weapon_primary.AddAttribute("self dmg push force increased", 1.20, -1)
            weapon_primary.AddAttribute("Projectile speed increased", 1.65, -1);
            weapon_primary.AddAttribute("rocket jump damage reduction", 0.0, -1);
        }
        else if (WeaponIs(weapon_primary, "direct_hit"))
        {
            DirectHit = weapon_primary
            DirectHit.AddAttribute("Projectile speed increased", 1.0, -1)
            DirectHit.AddAttribute("damage bonus", 1.15, -1)
        }
        else if (WeaponIs(weapon_primary, "rocket_jumper"))
        {
            RocketJumper = weapon_primary
            RocketJumper.AddAttribute("damage penalty", 1.0, -1);
            RocketJumper.AddAttribute("rocket jump damage reduction", 0.0, -1);
            RocketJumper.AddAttribute("no self blast dmg", 1, -1);
            RocketJumper.AddAttribute("maxammo primary increased", 1, -1);
            // SetPropInt(player, "m_iAmmo.001", 20)
        }

		// Secondary definitions.
		if (WeaponIs(weapon_secondary, "shotgun"))
        {
            Shotgun = weapon_secondary;
            // Shotgun.AddAttribute("damage bonus" 1.40, -1);
            Shotgun.AddAttribute("weapon spread bonus", 0.70, -1);
            Shotgun.AddAttribute("reload time decreased", 0.85, -1);
        }
        else if (WeaponIs(weapon_secondary, "reserve_shooter"))
        {
            // weapon_secondary.AddAttribute("weapon spread bonus" 0.70, -1);
        }
        else if (WeaponIs(weapon_secondary, "panic_attack"))
        {
            weapon_secondary.AddAttribute("weapon spread bonus" 0.6, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
        }
        else if (WeaponIs(weapon_secondary, "righteous_bison"))
        {
            weapon_secondary.AddAttribute("energy weapon penetration", 0, -1);
            weapon_secondary.AddAttribute("fire rate bonus", 0.80, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.80, -1);
            weapon_secondary.AddAttribute("dmg penalty vs players", 1.2, -1);
            Bison = weapon_secondary
        }
        else if (WeaponIs(weapon_secondary, "base_jumper_soldier"))
        {
            weapon_secondary.AddAttribute("rocket jump damage reduction", 0.40, -1)
        }
        else if (WeaponIs(weapon_secondary, "buff_banner"))
        {
            BuffBanner = weapon_secondary
        }
        else if (WeaponIs(weapon_secondary, "battalions_backup"))
        {
            Batts = weapon_secondary
        }
        else if (WeaponIs(weapon_secondary, "concheror"))
        {
            Conch = weapon_secondary
        }

		// Melee definitions.
		if (WeaponIs(weapon_melee, "shovel"))
		{
			weapon_melee.AddAttribute("damage bonus", 1.30, -1);
		}
		else if (WeaponIs(weapon_melee, "escape_plan"))
		{
			weapon_melee.AddAttribute("self mark for death", 0, -1);
			weapon_melee.AddAttribute("mod shovel speed boost", 0, -1);
			weapon_melee.AddAttribute("move speed bonus", 1.4, -1);
			weapon_melee.AddAttribute("damage penalty", 0.65, -1);
			// Delfite: The escape plan already uses the "provide on active" attribute, so there's no need to include it here.
		}

		// Wearable definitions.
		RunWithDelay2(this, 0.1, function() //This delay is hopefully to prevent issues with it not applying. - Senni
        {
            local wearable = null;
            while (wearable = FindByClassname(wearable, "tf_wearable"))
            {
                if (wearable.GetOwner() == player && WeaponIs(wearable, "gunboats")) //Gunboats aren't considered a weapon, so this is a workaround. - Senni
                {
                    wearable.AddAttribute("cancel falling damage", 1, -1);
                    Gunboats = wearable
                    break;
                }
            }
        })
	}

	function OnFrameTickAlive()
    {
        if (weapon_secondary == (BuffBanner || Batts || Conch))
            RageThink()
    }

	function OnDamageTaken(attacker, params)
    {
        if (RocketJumper != null && params.weapon == RocketJumper)
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

    function OnDamageDealt(victim, params)
    {

		if (Shotgun != null)
			lastHitWasShotgun = params.weapon == Shotgun

		lastHitWasAirStrike = player != victim && params.weapon == Airstrike;
        if (lastHitWasAirStrike)
        {
            RunWithDelay2(this, 0.05, function ()
            {
                local heads = GetPropInt(player, "m_Shared.m_iDecapitations");
                if (player.IsAlive())
                {
                    local reload_speed_bonus = player.GetCustomAttribute("reload time decreased", 1.0)
                    if (heads < 5)
                    {
                        player.AddCustomAttribute("reload time decreased", reload_speed_bonus - 0.05, -1)
                    }
                }
            })
        }

        if (params.weapon == RocketJumper && player != victim)
        {
            printdev("Rocket Jumper hit someone.")
            local your_center = player.GetCenter();
            foreach (boss in GetAliveBossPlayers())
            {
                local distanceToBoss = (boss.GetCenter() - your_center).Length()
                if (distanceToBoss >= 180)
                {
                    params.damage = 0.0;
                    break;
                }
            }
        }
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (lastHitWasAirStrike)
        {
            damageAccumulated += params.damageamount;
            while (damageAccumulated >= 180)
            {
                AddPropInt(player, "m_Shared.m_iDecapitations", 1);
                damageAccumulated -= 180;
            }
        }

		if (lastHitWasShotgun)
		{
			local damage_dealt = params.damageamount
			local overheal_limit = player.GetMaxHealth() * 1.5
			player.SetHealth(clampCeiling(overheal_limit, player.GetHealth() + (damage_dealt / 2)))
		}
    }

	// Delfite: This function is responsible for fixing TF_COND_DEFENSEBUFF from not applying its damage resistance to Hale's abilities.
    // Primarily intended as a fix for the Battalion's Backup, but fixes the condition as a whole.
    function OnDamageTaken(attacker, params)
    {
        if (IsValidBoss(attacker))
        {
            if (params.damage_type & DMG_CLUB) //Ignore Saxton's normal hits, the game already handles the resistance. - Senni
            {
                EmitSoundOnClient("Player.ResistanceMedium", player)
                return;
            }

            if (player.InCond(TF_COND_DEFENSEBUFF))
            {
                params.damage *= 0.65
                // Delfite: Play a sound to the player so they know the banner resisted the damage.
                EmitSoundOnClient("Player.ResistanceMedium", player)
                //printdev("damage resisted on merc") //Debug to make sure resistance is applied - Senni
            }
        }
    }

	// Delfite: This function is responsible for adding Rage to every player's currently equipped banner (if any).
    function RageThink()
    {
        local rage = player.GetRageMeter();

        if (rage < 100 && !player.IsRageDraining()) // Delfite: Stop charging the banner at 100% and while it's draining.
        {
            player.SetRageMeter(clampCeiling(100, rage + 0.02525252525252525252525252525253)); //Adding 0.025 to the meter to get 60 seconds - Senni
            //printdev(rage) //Debug
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

        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("movement speed bonus");
        }
    }
});