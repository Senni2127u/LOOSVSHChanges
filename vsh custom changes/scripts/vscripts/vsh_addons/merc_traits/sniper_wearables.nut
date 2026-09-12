// Script by: Delfite, with assistance from: Bradasparky.
// This script handles everything to do with Sniper's wearables (Eg. Razorback, Darwin's Danger Shield, Cozy Camper).


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
	wearable = null;
    // weapon_primary = null;
    // weapon_secondary = null;
    // weapon_melee = null;
	razorback = null;

	destroyRazorback = false;
    razorbackBroken = false;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_SNIPER;
	}

	function OnApply()
    {
        // weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        // weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        // weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        RunWithDelay2(this, 0.1, function() // Delfite: Adding a delay here to apply the attributes, otherwise there's a chance they just won't.
        {
            while (wearable = FindByClassname(wearable, "tf_wear*"))
                if (wearable.GetOwner() == player)
				{
					if (WeaponIs(wearable, "razorback"))
					{
						// printl("Razorback found.")
						wearable.AddAttribute("item_meter_charge_type", 3, -1)
						wearable.AddAttribute("item_meter_charge_rate", 12, -1)
						wearable.AddAttribute("patient overheal penalty", 1.0, -1)
						wearable.AddAttribute("cancel falling damage", 1, -1)
						wearable.AddAttribute("item_meter_damage_for_full_charge", 450, -1);
						// Delfite: As much as I wanted this attribute to work, it unfortunately only works on weapons that use the
						// classname "tf_weapon_shovel". And yes, I did try putting it on Sniper's other weapons just to make sure.
						// wearable.AddAttribute("mod shovel speed boost", 1, -1)
						razorback = wearable
						player.Regenerate(true)
					}
                	else if (WeaponIs(wearable, "darwins_danger_shield"))
					{
						// printl("Darwin's Danger Shield found.")
						wearable.AddAttribute("dmg taken from blast reduced", 0.5, -1)
						player.Regenerate(true)
					}
                	else if (WeaponIs(wearable, "cozy_camper"))
					{
						// printl("Cozy Camper found.")
						wearable.AddAttribute("health regen", 10.0, -1)
						wearable.AddAttribute("max health additive bonus", 50, -1)
						wearable.AddAttribute("patient overheal penalty", 0.4, -1)
						player.Regenerate(true)
					}
                }
        })
    }

	function OnFrameTickAlive()
    {
        if ((GetPropInt(razorback, "m_fEffects") & 32))
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
		if (!(GetPropInt(razorback, "m_fEffects") & 32))
		{
			// Delfite: I don't recommend setting worldspawn as the attacker, inflictor, or weapon in TakeDamageCustom.
			// Doing so - with any of the aforementioned fields - will crash the game when the function tries to run.
			victim.TakeDamageCustom(victim, victim, knife, Vector(0, 0, 0), Vector(0, 0, 0), 1, 0, TF_DMG_CUSTOM_BACKSTAB)

			// Delfite: Since the Sniper is backstabbing himself when Hale hits him, we'll set the Sniper's attack cooldown so he isn't locked
			// out of using his own weapons.
			SetPropFloat(params.weapon, "m_flNextPrimaryAttack", Time());
            SetPropFloat(player, "m_flNextAttack", Time());

			params.damage *= params.inflictor == custom_dmg_saxton_punch ? 0.3 : 0.3;

			local deltaVector = player.GetCenter() - attacker.GetCenter();
			deltaVector.z = 0;
			deltaVector.Norm();
			player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
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
				{
					if (RandomInt(0, 1))
						EmitSoundOn("Sniper.LaughLong01", player)
					else
						EmitSoundOn("Sniper.LaughLong02", player)
				}
			})
		}
		// Delfite: Very silly code me and Brad made where if you take any damage, you'll backstab yourself and turn to gold.
		// else if (RandomInt(0, 1))
		// 	victim.TakeDamageCustom(victim, victim, knife, Vector(0, 0, 0), Vector(0, 0, 0), 999999, 0, TF_DMG_CUSTOM_BACKSTAB)
	}
});