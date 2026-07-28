//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
{
	isWranglerNerfApplied = null;
	secondaryIsWrangler = null;
	weapon_secondary = null;
	active_weapon = null;

	damageCounter = null;
	damageLastTick = 0;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

	function OnApply()
    {
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        secondaryIsWrangler = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY).GetClassname() == "tf_weapon_laser_pointer"

		if (WeaponIs(weapon_secondary, "pistol"))
		{
			weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1)
			weapon_secondary.AddAttribute("damage bonus", 1.20, -1)
			weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
		}
		if (WeaponIs(weapon_secondary, "wrangler"))
		{
			weapon_secondary.AddAttribute("deploy time decreased", 0.65, -1)
		}

        // damageCounter = [];
    }

    // // Delfite: Used to track the wrangler's sentry DPS.
    // function OnHurtDealtEvent(victim, params)
    // {
    //     damageLastTick += params.damageamount
    //     // victim.SetHealth(1000)
    //     // printl(damageLastTick)
    // }

    function OnFrameTickAlive()
    {
        // damageCounter.push(damageLastTick);
        // if (damageCounter.len() > 66)
        //     damageCounter.remove(0)

        // damageLastTick = 0

        // local totalDamage = 0
        // foreach (v in damageCounter)
        //     totalDamage += v

        // ClientPrint(player, 4, "Total Damage: " + totalDamage)


        local active_weapon = player.GetActiveWeapon()
        if (secondaryIsWrangler)
        {
            if (WeaponIs(active_weapon, "wrangler"))
            {
                if (isWranglerNerfApplied)
                    return;

				// Delfite: Turns out negating the wrangler's doubled fire rate is as simple as giving this attribute a value of 2.
                weapon_secondary.AddAttribute("engy sentry fire rate increased", 2, -1)
                isWranglerNerfApplied = true;
            }
            else
            {
                if (!isWranglerNerfApplied)
                    return;

                weapon_secondary.RemoveAttribute("engy sentry fire rate increased")
                isWranglerNerfApplied = false;
            }
        }
	}

	function OnDiscard()
	{
		if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("engy sentry fire rate increased");
            weapon_secondary.RemoveAttribute("fire rate bonus");
        }
	}
})