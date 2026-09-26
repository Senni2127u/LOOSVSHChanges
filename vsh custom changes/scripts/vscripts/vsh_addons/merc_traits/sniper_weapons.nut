// Script by: Delfite
// With assistance from: Bradasparky
// This script handles everything to do with Sniper's weapons.
// Requires modification of `weapons.nut` in order to function.

const HUNTSMAN_RESISTANCE_FACTOR = 0.7

// Delfite: These variables control everything to do with a magic knife that can backstab anyone when used with the TakeDamageCustom function.
// The knife is set to the index of a Saxxy, so the backstab will result in someone turning to gold if they die to it.
::knife <- CreateByClassname("tf_weapon_knife")
SetPropBool(knife, "m_AttributeManager.m_Item.m_bInitialized", true)
SetPropInt(knife, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 423)
Entities.DispatchSpawn(knife)

PrecacheScriptSound("Sniper.LaughLong01");
PrecacheScriptSound("Sniper.LaughLong02");

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;
    weapon_secondary = null;
    weapon_melee = null;
    wearable = null;

    // Primary handles

    // Secondary handles
    Razorback = null;
	Jarate = null;

    // Melee handles
    Bushwacka = null;

    destroyRazorback = false;
    razorbackBroken = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SNIPER;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        // Primary definitions.
        if (WeaponIs(weapon_primary, "any_bow"))
        {
			// Delfite: 175 HP feels more satisfying than 150. Probably because no other class has 175 HP at this point.
			weapon_primary.AddAttribute("max health additive bonus", 25, -1)
			weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1)
			weapon_primary.AddAttribute("Reload time decreased", 0.75, -1)
			// Delfite: The Huntsman's charge speed is directly tied to its fire rate. We want it to charge quickly.
			weapon_primary.AddAttribute("fire rate bonus", 0.65, -1)
			weapon_primary.AddAttribute("maxammo primary increased", 2.0, -1)
        }
        else if (WeaponIs(weapon_primary, "any_sniper_rifle"))
        {
            // Delfite: Enabling the tracers on the Sydney causes it to do normal headshot damage, which we don't want.
            if (!WeaponIs(weapon_primary, "machina") && !WeaponIs(weapon_primary, "sydney_sleeper"))
            {
                weapon_primary.AddAttribute("sniper fires tracer", 1, -1)
                weapon_primary.AddAttribute("lunchbox adds minicrits", 3, -1)
                // Delfite: For whatever reason, this attribute controls the visuals of a sniper rifle's tracer rounds.
                // A value of 3 enables the tracer rounds used by the Classic.
            }
        }
        else if (WeaponIs(weapon_primary, "sniper_rifle"))
        {
            weapon_primary.AddAttribute("SRifle charge rate increased", 1.15, -1)
            weapon_primary.AddAttribute("move speed bonus", 1.25, -1)
            weapon_primary.AddAttribute("minicrits become crits", 1, -1)
        }
        else if (WeaponIs(weapon_primary, "machina"))
        {
            weapon_primary.AddAttribute("dmg pierces resists absorbs", 1, -1)
            weapon_primary.AddAttribute("sniper only fire zoomed", 0, -1)
            weapon_primary.AddAttribute("sniper full charge damage bonus", 1.25, -1)
        }
        else if (WeaponIs(weapon_primary, "hitmans_heatmaker"))
        {
            weapon_primary.AddAttribute("SRifle charge rate increased", 1.15, -1)
            weapon_primary.AddAttribute("reload time decreased", 0.75, -1)
            weapon_primary.AddAttribute("fire rate bonus", 0.75, -1)
            weapon_primary.AddAttribute("minicrits become crits", 1, -1)
        }
        else if (WeaponIs(weapon_primary, "classic"))
        {
            weapon_primary.AddAttribute("SRifle charge rate increased", 1.30, -1)
            weapon_primary.AddAttribute("aiming movespeed increased", 2.8, -1)
            weapon_primary.AddAttribute("sniper no headshot without full charge", 0, -1)
        }
        else if (WeaponIs(weapon_primary, "sydney_sleeper"))
        {
            weapon_primary.AddAttribute("SRifle charge rate increased", 1.35, -1)
        }
        else if (WeaponIs(weapon_primary, "bazaar_bargain"))
        {

        }

        // Secondary definitions.
        // Delfite: This rebalance of the SMG is intended to make it a TRUE SMG.
		// High rate of fire, good damage, but mandates that you stay relatively close to your target to deal good damage.
		if (WeaponIs(weapon_secondary, "smg"))
		{
			weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1)
			// +15% fire rate. Make the SMG a proper machine gun!
			weapon_secondary.AddAttribute("damage bonus", 2, -1)
			// Damage per bullet: 8 -> 16 (1 damage more than pistol), compensates for falloff just a bit, and makes sniper a serious threat if kritz'd.
			weapon_secondary.AddAttribute("maxammo secondary increased", 2.67, -1)
			// 200 spare rounds.
			weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
			// Perfectly accurate.
			// printdev("SMG stats applied.")
		}
		// Delfite: This rebalance of the Cleaner's Carbine is intended to make it better at mid-range combat.
		// The damage is still worse than the SMG's, but on-demand mini-crits combined with the accuracy bonus turn it into quite the long-range support tool.
		else if (WeaponIs(weapon_secondary, "cleaners_carbine"))
		{
			weapon_secondary.AddAttribute("fire rate penalty", 1.0, -1)
			// No fire rate penalty. This is an SMG, not a lever-action rifle.
			weapon_secondary.AddAttribute("damage bonus", 1.75, -1)
			// Damage per bullet: 8 -> 14 (1 damage less than pistol)
			weapon_secondary.AddAttribute("maxammo secondary increased", 2.67, -1)
			// 200 spare rounds.
			weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
			// Perfectly accurate.
			// printdev("Cleaner's Carbine stats applied.")
		}
		else if (WeaponIs(weapon_secondary, "jarate"))
		{
			Jarate = weapon_secondary
		}

        // Melee definitions.
        if (WeaponIs(weapon_melee, "kukri"))
        {
			weapon_melee.AddAttribute("speed boost when active", 1.2, -1)
        }
        else if (WeaponIs(weapon_melee, "tribalmans_shiv"))
        {
			weapon_melee.AddAttribute("fire rate bonus", 0.7, -1)
        }
        else if (WeaponIs(weapon_melee, "shahanshah"))
        {
			weapon_melee.AddAttribute("dmg bonus while half dead", 1.5, -1)
			weapon_melee.AddAttribute("dmg penalty while half alive", 0.5, -1)
        }
        else if (WeaponIs(weapon_melee, "bushwacka"))
        {
			Bushwacka = weapon_melee
            Bushwacka.AddAttribute("dmg taken increased", 1.0, -1)
        }

        // Melee definitions.
        if (WeaponIs(weapon_melee, "kukri"))
        {
			weapon_melee.AddAttribute("speed boost when active", 1.2, -1)
        }
        else if (WeaponIs(weapon_melee, "tribalmans_shiv"))
        {
			weapon_melee.AddAttribute("fire rate bonus", 0.7, -1)
        }
        else if (WeaponIs(weapon_melee, "shahanshah"))
        {
			weapon_melee.AddAttribute("dmg bonus while half dead", 1.5, -1)
			weapon_melee.AddAttribute("dmg penalty while half alive", 0.5, -1)
        }
        else if (WeaponIs(weapon_melee, "bushwacka"))
        {
			Bushwacka = weapon_melee
            Bushwacka.AddAttribute("dmg taken increased", 1.0, -1)
        }

        // Wearable definitions.
        RunWithDelay2(this, 0.1, function() // Delfite: Adding a delay here to apply the attributes, otherwise there's a chance they just won't.
        {
            while (wearable = FindByClassname(wearable, "tf_wear*"))
			{
                if (wearable.GetOwner() == player)
				{
					if (WeaponIs(wearable, "razorback"))
					{
						// printdev("Razorback found.")
						wearable.AddAttribute("item_meter_charge_type", 3, -1)
						wearable.AddAttribute("item_meter_charge_rate", 12, -1)
						wearable.AddAttribute("patient overheal penalty", 1.0, -1)
						wearable.AddAttribute("cancel falling damage", 1, -1)
						wearable.AddAttribute("item_meter_damage_for_full_charge", 450, -1);
						// Delfite: As much as I wanted this attribute to work, it unfortunately only works on weapons that use the
						// classname "tf_weapon_shovel". And yes, I did try putting it on Sniper's other weapons just to make sure.
						// wearable.AddAttribute("mod shovel speed boost", 1, -1)
						Razorback = wearable
						player.Regenerate(true)
					}
                	else if (WeaponIs(wearable, "darwins_danger_shield"))
					{
						// printdev("Darwin's Danger Shield found.")
						wearable.AddAttribute("dmg taken from blast reduced", 0.5, -1)
						player.Regenerate(true)
					}
                	else if (WeaponIs(wearable, "cozy_camper"))
					{
						// printdev("Cozy Camper found.")
						wearable.AddAttribute("health regen", 10.0, -1)
						wearable.AddAttribute("max health additive bonus", 50, -1)
						wearable.AddAttribute("patient overheal penalty", 0.4, -1)
						player.Regenerate(true)
					}
                }
			}
        })
        player.Regenerate(true)
    }

    function OnTickAlive(timeDelta)
    {
        if ((GetPropInt(Razorback, "m_fEffects") & 32))
			razorbackBroken = false;
    }

    function OnDamageTaken(attacker, params)
    {
        destroyRazorback = false;

		// Delfite: Since we're backstabbing ourselves as a means to trigger the Razorback's break mechanic, we need to stop the knife from dealing damage to us.
		if (params.weapon == knife)
			return;

        if (razorbackBroken || !IsValidBoss(attacker) || player.IsInvulnerable())
            return;

        if ((params.damage_type == 1 || params.damage_type == DMG_BLAST) && params.damage < player.GetHealth())
            return;

        //Note: Saxton Punch!'s collateral will NOT be resisted. Adding extra-extra resistance to make up for it.
        // params.damage *= params.inflictor == custom_dmg_saxton_punch ? 0.2 : 0.5;
        destroyRazorback = true;
    }

	function OnDamageTakenPost(attacker, params)
	{
		if (!destroyRazorback)
            return;

        razorbackBroken = true;

		local victim = params.const_entity
		if (!(GetPropInt(Razorback, "m_fEffects") & 32))
		{
			// Delfite: I don't recommend setting worldspawn as the attacker, inflictor, or weapon in TakeDamageCustom.
			// Doing so - with any of the aforementioned fields - will crash the game when the function tries to run.
			victim.TakeDamageCustom(victim, victim, knife, Vector(0, 0, 0), Vector(0, 0, 0), 1, 0, TF_DMG_CUSTOM_BACKSTAB)

			// Delfite: Since the Sniper is backstabbing himself when Hale hits him, we'll set the Sniper's attack cooldown so he isn't locked
			// out of using his own weapons.
			SetPropFloat(params.weapon, "m_flNextPrimaryAttack", Time());
            SetPropFloat(player, "m_flNextAttack", Time());

			params.damage *= params.inflictor == custom_dmg_saxton_punch ? 0.3 : 0.3;

			// local deltaVector = player.GetCenter() - attacker.GetCenter();
			// deltaVector.z = 0;
			// deltaVector.Norm();
			// player.Yeet(deltaVector * 300 + Vector(0, 0, 450));
			player.AddCondEx(TF_COND_PREVENT_DEATH, 0, null);
			// Delfite: Of course, should the Razorback ever break, we don't want the player to die unless it's already broken.
			// Unfortunately, there IS a bug with this method of death prevention, where if you get hit within the HP threshold
			// needed to set the player's health to 1 from TF_COND_PREVENT_DEATH, the knockback from Hale's melee swing will be
			// drastically reduced and will trigger a "double hit". Normally, this bug isn't a problem because you get flung high
			// enough or far enough away to avoid that "double hit" because your health is high enough to never trigger the
			// knockback reduction. To be clear, this bug is RARE and very specific. Multiple things need to go wrong in order for
			// it to be a problem during gameplay, and I don't know if I can even fix it since damage calculations happen before
			// knockback gets applied.
			// (This bug also happens with Demoman's shield, since it uses the same method of death prevention.)

			RunWithDelay2(this, 1.0, function ()
			{
				// player.AcceptInput("SpeakResponseConcept", "TLK_PLAYER_HELP", null, null)
				if (player.IsAlive())
					EmitSoundOn("Sniper.LaughLong0" + RandomInt(1, 2), player)
			})
		}
		// Delfite: Very silly code me and Brad made where if you take any damage, you'll backstab yourself and turn to gold.
		// else if (RandomInt(0, 1))
		// 	victim.TakeDamageCustom(victim, victim, knife, Vector(0, 0, 0), Vector(0, 0, 0), 999999, 0, TF_DMG_CUSTOM_BACKSTAB)
	}

    function OnDamageDealt(victim, params)
    {
        if (params.damage_custom == TF_DMG_CUSTOM_HEADSHOT)
        {
            params.damage *= 1.2; //Hale has Crit Resistance. Making Headshots an exception.
            AddPropInt(player, "m_Shared.m_iDecapitations", 1);
        }

        // Delfite: Double the Bushwacka's damage if it lands a crit.
        if (params.weapon == Bushwacka)
            if (params.damage_type & DMG_ACID)
                printdev(params.damage)
    }

    function OnHurtDealtEvent(victim, params)
    {
        player.SetRageMeter(clampCeiling(100, player.GetRageMeter() + params.damageamount / 7));
    }

	//At first, I thought giving the Darwin's Danger Shield this resistance would make sense, since it's a "shield".
	//However, I decided to give it to the Huntsman instead, for the following reasons:

    // 1. Unlike sniper rifles, the Huntsman forces you to get close to Hale in order to hit your shots more consistently.
	// 2. Having the resistance be on the primary instead of the secondary enables other close-quarter playstyles (SMG sniper, anyone?)
	// 3. It enforces more courageous gameplay that makes the sniper easy to spot and relatively easy to chase down, but still takes effort to kill on Hale's part.
	function OnDamageTaken(attacker, params)
    {
        if (WeaponIs(weapon_primary, "any_bow"))
        {
            // printdev("The player has a bow equipped.")
            if (IsValidBoss(attacker) || params.attacker == worldspawn)
            {
                // printdev("The attacker is either Hale or Worldspawn.")
                if (params.damage_type & (DMG_CLUB | DMG_FALL))
                {
                    // printdev("The player received either melee damage or fall damage.")
                    params.damage *= params.inflictor == custom_dmg_saxton_punch ? 1.0 : HUNTSMAN_RESISTANCE_FACTOR;

                    local deltaVector = player.GetOrigin() - attacker.GetOrigin();
                    deltaVector.z = 0;
                    deltaVector.Norm();
                    player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
                    params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
                }
            }
        }
    }

    function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("move speed bonus");
            weapon_primary.RemoveAttribute("aiming movespeed increased");
            weapon_primary.RemoveAttribute("sniper no headshot without full charge");
            weapon_primary.RemoveAttribute("minicrits become crits");
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("fire rate bonus");
        }
    }
});