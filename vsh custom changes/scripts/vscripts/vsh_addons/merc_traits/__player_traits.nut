// Script by: Delfite.
// With assistance from: Bradasparky.
// The Master Switch!
// This script controls everything to do with the mercs themselves, such as them having knockback resistance while invulnerable, or having
// altered base stats. You can think of this script as a file that covers stuff not normally seen in the weapon scripts.


const TAUNT_BASE_WEAPON = 0

::engie_scene_array <- [
	"scenes/player/engineer/low/taunt01_vocal01.vcd",
	"scenes/player/engineer/low/taunt01_vocal02.vcd",
	"scenes/player/engineer/low/taunt01_vocal03.vcd",
	"scenes/player/engineer/low/taunt01_vocal04.vcd"
]

// Delfite: Failed attempt at distinguishing between different tauntkills.
// ::taunt_damage_array <- [
// 	TF_DMG_CUSTOM_TAUNTATK_ALLCLASS_GUITAR_RIFF,
// 	TF_DMG_CUSTOM_TAUNTATK_ARMAGEDDON,
// 	TF_DMG_CUSTOM_TAUNTATK_ARROW_STAB,
// 	TF_DMG_CUSTOM_TAUNTATK_BARBARIAN_SWING,
// 	TF_DMG_CUSTOM_TAUNTATK_ENGINEER_ARM_KILL,
// 	TF_DMG_CUSTOM_TAUNTATK_ENGINEER_GUITAR_SMASH,
// 	TF_DMG_CUSTOM_TAUNTATK_FENCING,
// 	TF_DMG_CUSTOM_TAUNTATK_GASBLAST,
// 	TF_DMG_CUSTOM_TAUNTATK_GRAND_SLAM,
// 	TF_DMG_CUSTOM_TAUNTATK_GRENADE,
// 	TF_DMG_CUSTOM_TAUNTATK_HADOUKEN,
// 	TF_DMG_CUSTOM_TAUNTATK_HIGH_NOON,
// 	TF_DMG_CUSTOM_TAUNTATK_UBERSLICE
// ]


PrecacheScriptSound("Player.ResistanceMedium")
PrecacheArbitrarySound("vsh_sfx.gardened")
PrecacheSound("items/powerup_pickup_knockout.wav")
PrecacheSound("weapons/buffed_on.wav")
PrecacheSound("weapons/buffed_off.wav")
PrecacheSound("ui/buttonclick.wav")
PrecacheSound("ui/buttonclickrelease.wav")


AddListener("player_say", 0, function (player, text, params)
{
	foreach (player in GetValidClients())
	{
		EmitSoundEx(
		{
			sound_name = "ui/buttonclickrelease.wav"
			entity = player
			filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
			volume = 1.0
			channel = 6
			pitch = 90
		})
		EmitSoundEx(
		{
			sound_name = "ui/buttonclickrelease.wav"
			entity = player
			filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
			volume = 0.2
			channel = 6
			pitch = 90
		})
		EmitSoundEx(
		{
			sound_name = "ui/buttonclick.wav"
			entity = player
			filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
			volume = 1.0
			channel = 6
			pitch = 90
			flags = 16
			sound_time = Time() + 0.5
		})
		EmitSoundEx(
		{
			sound_name = "ui/buttonclick.wav"
			entity = player
			filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
			volume = 0.2
			channel = 6
			pitch = 90
			flags = 16
			sound_time = Time() + 0.5
		})
	}
})

AddListener("spawn", 1, function (player, params)
{
	// Delfite: This is a list of variables that can be assigned per-player, and used across other scripts.
	// Initially intended as a means of stopping the mercs' wallclimb voicelines from playing for 10 seconds
	// after they land a tauntkill on Hale, but it can do a lot more than that if you use your imagination.

	// Things to keep in mind about this system:
	// 1. Variables do not reset automatically. You MUST have a reset mechanism somewhere in order for them
	// to return to their default values, or else their data will carry over into the next round. In the case of
	// `allowWallclimbVOs`, it resets to `true` when the player respawns, or when its usual code finishes running.
	// 2. You don't need to worry about deleting the variables manually if a player disconnects. Player scopes are
	// automatically deleted by the game 1 frame after a disconnect happens.
	// 3. Scopes do not persist between map changes. That requires writing to an external file, such as a .txt.
	// 4. In order to retrieve the player's scope for use in other scripts, use `local player_scope = player.GetScriptScope()`
	// before accessing the variable(s) you need.

	player.ValidateScriptScope()
	local player_scope = player.GetScriptScope();

	player_scope.allowWallclimbVOs <- true;
	player_scope.eyelanderCritsEnabled <- false;
	// if (!("allowWallclimbVOs" in player_scope))
	// 	player_scope["allowWallclimbVOs"] <- true;
	// player_scope["allowWallclimbVOs"] = true;
})

AddListener("tick_only_valid", 1, function (timeDelta)
{
    local projectile = null;
    while (projectile = FindByClassname(projectile, "tf_projectile*"))
    {
		if (projectile.GetClassname() == "tf_projectile_sentryrocket")
			break;

		projectile.ValidateScriptScope()
		local projectile_scope = projectile.GetScriptScope();
		if (!("CHECKED" in projectile_scope))
		{
			local player = GetPropEntity(projectile, "m_hOwnerEntity")
			local weapon = GetPropEntity(projectile, "m_hLauncher")
			local thrower = GetPropEntity(projectile, "m_hThrower")
			// Delfite: Throwables don't use `m_hOwnerEntity`. Not really sure why, but okay Valve.
			if (player == null)
				player = thrower
			// printdev(weapon + " | " + player)
			if (player != null) // projectile is a class object, aka an "instance".
			{
				projectile_scope["CHECKED"] <- null;

				if (WeaponIs(weapon, "direct_hit"))
					projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3.5)
				else if (WeaponIs(weapon, "righteous_bison"))
					projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3)
				else if (WeaponIs(weapon, "flaregun"))
					projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 1.5)
				else if (WeaponIs(weapon, "detonator"))
					projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 1.25)
				else if (WeaponIs(weapon, "pomson_6000"))
					projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3)
				// Delfite: BEWARE OF JANK! While this code *does* have the intended effect of making syringes more consistent to hit by making
				// them faster, it comes at the downside of desyncing the syringes visually from their actual position since they're client-sided.
				// I do not recommend enabling this code. Instead, go support this Github issue: https://github.com/ValveSoftware/Source-1-Games/issues/8253
				// else if (WeaponIs(weapon, "any_syringegun"))
				// 	projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3)
				else if (WeaponIs(weapon, "flying_guillotine"))
					projectile.SetPhysVelocity(GetPhysVelocity(projectile) * 2)
				else if (WeaponIs(weapon, "gas_passer"))
					projectile.SetPhysVelocity(GetPhysVelocity(projectile) * 2)
				else if (WeaponIs(weapon, "jarate"))
					projectile.SetPhysVelocity(GetPhysVelocity(projectile) * 1.5)

				// if (thrower == null)
				// 	printdev(projectile + " | " + projectile.GetAbsVelocity())
				// else
				// 	printdev(projectile + " | " + GetPhysVelocity(projectile))
			}
		}
        break;
    }
});

AddListener("tick_frame", 1, function ()
{
	// Delfite: This code prevents the Thriller taunt from playing. Works on Hale and the mercs.
	for (local scene; scene = Entities.FindByClassname(scene, "instanced_scripted_scene");)
	{
		local owner = GetPropEntity(scene, "m_hOwner")
		if (owner == null || !owner.IsPlayer())
			continue;

		local name = GetPropString(scene, "m_szInstanceFilename")
		// printdev("Active scene: " + name)
		local thriller_name = owner.GetPlayerClass() == TF_CLASS_MEDIC ? "taunt07" : "taunt06"
		if (name.find(thriller_name) == null)
			continue;

		scene.Kill()
		owner.RemoveCond(TF_COND_TAUNTING)
		owner.Taunt(TAUNT_BASE_WEAPON, 0)
		break;
	}
})

characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;
	weapon_melee = null;

	you = null;

	tauntStartTimestampSet = false;
	taunt_start_timestamp = -1;
	taunt_end_timestamp = -1;
	time_spent_taunting = -1;

	friendly_penalty_countdown = 990;
	countdownSet = true;
	antiFriendlyMessageSent = false;

	tauntSearchActive = false;
	taunt_search_count = 0;

	buffOnSFXPlayed = false;
	buffOffSFXPlayed = false;

	launch = false;
	Invulnerable = false;
	boss_eye_angles = null;

	lastHitWasTauntkill = false;

	player_class = 0;

	function OnApply()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
		you = player;

		RunWithDelay2(this, 0, OnApply0Delay);
		RunWithDelay2(this, 0.05, OnApply05Delay);
		RunWithDelay2(this, 0.1, OnApply1Delay);
	}

	// Delfite: Not sure why, but I needed to copy over OnApply0Delay from `boss.nut` to get the player attributes working.
	// Might have something to do with player attributes getting cleared automatically on setup start.
	function OnApply0Delay()
	{
		player_class = player.GetPlayerClass()
		switch (player_class)
		{
			case TF_CLASS_SCOUT:
			break;

			case TF_CLASS_SOLDIER:
				player.AddCustomAttribute("move speed bonus", 1.25, -1);
			break;

			case TF_CLASS_PYRO:
				player.AddCustomAttribute("max health additive bonus", 25, -1);
				// printdev("Pyro attributes applied.")
			break;

			case TF_CLASS_DEMOMAN:
				player.AddCustomAttribute("max health additive bonus", 25, -1);
        		// Delfite: Give demo 25 more health so he doesn't die in 1 hit. Boots should not be a hard requirement for preventing death.
				player.AddCustomAttribute("move speed bonus", 1.072, -1)
			break;

			case TF_CLASS_HEAVY:
				player.AddCustomAttribute("move speed bonus", 1.3045, -1);
				// printdev("Heavy attributes applied.")
			break;

			case TF_CLASS_ENGINEER:
				player.AddCustomAttribute("max health additive bonus", 25, -1);
				player.AddCustomAttribute("move speed bonus", 1.15, -1);
				player.AddCustomAttribute("engineer teleporter build rate multiplier", 3.0, -1);
				player.AddCustomAttribute("rocket jump damage reduction", 0.1, -1); // 90% resistance to the Engie's own sentry rockets.
				player.AddCustomAttribute("maxammo metal increased", 1.5, -1); // Metal reserve: 200 -> 300
				player.AddCustomAttribute("bidirectional teleport", 1, -1);
				player.AddCustomAttribute("mod teleporter cost", 0.5, -1);
				// printdev("Engineer attributes applied.")
			break;

			case TF_CLASS_MEDIC:
				player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1);
				// printdev("Medic attributes applied.")
			break;

			case TF_CLASS_SNIPER:
				player.AddCustomAttribute("max health additive bonus", 25, -1);
				player.AddCustomAttribute("move speed bonus", 1.15, -1);
				// printdev("Sniper attributes applied.")
			break;

			case TF_CLASS_SPY:
				player.AddCustomAttribute("move speed bonus", 1.2, -1);
				player.AddCustomAttribute("NoCloakWhenCloaked", 1, -1);
				// printdev("Spy attributes applied.")
			break;

			default:
			break;
		}

	}

	function OnApply05Delay()
	{
		// Delfite: Mainly used for giving us ammo after all of our stats are applied.
		player.Regenerate(true)
	}

	function OnApply1Delay()
	{
		// Delfite: Set the player's health after AddCustomAttribute runs so the player doesn't start with overheal.
		player.SetHealth(player.GetMaxHealth())
	}

	// function OnDamageDealt(victim, params)
	// {
	// 	foreach (boss in GetAliveBossPlayers())
	// 	{
	// 		printdev(boss.EyeAngles())
	// 		break;
	// 	}
	// }

	function OnTickAlive(timeDelta)
	{
		if (!roundIsOver || !LastMannStandingActive)
			AntiFriendlySlowThink()
	}

	function OnFrameTickAlive()
	{
		if (player.InCond(TF_COND_SELECTED_TO_TELEPORT))
			player.AddCondEx(TF_COND_INVULNERABLE, 1.0, null)

		// if (player.GetPlayerSteamID() != DELFITE)
		// 	return;

		if (!roundIsOver || !LastMannStandingActive)
		{
			AntiFriendlyThink()
			BannerSFXControl()
		}

		// Delfite: Performing this check every frame so there's no delay between when the taunts switch.
		if (player.IsTaunting())
		{
			NoThrillerThink()
			// EngiePanicAttackTauntSwap()
		}

		// Delfite: Debug function. Primarily used to display the duration of a non-looping taunt.
		// TauntDurationTracker()
	}

	function OnDamageDealt(victim, params)
	{
		// printdev(params.inflictor.GetClassname())
		if (player.IsTaunting() && params.inflictor.GetClassname() != ("obj_sentrygun" || "tf_proj*"))
		{
			lastHitWasTauntkill = true;
			// Delfite: Special case for the Eyelander that maxes out Demo's headcount if he lands the tauntkill.
			// I doubt this will *ever* happen, but when it *does* happen, I hope it'll be that one extra
			// detail that makes the gamemode feel just that little bit more special. And polished, of course.
			local weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE)
			local Eyelander = null;
			if (WeaponIs(weapon_melee, "eyelander"))
				Eyelander = weapon_melee;
			if (player_class == TF_CLASS_DEMOMAN && params.damage_type & DMG_CLUB && params.weapon == Eyelander)
			{
				RunWithDelay2(this, 0.05, function ()
				{
					local heads = GetPropInt(player, "m_Shared.m_iDecapitations")
					// if (heads >= 20)
					// 	return;

					SetPropInt(player, "m_Shared.m_iDecapitations", heads + 3)
					player.AddCustomAttribute("move speed bonus", 1.24, -1)
					Eyelander.AddAttribute("damage penalty", 1.0, -1)
					Eyelander.AddAttribute("damage bonus", 2.04, -1)
				})
			}

			if (player_class == TF_CLASS_ENGINEER)
				SetPropInt(player, "m_Shared.m_iRevengeCrits", 35);

			if (player.IsCritBoosted())
			{
				// for (local i; i < taunt_damage_array.len(); i++)
				// {
				// 	lastHitWasTauntkill = params.damage_type & taunt_damage_array[i]
				// }

				params.damage *= 1.2;
				params.damage_type = params.damage_type | DMG_ACID;
			}
		}
		else
			lastHitWasTauntkill = false;

		// Delfite: This code aims to fix this issue: https://github.com/ValveSoftware/Source-1-Games/issues/8432
		// Need a BFB Scout to test this with.
		local healers = GetPropInt(player, "m_Shared.m_nNumHealers")
		if (healers > 0)
		{
			foreach (player in GetAliveMercs())
			{
				if (player.GetPlayerClass() == TF_CLASS_MEDIC && player.GetHealTarget() == you)
				{
					player.AddCustomAttribute("custom desc attr", 1, 0.05)
					// printdev("Medic stats updated.")
				}
			}
		}
	}

	function OnHurtDealtEvent(victim, params)
	{
		if (lastHitWasTauntkill)
		{
			if (params.damageamount >= 500)
			{
				HaleStunBreakout()
				// Delfite: Credit whoever landed the tauntkill.
				local taunter_name = GetPlayerNameFromParams(player)
				ClientPrint(null, 3, "\x0728FF46[VSH] \x07F2AC0A" + taunter_name + "\x07F5E7DE landed a tauntkill on Hale!");

				local player_scope = player.GetScriptScope()
				player_scope.allowWallclimbVOs = false;
				// printdev("allowWallclimbVOs: " + player_scope.allowWallclimbVOs)
				RunWithDelay2(this, 10.0, function ()
				{
					player_scope.allowWallclimbVOs = true;
					// printdev("allowWallclimbVOs: " + player_scope.allowWallclimbVOs)
				})

				EmitSoundOn("vsh_sfx.gardened", player)
				RunWithDelay2(this, 1.5, function ()
				{
					if (!player.IsAlive())
						return;

					switch (player_class)
					{
						case TF_CLASS_SCOUT:
							EmitSoundOn("Scout.LaughLong0" + RandomInt(1, 2), player)
						break;

						case TF_CLASS_SOLDIER:
							EmitSoundOn("Soldier.LaughLong0" + RandomInt(1, 3), player)
						break;

						case TF_CLASS_PYRO:
							EmitSoundOn("Pyro.LaughLong01", player)
						break;

						case TF_CLASS_DEMOMAN:
							EmitSoundOn("Demoman.LaughLong0" + RandomInt(1, 2), player)
						break;

						case TF_CLASS_HEAVY:
							EmitSoundOn("Heavy.LaughLong0" + RandomInt(1, 2), player)
						break;

						case TF_CLASS_ENGINEER:
							EmitSoundOn("Engineer.LaughLong0" + RandomInt(1, 2), player)
						break;

						case TF_CLASS_MEDIC:
							EmitSoundOn("Medic.LaughLong0" + RandomInt(1, 2), player)
						break;

						case TF_CLASS_SNIPER:
							EmitSoundOn("Sniper.LaughLong0" + RandomInt(1, 2), player)
						break;

						case TF_CLASS_SPY:
							EmitSoundOn("Spy.LaughLong01", player)
						break;

						default:
						break;
					}
				})
			}
		}
	}

	function OnDamageTaken(attacker, params)
    {
        launch = IsValidBoss(attacker);
		Invulnerable = player.IsInvulnerable()
		// printdev("Damage taken.")
		if (!Invulnerable)
		{
			if (player_class == TF_CLASS_MEDIC)
				params.damage *= 0.7;
		}
		// else
		if (launch)
			params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;

		// Delfite: This function is responsible for fixing TF_COND_DEFENSEBUFF from not applying its damage resistance to Hale's abilities.
        // Primarily intended as a fix for the Battalion's Backup, but fixes the condition as a whole.
        if (IsValidBoss(attacker) && player.InCond(TF_COND_DEFENSEBUFF))
        {
            // Delfite: Don't reduce the damage of Hale's normal melees here. The game already calculates that for us,
            // albeit with some minor deviance. Just play a sound so the player knows the resistance did its job, or at least tried to.
            if (params.damage_type & DMG_CLUB)
			{
				EmitSoundOnClient("Player.ResistanceMedium", player)
				EmitSoundOnClient("Player.ResistanceMedium", player)
			}
            else
            {
                params.damage *= 0.65
                // Delfite: Play a sound to the player so they know the banner resisted the damage.
                EmitSoundOnClient("Player.ResistanceMedium", player)
                EmitSoundOnClient("Player.ResistanceMedium", player)
                // printdev("damage resisted on merc") //Debug to make sure resistance is applied - Senni
            }
        }

		// Delfite: This block increases the player's melee range whenever they get hit by Saxton Punch!, then sets
		// the melee range back to normal after a few seconds. Originally just meant for Spy, but figured it would be
		// a nice Quality-of-life change for the other classes without just giving them straight up fall immunity.
		if (params.inflictor == custom_dmg_saxton_punch && player.IsAlive())
		{
			local melee_range_mult = weapon_melee.GetAttribute("melee range multiplier", 1.0)
			if (player_class != TF_CLASS_SPY)
				weapon_melee.AddAttribute("melee range multiplier", melee_range_mult + 0.4, -1)
			else
				weapon_melee.AddAttribute("melee range multiplier", melee_range_mult + 2.0, -1)

			player.AddCustomAttribute("custom desc attr", 1, 0.05) // Delfite: Used to update the weapon's current attributes.
			RunWithDelay2(this, 5.0, function ()
			{
				weapon_melee.AddAttribute("melee range multiplier", melee_range_mult, -1)
				player.AddCustomAttribute("custom desc attr", 1, 0.05)
			})
		}
    }

	function OnDamageTakenPost(attacker, params)
    {
        if (!launch)
            return;

		local deltaVector = player.GetOrigin() - attacker.GetOrigin();
		deltaVector.Norm();
		if (Invulnerable)
		{
			// deltaVector.z = 0.0;
			if (player_class != TF_CLASS_HEAVYWEAPONS)
			{
				// printdev("Invulnerable, but not a Heavy. Knockback halved.")
				player.Yeet(deltaVector * 400 + Vector(0, 0, 225));
			}
			else
			{
				// printdev("A Heavy took damage while invulnerable.")
				if (GetPropInt(weapon_primary, "m_iWeaponState") > 0)
				{
					// printdev("They're spun up. Knockback halved.")
					player.Yeet(deltaVector * 400 + Vector(0, 0, 225));
				}
				else
				{
					// printdev("They're not spun up. Knockback unchanged.")
					// Delfite: 800 used to be 600. Increasing so escaping is a bit easier.
                    // Might reduce depending on playtest results.
					player.Yeet(deltaVector * 800 + Vector(0, 0, 450));
				}
			}
        }
		else
		{
			// printdev("Someone took damage while vulnerable. Knockback unchanged.")
			player.Yeet(deltaVector * 800.0 + Vector(0, 0, 450))
		}
    }

	// Delfite: This function prevents the "Thriller" taunt from playing during Scream Fortress.
	// This code is an example taken from the Valve Developer Wiki.
	function NoThrillerThink()
	{

	}

	// Delfite: This function keeps track of how long the player has been taunting for, up to a maximum of 15 seconds.
	// Works in tandom with AntiFriendlySlowThink() to penalize players who stay in looping taunts for too long.
	function AntiFriendlyThink()
	{
		// printdev("Countdown: " + friendly_penalty_countdown)

		if (player.IsTaunting())
		{
			countdownSet = false;
			if (friendly_penalty_countdown > 0)
				friendly_penalty_countdown--

			if (friendly_penalty_countdown < 0)
				friendly_penalty_countdown = 0
		}
		else
		{
			// Delfite: 66 ticks * 15 seconds = 990 ticks
			if (countdownSet)
				return;

			countdownSet = true;
			friendly_penalty_countdown = 990;
		}
	}

	// Delfite: This function is responsible for penalizing players who remain in looping taunts for too long.
	// Should the player taunt continuously for 15 seconds straight, a sound will play to notify Hale of the player's location,
	// with said player being Marked-for-death until 10 seconds after they exit their taunt.
	function AntiFriendlySlowThink()
	{
		if (player.IsTaunting())
		{
			if (friendly_penalty_countdown == 0)
			{
				player.AddCondEx(TF_COND_MARKEDFORDEATH_SILENT, 10, null)

				if (antiFriendlyMessageSent)
					return;

				antiFriendlyMessageSent = true;
				// EmitSoundOn("items/powerup_pickup_knockout.wav", player)
				EmitSoundEx(
				{
					sound_name = "items/powerup_pickup_knockout.wav"
					entity = player
					filter_type = RECIPIENT_FILTER_GLOBAL
					volume = 1.0
					channel = 0
					sound_level = 150
				})
				ClientPrint(player, 3, "\x07C9C5B1[VSH] \x07C8140FAttention! Non-participation in VSH is not allowed! You will be Marked-for-death and revealed until you exit your taunt.");
				SetPropBool(player, "m_bGlowEnabled", true);
			}
		}
		else
		{
			if (!antiFriendlyMessageSent)
				return;

			antiFriendlyMessageSent = false;

			if (LastMannStandingActive)
				return;

			RunWithDelay2(this, 10, function ()
			{
				if (player.IsTaunting())
					return;

				SetPropBool(player, "m_bGlowEnabled", false);
			})
		}
	}

	function BannerSFXControl()
	{
		if (player.InCond(TF_COND_OFFENSEBUFF) || player.InCond(TF_COND_DEFENSEBUFF))
		{
			if (buffOnSFXPlayed)
				return;

			buffOnSFXPlayed = true;
			buffOffSFXPlayed = false;
			EmitSoundEx(
			{
				sound_name = "weapons/buffed_on.wav"
				entity = player
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				volume = 1.0
			})
			EmitSoundEx(
			{
				sound_name = "weapons/buffed_on.wav"
				entity = player
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				volume = 1.0
			})
			EmitSoundEx(
			{
				sound_name = "weapons/buffed_on.wav"
				entity = player
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				volume = 1.0
			})
		}

		if (!(player.InCond(TF_COND_OFFENSEBUFF) || player.InCond(TF_COND_DEFENSEBUFF)))
		{
			if (buffOffSFXPlayed)
				return;

			buffOffSFXPlayed = true;
			buffOnSFXPlayed = false;
			EmitSoundEx(
			{
				sound_name = "weapons/buffed_off.wav"
				entity = player
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				volume = 1.0
			})
			EmitSoundEx(
			{
				sound_name = "weapons/buffed_off.wav"
				entity = player
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				volume = 1.0
			})
			EmitSoundEx(
			{
				sound_name = "weapons/buffed_off.wav"
				entity = player
				filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
				volume = 1.0
			})
		}
	}

	// Delfite: Failed attempt at replacing the Panic Attack's default taunt with the Frontier Justice's taunt.
	function EngiePanicAttackTauntSwap()
	{
		// Delfite: Only Engie can have the Panic Attack as a primary, so there's no need to check for the merc.
		// if (!WeaponIs(weapon_primary, "panic_attack"))
		// 	return;
		// local current_taunt = GetPropInt(player, "m_iTauntItemDefIndex")
		// printdev("Current Taunt: " + current_taunt)
		if (tauntSearchActive)
			return;

		// if (taunt_search_count > 2)
		// 	return;

		// taunt_search_count++
		for (local scene; scene = Entities.FindByClassname(scene, "instanced_scripted_scene");)
		{
			tauntSearchActive = true;
			local owner = GetPropEntity(scene, "m_hOwner")
			if (owner != player)
				continue;

			local name = GetPropString(scene, "m_szInstanceFilename")
			if (engie_scene_array.find(name) != null)
			{
				SetPropString(scene, "m_iszSceneFile", "scenes/player/engineer/low/taunt07.vcd")
				tauntSearchActive = false;
				// taunt_search_count = 0;
			}
			// printdev("Active scene: " + name)
			// break;
		}
	}

	// Delfite: Debug function used to find out how long certain taunts are. Prints the final time - in seconds - to in-game chat.
	// Of course, looping taunts will just return however much time you were in the taunt for.
	function TauntDurationTracker()
	{
		if (player.IsTaunting())
		{
			if (tauntStartTimestampSet)
				return;

			tauntStartTimestampSet = true;
			taunt_start_timestamp = Time();
			taunt_end_timestamp = -1;
			time_spent_taunting = -1;
		}
		else
		{
			if (!tauntStartTimestampSet)
				return;

			tauntStartTimestampSet = false;
			taunt_end_timestamp = Time();
			time_spent_taunting = taunt_end_timestamp - taunt_start_timestamp;
			// Delfite: I would like to round the result of time_spent_taunting to the next hundredth of a second, but I'm not sure how.
			printdev("Taunt duration: " + time_spent_taunting + " seconds")
			local name = GetPropString(scene, "m_szInstanceFilename")
			printdev("Active scene: " + name)
		}
	}

	// function ForceTaunt(taunt_id)
	// {
	// 	player.HandleTauntCommand(0)
	// }
})