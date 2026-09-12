//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
{
	isWranglerNerfApplied = false;
	secondaryIsWrangler = false;
	weapon_secondary = null;
	active_weapon = null;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

	function OnApply()
    {
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);

		if (WeaponIs(weapon_secondary, "pistol"))
        {
            weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1)
            weapon_secondary.AddAttribute("damage bonus", 1.20, -1)
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1)
            weapon_secondary.AddAttribute("projectile penetration", 1, -1);
		}
		if (WeaponIs(weapon_secondary, "wrangler"))
        {
            weapon_secondary.AddAttribute("deploy time decreased", 0.65, -1)
            secondaryIsWrangler = true;
		}
    }

    function OnFrameTickAlive()
    {
        local active_weapon = player.GetActiveWeapon()
        if (secondaryIsWrangler)
        {
            if (WeaponIs(active_weapon, "wrangler"))
            {
                if (isWranglerNerfApplied)
                    return;

				// Delfite: Turns out negating the wrangler's doubled fire rate is as simple as giving this attribute a value of 2.
                // This nerf - in practice, however - ended up being pretty harsh since sentries already deal half of their normal damage.
                // Reducing this value to 1.75 so the player can at least get a 25% fire rate bonus on the sentry.
                weapon_secondary.AddAttribute("engy sentry fire rate increased", 1.75, -1)
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

    function OnDeath(attacker, params)
    {
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("engy sentry fire rate increased");
            weapon_secondary.RemoveAttribute("fire rate bonus");
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