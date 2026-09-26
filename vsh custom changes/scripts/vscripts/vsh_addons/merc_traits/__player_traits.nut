// Script by: Delfite
// The Master Switch!
// This script controls everything to do with the mercs themselves, such as them having knockback resistance while invulnerable, or having altered base stats.
// You can think of this script as a file that covers stuff not normally seen in the weapon scripts.



AddListener("tick_only_valid", 1, function (timeDelta)
{
    local projectile = null;
    while (projectile = FindByClassname(projectile, "tf_projectile*"))
    {
		projectile.ValidateScriptScope()
		local projectileScope = projectile.GetScriptScope();
		if (!("CHECKED" in projectileScope))
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
				projectileScope["CHECKED"] <- null;

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
				// Delfite: BEWARE OF JANK: While this code *does* have the intended effect of making syringes more consistent to hit by making them faster,
				// it comes at the downside of desyncing the syringes visually from their actual position since they're client-sided.
				// I do not recommend enabling this code. Instead, go upvote this Github issue: https://github.com/ValveSoftware/Source-1-Games/issues/8253
				// else if (WeaponIs(weapon, "any_syringegun"))
				// 	projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3)
				else if (WeaponIs(weapon, "flying_guillotine"))
					projectile.SetPhysVelocity(GetPhysVelocity(projectile) * 2)
				else if (WeaponIs(weapon, "gas_passer"))
					projectile.SetPhysVelocity(GetPhysVelocity(projectile) * 2)
				else if (WeaponIs(weapon, "jarate"))
					projectile.SetPhysVelocity(GetPhysVelocity(projectile) * 1.5)
				// TODO: Make Guillotine 2x faster.

				// if (thrower == null)
				// 	printdev(projectile + " | " + projectile.GetAbsVelocity())
				// else
				// 	printdev(projectile + " | " + GetPhysVelocity(projectile))

			}
		}
        break;
    }
});

characterTraitsClasses.push(class extends CharacterTrait
{
	launch = false;

	isScout = false;
	isSoldier = false;
	isPyro = false;
	isDemoman = false;
	isHeavy = false;
	isEngineer = false;
	isMedic = false;
	isSniper = false;
	isSpy = false;

	function OnApply()
	{
		RunWithDelay2(this, 0, OnApply0Delay);
	}

	// Delfite: Not sure why, but I needed to copy over OnApply0Delay from `boss.nut` to get the player attributes working.
	// Might have something to do with player attributes getting cleared automatically on setup start.
	function OnApply0Delay()
	{
		switch (player.GetPlayerClass())
		{
			case TF_CLASS_SCOUT:
				isScout = true;
			break;

			case TF_CLASS_SOLDIER:
				isSoldier = true;
			break;

			case TF_CLASS_PYRO:
				player.AddCustomAttribute("max health additive bonus", 25, -1);
				isPyro = true;
				// printdev("Pyro attributes applied.")
			break;

			case TF_CLASS_DEMOMAN:
				player.AddCustomAttribute("max health additive bonus", 25, -1);
        		// Delfite: Give demo 25 more health so he doesn't die in 1 hit. Boots should not be a hard requirement for preventing death.
				// Might remove the Eyelander's melee crits or give it a damage penalty.
				// Trying to make it more of a utility item than an offensive implement.
				isDemoman = true;
			break;

			case TF_CLASS_HEAVYWEAPONS:
				player.AddCustomAttribute("move speed bonus", 1.3045, -1);
				isHeavy = true;
				// printdev("Heavy attributes applied.")
			break;

			case TF_CLASS_ENGINEER:
				player.AddCustomAttribute("engineer teleporter build rate multiplier", 3.0, -1);
				player.AddCustomAttribute("SET BONUS: dmg from sentry reduced", 0.1, -1); // 90% resistance to the Engie's own sentry bullets.
				player.AddCustomAttribute("rocket jump damage reduction", 0.1, -1); // 90% resistance to the Engie's own sentry rockets.
				player.AddCustomAttribute("maxammo metal increased", 1.5, -1); // Metal reserve: 200 -> 300
				player.AddCustomAttribute("bidirectional teleport", 1, -1);
				player.AddCustomAttribute("mod teleporter cost", 0.5, -1);
				player.AddCustomAttribute("move speed bonus", 1.15, -1);
				isEngineer = true;
				// printdev("Engineer attributes applied.")
			break;

			case TF_CLASS_MEDIC:
				player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1);
				isMedic = true;
				// printdev("Medic attributes applied.")
			break;

			case TF_CLASS_SNIPER:
				player.AddCustomAttribute("move speed bonus", 1.15, -1);
				player.AddCustomAttribute("max health additive bonus", 25, -1);
				isSniper = true;
				// printdev("Sniper attributes applied.")
			break;

			case TF_CLASS_SPY:
				player.AddCustomAttribute("move speed bonus", 1.2, -1);
				player.AddCustomAttribute("NoCloakWhenCloaked", 1, -1);
				isSpy = true;
				// printdev("Spy attributes applied.")
			break;

			default:
			break;
		}
		player.Regenerate(true)
	}

	function OnDamageTaken(attacker, params)
    {
        launch = IsValidBoss(attacker);
        if (launch)
            params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
    }

	function OnDamageTakenPost(attacker, params)
    {
        local active_weapon = player.GetActiveWeapon()
        if (!launch)
            return;

		local deltaVector = player.GetOrigin() - attacker.GetOrigin();
		if (player.IsInvulnerable())
		{
			if (isHeavy)
			{
				if (GetPropInt(weapon_primary, "m_iWeaponState") > 0 && active_weapon == weapon_primary)
				{
					// printdev("1")
					deltaVector.z = 0;
					deltaVector.Norm();
					player.Yeet(deltaVector * 300 + Vector(0, 0, 250));
				}
				else
				{
					// printdev("2")
					deltaVector.z = 0;
					deltaVector.Norm();
					player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
				}
			}
			else
			{
				// printdev("3")
				deltaVector.z = 0;
				deltaVector.Norm();
				player.Yeet(deltaVector * 300 + Vector(0, 0, 250));
			}
        }
		else
		{
			// printdev("4")
			deltaVector.z = 0;
			deltaVector.Norm();
			player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
		}
    }
})