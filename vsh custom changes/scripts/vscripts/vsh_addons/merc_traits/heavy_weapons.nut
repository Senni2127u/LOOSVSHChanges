// Script by: Senni, Delfite, Bradasparky
// This script handles everything to do with Heavy's weapons.
// Requires modification of `weapons.nut` in order to function.


const BRASS_BEAST_OVERHEAL_MULT = 0.5

PrecacheScriptSound("Player.ResistanceMedium")
PrecacheScriptSound("Player.ResistanceHeavy")

characterTraitsClasses.push(class extends CharacterTrait
{
	active_weapon = null;
	weapon_primary = null;
	weapon_secondary = null;
	weapon_melee = null;

	// Primary handles.
	BrassBeast = null;
    Natascha = null;

	// Secondary handles.
	Shotgun = null;
	Steak = null;
	DalokohsBar = null;
	SecondBanana = null;

	// Melee handles.


	// medkit_new = null;
	// dalokohs_despawn_timer = Time();
	// dalokohsDespawnTimerActive = false;

	accuracy_bonus = 1;
	weapon_melee_fire_rate = 1;

	lastHitWasShotgun = false;
	eatingSpeedBuffed = false;
	dalokohsNullifierActive = false;
	steakBuffsActive = false;
    uberPenaltyApplied = false;
    primaryIsSpunUp = false;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS
	}

	function OnApply()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
		weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

		// Primary definitions.
		if (WeaponIs(weapon_primary, "minigun"))
        {
            // weapon_primary.AddAttribute("damage penalty", 0.8, -1);
            weapon_primary.AddAttribute("spread penalty", 1.25, -1);
            weapon_primary.AddAttribute("fire rate bonus", 0.85, -1);
            // weapon_primary.AddAttribute("bullets per shot bonus", 1.5, -1);
            // weapon_primary.AddAttribute("aiming movespeed increased", 1.2, -1);
        }
        else if (WeaponIs(weapon_primary, "tomislav"))
        {
            // weapon_primary.AddAttribute("fire rate penalty", 1.1, -1);
            // weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1);
        }
        else if (WeaponIs(weapon_primary, "huo_long_heater"))
        {
            // weapon_primary.AddAttribute("damage penalty", 1.0, -1);
            // weapon_primary.AddAttribute("damage bonus vs burning", 1.0, -1);
            weapon_primary.AddAttribute("uses ammo while aiming", 0, -1);
        }
        else if (WeaponIs(weapon_primary, "brass_beast"))
        {
            // Delfite: Rework of the Brass Beast that trades its damage bonus for more consistent and better damage resistance.
            // Also reduces max overheal to make pocketing less effective.
            BrassBeast = weapon_primary
            BrassBeast.AddAttribute("damage bonus", 1.0, -1);
            BrassBeast.AddAttribute("patient overheal penalty", BRASS_BEAST_OVERHEAL_MULT, -1);
            BrassBeast.AddAttribute("spunup_damage_resistance", 1.0, -1);
            BrassBeast.AddAttribute("aiming movespeed decreased", 0.8, -1);
        }
        else if (WeaponIs(weapon_primary, "natascha"))
        {
            Natascha = weapon_primary
            Natascha.AddAttribute("damage penalty", 1.0, -1);
            Natascha.AddAttribute("spunup_damage_resistance", 1.0, -1);
            Natascha.AddAttribute("aiming movespeed decreased", 1.0, -1);
            Natascha.AddAttribute("slow enemy on hit", 0.15, -1);
        }

		// Secondary definitions.
		if (WeaponIs(weapon_secondary, "shotgun"))
		{
			Shotgun = weapon_secondary;
			// Shotgun.AddAttribute("damage bonus", 1.40, -1);
			Shotgun.AddAttribute("weapon spread bonus", 0.7, -1);
			Shotgun.AddAttribute("reload time decreased", 0.85, -1);
		}
		else if (WeaponIs(weapon_secondary, "family_business"))
		{
			weapon_secondary.AddAttribute("weapon spread bonus", 0.7, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
		}
		else if (WeaponIs(weapon_secondary, "panic_attack"))
		{
			weapon_secondary.AddAttribute("weapon spread bonus", 0.6, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
		}
		else if (WeaponIs(weapon_secondary, "sandvich"))
		{
			// Delfite: Small Medkits: 60 health -> 90 health
			// Delfite: Medium Medkits: 150 health -> 225 health
			weapon_secondary.AddAttribute("health from packs increased", 1.50, -1);
		}
		else if (WeaponIs(weapon_secondary, "dalokohs_bar"))
		{
			// Delfite: This attribute, "lunchbox adds maxhealth bonus", controls more than just the Dalokohs' behavior as an item,
			// but also what model it uses and what size medkit it drops (small, medium, or large?)
			// Due to this, a workaround was needed in order to maintain the last two features, but still remove the first. Said
			// workaround is further down in this script.
			DalokohsBar = weapon_secondary
			DalokohsBar.AddAttribute("lunchbox adds maxhealth bonus", 1, -1);
			DalokohsBar.AddAttribute("lunchbox healing decreased", 0.44, -1);
			DalokohsBar.AddAttribute("charge recharge rate increased", 2, -1);
			DalokohsBar.AddAttribute("max health additive bonus", 50, -1);
		}
		else if (WeaponIs(weapon_secondary, "buffalo_steak_sandvich"))
		{
			Steak = weapon_secondary
			Steak.AddAttribute("energy buff dmg taken multiplier", 1.0, -1);
		}
		else if (WeaponIs(weapon_secondary, "second_banana"))
		{
			SecondBanana = weapon_secondary
		}

		// Melee definitions.
		if (WeaponIs(weapon_melee, "fists"))
		{
			weapon_melee.AddAttribute("fire rate bonus", 0.8, -1);
		}
		else if (WeaponIs(weapon_melee, "gru"))
		{
			weapon_melee.AddAttribute("damage penalty", 0.7, -1);
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.3, -1);
			weapon_melee.AddAttribute("mod_maxhealth_drain_rate", 0, -1);
		}
		else if (WeaponIs(weapon_melee, "eviction_notice"))
		{
			weapon_melee.AddAttribute("mult_player_movespeed_active", 1.15, -1);
			// weapon_melee.AddAttribute("move speed bonus", 1.15, -1);
			// weapon_melee.AddAttribute("provide on active", 1, -1);
			weapon_melee.AddAttribute("speed_boost_on_hit", 8, -1);
			weapon_melee.AddAttribute("fire rate bonus", 0.9, -1);
			weapon_melee.AddAttribute("mod_maxhealth_drain_rate", 0, -1);
			// Delfite: Max health drain has been taken out back and blasted with a shotgun.
			// Please, do not ever use this attribute on a weapon.
			weapon_melee.AddAttribute("damage penalty", 0.5, -1);
			// Delfite: Damage penalty: 60% -> 50%
		}
		else if (WeaponIs(weapon_melee, "fists_of_steel"))
		{
			weapon_melee.AddAttribute("dmg from melee increased", 1, -1);
			// Delfite: No, Hale should not be able to 1-shot a Heavy while he has this item out.
			weapon_melee.AddAttribute("single wep holster time increased", 1.5, -1);
		}
		else if (WeaponIs(weapon_melee, "warriors_spirit"))
		{
			weapon_melee.AddAttribute("dmg taken increased", 1, -1);
			// Delfite: Again with the damage vulns on melees Valve...
			// It at least made sense on the Fists of Steel, but why this item?!
			weapon_melee.AddAttribute("single wep holster time increased", 1.5, -1);
		}
		player.Regenerate(true)
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
            // printdev(value);
        }

        // Delfite: Fixes an issue with the "patient overheal penalty" attribute where Medic gets increased ubercharge rate
        // due to the patient's overheal not technically being "full."
        if (BrassBeast != null)
        {
            local patient_health = player.GetHealth()
            local overheal_limit = player.GetMaxHealth() * 1.5 * BRASS_BEAST_OVERHEAL_MULT
            if (patient_health == overheal_limit)
            {
                if (uberPenaltyApplied)
                    return;

                player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
                uberPenaltyApplied = true
                printdev(overheal_limit)
            }
            else if (patient_health <= overheal_limit - 2)
            {
                if (!uberPenaltyApplied)
                    return;

                player.RemoveCustomAttribute("ubercharge rate bonus for healer")
                uberPenaltyApplied = false
            }
        }
    }

	function OnTickAlive(timeDelta)
	{
		// local time = Time()

		// Delfite: This block is a workaround for stopping the Dalokohs from giving its max health bonus when eaten.
		if (weapon_secondary == DalokohsBar)
			DalokohsNullifierThink()

		// Delfite: Eat the banan faster. Yup, that's it.
		if (weapon_secondary == SecondBanana)
			BananaEatingBuffThink();

		if (weapon_secondary == Steak)
		{
			SteakEatingBuffThink();
			SteakEnergyBuffThink();
		}

		// if (Dalokohs_Bar)
		// {
		// 	// Delfite: Oh, would you look at the time! It's hack-o-clock!
		// 	// This block is intended as a workaround for the fact that Valve tied the type of lunchbox to item attributes. Hooraaaaaay!
		// 	// This means that the size of medkit dropped by the lunchbox, as well as its model, will also be changed depending
		// 	// on the weapon's current attributes. In the wise words of a certain hedgehog: "That's no good!" In response to
		// 	// said hedgehog, I replied: "Fine, I'll do it myself!" So I did it myself.
		// 	local medkit = null;
		// 	// local medkit_new = null;
        //     while (medkit = FindByClassname(medkit, "item_healthkit_medium"))
		// 	{
        //         if (medkit.GetOwner() == player && medkit.GetModelName() == "models/items/plate.mdl")
        //         {
		// 			// Delfite: We only need to run this code once, so we'll validate the script scope to stop any re-runs.
		// 			medkit.ValidateScriptScope()
        //             local medkitScope = medkit.GetScriptScope();
		// 			if ("spawned" in medkitScope)
		// 				return;

		// 			medkitScope["spawned"] <- null;

		// 			medkit_new[i] = SpawnEntityFromTable("item_healthkit_small",
		// 			{
		// 				AutoMaterialize = false,
		// 				// Delfite: Do not use powerup_model! While it *will* set the model, it also causes substantial script lag whenever it triggers.
		// 				// I couldn't discern a cause for this, but for future reference: I don't recommend using this keyvalue!
		// 				// powerup_model = "models/workshop/weapons/c_models/c_chocolate/plate_chocolate.mdl",
		// 			})
		// 			// EntFireByHandle(medkit_new, "Disable", "", 0, player, player)
		// 			// EntFireByHandle(medkit_new, "Enable", "", 0.3, player, player)

		// 			// Delfite: Set the team to TEAM_INVALID so the Heavy doesn't pick up his Dalokohs as soon as it spawns.
		// 			// Delifte: Set the team back to the Heavy's after a delay so him and his teammates can pick it up.
		// 			medkit_new.SetTeam(TEAM_INVALID)
		// 			RunWithDelay2(this, 0.3, function ()
		// 			{
		// 				medkit_new.SetTeam(player.GetTeam())
		// 			})

		// 			// Delfite: Since this is a medkit, we need to override each holiday's modelIndex. Otherwise it won't look like
		// 			// the Dalokohs Bar anymore, which we don't want.
		// 			local modelIndex = GetModelIndex("models/workshop/weapons/c_models/c_chocolate/plate_chocolate.mdl")
		// 			SetPropIntArray(medkit_new, "m_nModelIndexOverrides", modelIndex, 000)
		// 			SetPropIntArray(medkit_new, "m_nModelIndexOverrides", modelIndex, 001)
		// 			SetPropIntArray(medkit_new, "m_nModelIndexOverrides", modelIndex, 002)
		// 			SetPropIntArray(medkit_new, "m_nModelIndexOverrides", modelIndex, 003)

		// 			SetPropEntity(medkit_new, "m_hOwnerEntity", player)

		// 			medkit_new.SetMoveType(Constants.EMoveType.MOVETYPE_FLYGRAVITY, Constants.EMoveCollide.MOVECOLLIDE_FLY_BOUNCE);
		// 			medkit_new.SetAbsOrigin(player.EyePosition())

		// 			local medkit_velocity = medkit.GetAbsVelocity()
		// 			medkit_new.SetAbsVelocity(medkit_velocity)

		// 			EntFireByHandle(medkit_new, "Kill", "", 30, medkit_new, medkit_new);
		// 			RunWithDelay2(this, 30.05, function ()
		// 			{
		// 				SetPropBool(medkit_new, "m_bForcePurgeFixedupStrings", true)
		// 			})

		// 			// Delfite: Remove the old medkit once everything else is done.
		// 			medkit.Kill()
		// 			printdev("Small Medkit spawned.")
        //         }
		// 	}

		// 	// if (medkit_new != null)
		// 	// {
		// 	// 	if (!dalokohsDespawnTimerActive)
		// 	// 	{
		// 	// 		dalokohs_despawn_timer = Time() + 30;
		// 	// 		dalokohsDespawnTimerActive = true;
		// 	// 	}
		// 	// 	else if (dalokohsDespawnTimerActive && dalokohs_despawn_timer == Time())
		// 	// 	{
		// 	// 		medkit_new.Kill()
		// 	// 		medkit_new = null;
		// 	// 		dalokohsDespawnTimerActive = false;
		// 	// 		printdev("Small Medkit killed.")
		// 	// 	}

		// 	// 	// if (GetPropFloat(player, "m_Shared.tfsharedlocaldata.m_flItemChargeMeter.001") == 100)
		// 	// 	// {
		// 	// 	// }
		// 	// }
		// 	// else
		// 	// {
		// 	// 	dalokohs_despawn_timer = Time()
		// 	// 	dalokohsDespawnTimerActive = false;
		// 	// }
		// 	// printdev(dalokohs_despawn_timer)
		// }
	}

	function OnDamageDealt(victim, params)
    {
		if (weapon_primary != null)
			if (player.IsCritBoosted())
            	params.damage *= 0.7;

		if (weapon_secondary == Shotgun)
			lastHitWasShotgun = params.weapon == Shotgun

		local health = player.GetHealth()
		local max_health = player.GetMaxHealth()
        if (params.damage_type & 128 && health < max_health && WeaponIs(params.weapon, "warriors_spirit"))
            player.SetHealth(clampCeiling(player.GetHealth() + 50, max_health));
		else if ((params.damage_type & 128) && WeaponIs(params.weapon, "kgb"))
            player.AddCondEx(TF_COND_CRITBOOSTED_ON_KILL, 5, null);
    }

	function OnHurtDealtEvent(victim, params)
	{
		if (lastHitWasShotgun)
		{
			local damage_dealt = params.damageamount
			local overheal_limit = player.GetMaxHealth() * 1.5
			player.SetHealth(clampCeiling(overheal_limit, player.GetHealth() + (damage_dealt / 2)))
		}
	}

	// Delfite: Failed attempt at nerfing Heavy's Minigun crit damage.
    // function OnHurtDealtEvent(victim, params)
    // {
    //     printdev(params.weaponid + " | " + weapon_primary.GetClassname())
    //     if (params.weaponid == TF_WEAPON_MINIGUN && params.bonuseffect == kBonusEffect_Crit)
    //     {
    //         params.damage *= 0.7;
    //         printdev("Damage reduced.")
    //     }
    // }

    function OnDamageTaken(attacker, params)
    {
        // printdev("m_iWeaponState: " + GetPropInt(weapon_primary, "m_iWeaponState") + " | " + "primaryIsSpunUp: " + primaryIsSpunUp)
        if (BrassBeast)
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

	function DalokohsNullifierThink()
	{
		if (DalokohsBar == active_weapon && player.InCond(TF_COND_TAUNTING))
		{
			if (dalokohsNullifierActive)
				return;

			weapon_secondary.AddAttribute("lunchbox adds maxhealth bonus", 0, -1);

			// Delfite: Recharge the Dalokohs if we're at full health or have overheal.
			if (player.GetHealth() >= player.GetMaxHealth())
			{
				// Delfite: Cannot set to 100. Doing so causes the item to have no ammo until you pick up another medkit.
				SetPropFloat(player, "m_Shared.tfsharedlocaldata.m_flItemChargeMeter.001", 99.99)
			}

			dalokohsNullifierActive = true;
		}
		else
		{
			if (!dalokohsNullifierActive)
				return;

			weapon_secondary.AddAttribute("lunchbox adds maxhealth bonus", 1, -1);
			dalokohsNullifierActive = false;
		}

		// if (player.GetCustomAttribute("hidden maxhealth non buffed", 0) == 0)
		// 	return;

		// player.RemoveCustomAttribute("hidden maxhealth non buffed")
	}

	function SteakEatingBuffThink()
	{
		if (Steak == active_weapon && player.InCond(TF_COND_TAUNTING))
		{
			if (eatingSpeedBuffed)
				return;

			player.AddCustomAttribute("gesture speed increase", 1.375, -1);
			player.AddCustomAttribute("voice pitch scale", 1.375, -1);
			eatingSpeedBuffed = true;
		}
		else
		{
			if (!eatingSpeedBuffed)
				return;

			RunWithDelay2(this, 1.5, function ()
			{
				player.RemoveCustomAttribute("gesture speed increase")
				player.RemoveCustomAttribute("voice pitch scale")
			})
			eatingSpeedBuffed = false;
		}
	}

	function SteakEnergyBuffThink()
	{
		if (player.InCond(TF_COND_ENERGY_BUFF))
		{
			// Delfite: Valve seems to have hard-coded Heavy's movement speed while TF_COND_ENERGY_BUFF is applied to him.
			// Removing the condition seems to fix this. And yes, I mean "fix", because it's ridiculous that the Steak
			// even does that in the first place.
			player.RemoveCond(TF_COND_ENERGY_BUFF)
			player.RemoveCond(TF_COND_CANNOT_SWITCH_FROM_MELEE)
			// Delfite: I'm adding Sniper's rage buff as a way of tracking when the Steak's effects should be active.
			// It's better than tracking the status of TF_COND_OFFENSEBUFF since it can be active on the Heavy
			// under different circumstances. The rage condition, however, will never be active outside of scenarios like this one.
			player.AddCondEx(TF_COND_SNIPERCHARGE_RAGE_BUFF, 12, null)
		}
		else if (player.InCond(TF_COND_SNIPERCHARGE_RAGE_BUFF))
		{
			if (steakBuffsActive)
				return;

			steakBuffsActive = true;
			player.AddCondEx(TF_COND_OFFENSEBUFF, 15, null)

			accuracy_bonus = player.GetCustomAttribute("weapon spread bonus", 1.0)
			player.AddCustomAttribute("weapon spread bonus", accuracy_bonus - 0.2, -1)
			weapon_melee_fire_rate = weapon_melee.GetAttribute("fire rate bonus", 1.0)
			weapon_melee.AddAttribute("fire rate bonus", weapon_melee_fire_rate - 0.15, -1);
		}
		else
		{
			if (!steakBuffsActive)
				return;

			steakBuffsActive = false;

			player.RemoveCustomAttribute("weapon spread bonus")
			weapon_melee.AddAttribute("fire rate bonus", weapon_melee_fire_rate, -1);
		}
	}

	function BananaEatingBuffThink()
	{
		if (SecondBanana == active_weapon && player.InCond(TF_COND_TAUNTING))
		{
			if (eatingSpeedBuffed)
				return;

			weapon_secondary.AddAttribute("gesture speed increase", 1.5, -1);
			eatingSpeedBuffed = true;
		}
		else
		{
			if (!eatingSpeedBuffed)
				return;

			RunWithDelay2(this, 1.5, function ()
			{
				weapon_secondary.RemoveAttribute("gesture speed increase")
			})
			eatingSpeedBuffed = false;
		}
	}

	function OnDiscard()
	{
		if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_melee.RemoveAttribute("gesture speed increase");
            weapon_melee.RemoveAttribute("voice pitch scale");
        }

		if (weapon_melee && weapon_melee.IsValid())
		{
			weapon_melee.RemoveAttribute("fire rate bonus");
			weapon_melee.RemoveAttribute("damage penalty")
		}
	}
});