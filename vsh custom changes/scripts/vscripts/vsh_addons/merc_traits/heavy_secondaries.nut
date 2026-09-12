// Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)
// This script controls everything to do with Heavy's secondaries. Lunchbox items included.


characterTraitsClasses.push(class extends CharacterTrait
{
	// weapon_primary = null;
	// weapon_secondary = null;
	// weapon_melee = null;

	// medkit_new = null;

	Steak = null;
	Dalokohs_Bar = null;
	Second_Banana = null;

	// dalokohs_despawn_timer = Time();
	accuracy_bonus = 1;
	weapon_melee_fire_rate = 1;

	eatingSpeedBuffed = false;
	dalokohsNullifierActive = false;
	// dalokohsDespawnTimerActive = false;
	steakBuffsActive = false;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS
	}

	function OnApply()
	{
		// weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		// weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
		// weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

		if (WeaponIs(weapon_secondary, "shotgun"))
		{
			weapon_secondary.AddAttribute("damage bonus", 1.40, -1);
			weapon_secondary.AddAttribute("weapon spread bonus", 0.7, -1);
			weapon_secondary.AddAttribute("reload time decreased", 0.85, -1);
		}
		if (WeaponIs(weapon_secondary, "family_business"))
		{
			weapon_secondary.AddAttribute("weapon spread bonus", 0.7, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
		}
		if (WeaponIs(weapon_secondary, "panic_attack"))
		{
			weapon_secondary.AddAttribute("weapon spread bonus", 0.6, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
		}
		if (WeaponIs(weapon_secondary, "sandvich"))
		{
			// Delfite: Small Medkits: 60 health -> 90 health
			// Delfite: Medium Medkits: 150 health -> 225 health
			weapon_secondary.AddAttribute("health from packs increased", 1.50, -1);
		}
		if (WeaponIs(weapon_secondary, "dalokohs_bar"))
		{
			// Delfite: This attribute, "lunchbox adds maxhealth bonus", controls more than just the Dalokohs' behavior as an item,
			// but also what model it uses and what size medkit it drops (small, medium, or large?)
			// Due to this, a workaround was needed in order to maintain the last two features, but still remove the first. Said
			// workaround is further down in this script.
			weapon_secondary.AddAttribute("lunchbox adds maxhealth bonus", 1, -1);
			weapon_secondary.AddAttribute("lunchbox healing decreased", 0.44, -1);
			weapon_secondary.AddAttribute("charge recharge rate increased", 2, -1);
			weapon_secondary.AddAttribute("max health additive bonus", 50, -1);
			Dalokohs_Bar = weapon_secondary
		}
		if (WeaponIs(weapon_secondary, "buffalo_steak_sandvich"))
		{
			weapon_secondary.AddAttribute("energy buff dmg taken multiplier", 1.0, -1);
			Steak = weapon_secondary
		}
		if (WeaponIs(weapon_secondary, "second_banana"))
		{
			Second_Banana = weapon_secondary
		}
		player.Regenerate(true)
	}

	function OnFrameTickAlive()
	{
		local active_weapon = player.GetActiveWeapon()
		// local time = Time()

		// Delfite: This block is a workaround for stopping the Dalokohs from giving its max health bonus when eaten.
		if (Dalokohs_Bar)
		{
			DalokohsNullifierThink()
		}

		// Delfite: Eat the banan faster. Yup, that's it.
		if (Second_Banana)
		{
			BananaEatingBuffThink();
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
		// 			printl("Small Medkit spawned.")
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
		// 	// 		printl("Small Medkit killed.")
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
		// 	// printl(dalokohs_despawn_timer)
		// }

		if (Steak)
		{
			SteakEatingBuffThink();
			SteakEnergyBuffThink();
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
        }
    }

	function DalokohsNullifierThink()
	{
		if (Dalokohs_Bar == active_weapon && player.InCond(TF_COND_TAUNTING))
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
		if (Second_Banana == active_weapon && player.InCond(TF_COND_TAUNTING))
		{
			if (eatingSpeedBuffed)
				return;

			weapon_secondary.AddAttribute("gesture speed increase", 1.5, -1);
			weapon_secondary.AddAttribute("voice pitch scale", 1.5, -1);
			eatingSpeedBuffed = true;
		}
		else
		{
			if (!eatingSpeedBuffed)
				return;

			RunWithDelay2(this, 1.5, function ()
			{
				weapon_secondary.RemoveAttribute("gesture speed increase")
				weapon_secondary.RemoveAttribute("voice pitch scale")
			})
			eatingSpeedBuffed = false;
		}
	}
});
