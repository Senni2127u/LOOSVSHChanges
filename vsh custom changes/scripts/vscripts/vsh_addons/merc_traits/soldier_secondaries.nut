// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's Black Box HP on hit increase.
// This script requires modification to weapons.nut script to function.

AddListener("setup_start", 0, function()
{
	// Delfite: These cvars control everything to do with the Base Jumper. Their values are set every time setup starts.
	// These cvars are also hidden in-game and considered dev commands, but can still be set by VScript nonetheless.
	Convars.SetValue("tf_parachute_aircontrol", 2.5)                                                // Default: 2.5
	Convars.SetValue("tf_parachute_deploy_toggle_allowed", 0)                                       // Default: 0
	Convars.SetValue("tf_parachute_gravity", 0.2)                                                   // Default: 0.2
	Convars.SetValue("tf_parachute_maxspeed_onfire_z", -100)                                        // Default: -100
	Convars.SetValue("tf_parachute_maxspeed_xy", 300)                                               // Default: 300
	Convars.SetValue("tf_parachute_maxspeed_z", -100)                                               // Default: -100

	// printl("tf_parachute_aircontrol = " + Convars.GetFloat("tf_parachute_aircontrol"))
	// printl("tf_parachute_deploy_toggle_allowed = " + Convars.GetFloat("tf_parachute_deploy_toggle_allowed"))
	// printl("tf_parachute_gravity = " + Convars.GetFloat("tf_parachute_gravity"))
	// printl("tf_parachute_maxspeed_onfire_z = " + Convars.GetFloat("tf_parachute_maxspeed_onfire_z"))
	// printl("tf_parachute_maxspeed_xy = " + Convars.GetFloat("tf_parachute_maxspeed_xy"))
	// printl("tf_parachute_maxspeed_z = " + Convars.GetFloat("tf_parachute_maxspeed_z"))
});

characterTraitsClasses.push(class extends CharacterTrait
{
    Bison = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnApply()
    {
        if (WeaponIs(weapon_secondary, "shotgun"))
        {
            weapon_secondary.AddAttribute("damage bonus" 1.40, -1);
            weapon_secondary.AddAttribute("weapon spread bonus", 0.70, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.85, -1);
        }
        if (WeaponIs(weapon_secondary, "reserve_shooter"))
        {
            // weapon_secondary.AddAttribute("weapon spread bonus" 0.70, -1);
        }
        if (WeaponIs(weapon_secondary, "panic_attack"))
        {
            weapon_secondary.AddAttribute("weapon spread bonus" 0.6, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
        }
        if (WeaponIs(weapon_secondary, "righteous_bison"))
        {
            // weapon_secondary.AddAttribute("damage bonus", 4, -1);
            weapon_secondary.AddAttribute("fire rate bonus", 0.80, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.80, -1);
            weapon_secondary.AddAttribute("dmg penalty vs players", 2, -1);
            Bison = weapon_secondary
        }
        if (WeaponIs(weapon_secondary, "base_jumper_soldier"))
        {
				weapon_secondary.AddAttribute("rocket jump damage reduction", 0.40, -1)
        }
        player.Regenerate(true)
    }

    function OnFrameTickAlive()
    {
        if (Bison)
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
        }
    }

    function OnDiscard()
    {
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("reload time decreased");
            weapon_secondary.RemoveAttribute("Projectile speed increased");
            weapon_secondary.RemoveAttribute("damage bonus");
            weapon_secondary.RemoveAttribute("weapon spread bonus");
            weapon_secondary.RemoveAttribute("damage penalty");
        }
    }
});