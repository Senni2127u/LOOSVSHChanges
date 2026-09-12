// Script by: Delfite
// The Master Switch!
// This script controls everything to do with the mercs, such as the mercs having knockback resistance while invulnerable.


characterTraitsClasses.push(class extends CharacterTrait
{
	launch = false;

	weapon_primary = null;
    weapon_secondary = null;
    weapon_melee = null;

	Scout = null;
	Soldier = null;
	Pyro = null;
	Demoman = null;
	Heavy = null;
	Engineer = null;
	Medic = null;
	Sniper = null;
	Spy = null;

	knockbackResistanceActive = false;

	function OnApply()
	{
		RunWithDelay2(this, 0, OnApply0Delay);
	}

	// Delfite: Not sure why, but I needed to copy over OnApply0Delay from `boss.nut` to get the player attributes working.
	// Might have something to do with player attributes getting cleared automatically on setup start.
	function OnApply0Delay()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

		Scout = player.GetPlayerClass() == TF_CLASS_SCOUT
		Soldier = player.GetPlayerClass() == TF_CLASS_SOLDIER
		Pyro = player.GetPlayerClass() == TF_CLASS_PYRO
		Demoman = player.GetPlayerClass() == TF_CLASS_DEMOMAN
		Heavy = player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS
		Engineer = player.GetPlayerClass() == TF_CLASS_ENGINEER
		Medic = player.GetPlayerClass() == TF_CLASS_MEDIC
		Sniper = player.GetPlayerClass() == TF_CLASS_SNIPER
		Spy = player.GetPlayerClass() == TF_CLASS_SPY

		if (Scout)
		{

		}
		else if (Soldier)
		{

		}
		else if (Pyro)
		{
			player.AddCustomAttribute("max health additive bonus", 25, -1);
			// printl("Pyro attributes applied.")
		}
		else if (Demoman)
		{

		}
		else if (Heavy)
		{
			player.AddCustomAttribute("move speed bonus", 1.3045, -1);
			// printl("Heavy attributes applied.")
		}
		else if (Engineer)
		{
			player.AddCustomAttribute("engineer teleporter build rate multiplier", 3.0, -1)
			player.AddCustomAttribute("SET BONUS: dmg from sentry reduced", 0.1, -1);
			player.AddCustomAttribute("rocket jump damage reduction", 0.1, -1);
			player.AddCustomAttribute("maxammo metal increased", 1.5, -1); // Metal reserve: 200 -> 300
			player.AddCustomAttribute("bidirectional teleport", 1, -1);
			player.AddCustomAttribute("mod teleporter cost", 0.5, -1);
			player.AddCustomAttribute("move speed bonus", 1.15, -1);
			// printl("Engineer attributes applied.")
		}
		else if (Medic)
		{
			player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
			// printl("Medic attributes applied.")
		}
		else if (Sniper)
		{
			player.AddCustomAttribute("move speed bonus", 1.15, -1);
			// printl("Sniper attributes applied.")
		}
		else if (Spy)
		{
			player.AddCustomAttribute("move speed bonus", 1.2, -1);
			player.AddCustomAttribute("NoCloakWhenCloaked", 1, -1);
			// printl("Spy attributes applied.")
		}
		player.Regenerate(true)
	}

	function OnFrameTickAlive()
	{
		if (player.IsInvulnerable())
		{
			if (knockbackResistanceActive)
				return;

			printl("Force reduction applied.")
			player.AddCustomAttribute("damage force reduction", 0.1, -1)
			knockbackResistanceActive = true;
		}
		else
		{
			if (!knockbackResistanceActive)
				return;

			printl("Force reduction removed.")
			player.RemoveCustomAttribute("damage force reduction")
			knockbackResistanceActive = false;
		}
	}

	function OnDamageTaken(attacker, params)
    {
        launch = IsValidBoss(attacker);
        if (launch)
            params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
    }

	function OnDamageTakenPost(attacker, params)
    {
        local weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY)
        local active_weapon = player.GetActiveWeapon()
        if (!launch)
            return;

		if (player.IsInvulnerable() && !Medic)
		{
			if (Heavy)
			{
				if (GetPropInt(weapon_primary, "m_iWeaponState") > 0 && active_weapon == weapon_primary)
				{
					printl("1")
					local deltaVector = player.GetOrigin() - attacker.GetOrigin();
					deltaVector.z = 0;
					deltaVector.Norm();
					player.Yeet(deltaVector * 300 + Vector(0, 0, 250));
				}
				else
				{
					printl("2")
					local deltaVector = player.GetOrigin() - attacker.GetOrigin();
					deltaVector.z = 0;
					deltaVector.Norm();
					player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
				}
			}
			else
			{
				printl("3")
				local deltaVector = player.GetOrigin() - attacker.GetOrigin();
				deltaVector.z = 0;
				deltaVector.Norm();
				player.Yeet(deltaVector * 300 + Vector(0, 0, 250));
			}
        }
		else
		{
			printl("4")
			local deltaVector = player.GetOrigin() - attacker.GetOrigin();
			deltaVector.z = 0;
			deltaVector.Norm();
			player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
		}
    }
})