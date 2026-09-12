//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
{
	Pomson = null;

	pomsonCritNerfApplied = false;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

	function OnApply()
	{
		if (WeaponIs(weapon_primary, "shotgun"))
		{
			weapon_primary.AddAttribute("damage bonus", 1.40, -1);
			weapon_primary.AddAttribute("weapon spread bonus", 0.7, -1);
			weapon_primary.AddAttribute("reload time decreased", 0.85, -1);
		}
		if (WeaponIs(weapon_primary, "panic_attack"))
		{
			weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1);
			weapon_primary.AddAttribute("damage penalty", 1.0, -1);
		}
		if (WeaponIs(weapon_primary, "frontier_justice"))
		{
			weapon_primary.AddAttribute("fire rate bonus", 0.7, -1);
		}
		if (WeaponIs(weapon_primary, "widowmaker"))
		{
			weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1);
		}
		if (WeaponIs(weapon_primary, "rescue_ranger"))
		{
			weapon_primary.AddAttribute("fire rate bonus", 0.7, -1)
			weapon_primary.AddAttribute("mark for death on building pickup", 0, -1)
		}
		if (WeaponIs(weapon_primary, "pomson_6000"))
		{
			weapon_primary.AddAttribute("Projectile speed increased", 2.0, -1);
            weapon_primary.AddAttribute("fire rate bonus", 0.80, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.80, -1);
            weapon_primary.AddAttribute("dmg penalty vs players", 1.5, -1);
			Pomson = weapon_primary
		}
	}

	function OnFrameTickAlive()
	{
		if (Pomson)
		{
			local projectile = null;
            while (projectile = FindByClassname(projectile, "tf_projectile_energy_ring"))
            {
                if (projectile.GetOwner() == player) // projectile is a class object, aka an "instance".
                {
                    projectile.ValidateScriptScope()
                    local projectileScope = projectile.GetScriptScope();
                    if (!("CHECKED" in projectileScope))
                    {
                        projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3)
                        // printl(projectile + " | " + projectile.GetAbsVelocity())
                        projectileScope["CHECKED"] <- null;
                    }
                }
            }

			if (player.IsCritBoosted())
			{
				if (pomsonCritNerfApplied)
					return;

				Pomson.AddAttribute("dmg penalty vs players", 1.1, -1);
				pomsonCritNerfApplied = true;
			}
			else
			{
				if (!pomsonCritNerfApplied)
					return;

				Pomson.AddAttribute("dmg penalty vs players", 1.5, -1);
				pomsonCritNerfApplied = false;
			}
		}
	}

	function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("weapon spread bonus");
            weapon_primary.RemoveAttribute("reload time decreased");
            weapon_primary.RemoveAttribute("fire rate bonus");
            weapon_primary.RemoveAttribute("mark for death on building pickup");
            weapon_primary.RemoveAttribute("damage penalty");
        }
    }
});