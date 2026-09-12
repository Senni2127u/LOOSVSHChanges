// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's Black Box HP on hit increase.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;
    damageAccumulated = 0;

    Airstrike = null;
    DirectHit = null;

    lastHitWasAirStrike = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "rocket_launcher"))
        {
            weapon_primary.AddAttribute("reload time decreased" 0.75, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
        }
        if (WeaponIs(weapon_primary, "black_box"))
        {
            weapon_primary.AddAttribute("health on radius damage" 50, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
        }
        if (WeaponIs(weapon_primary, "beggars_bazooka"))
        {
            weapon_primary.AddAttribute("projectile spread angle penalty" 0, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.75, -1);
        }
        if (WeaponIs(weapon_primary, "air_strike"))
        {
            weapon_primary.AddAttribute("reload time decreased", 0.85, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.4, -1);
            Airstrike = weapon_primary
        }
        if (WeaponIs(weapon_primary, "liberty_launcher"))
        {
            // weapon_primary.AddAttribute("damage penalty", 0.7, -1)
            weapon_primary.AddAttribute("rocketjump attackrate bonus", 0.35, -1)
            weapon_primary.AddAttribute("reload time decreased" 0.75, -1);
            weapon_primary.AddAttribute("self dmg push force increased", 1.20, -1)
            weapon_primary.AddAttribute("Projectile speed increased", 1.65, -1);
            weapon_primary.AddAttribute("rocket jump damage reduction", 0.0, -1);
        }
        if (WeaponIs(weapon_primary, "direct_hit"))
        {
            weapon_primary.AddAttribute("Projectile speed increased", 1.0, -1)
            weapon_primary.AddAttribute("damage bonus", 1.15, -1)
            DirectHit = weapon_primary
        }
        if (WeaponIs(weapon_primary, "rocket_jumper"))
        {
            weapon_primary.AddAttribute("maxammo primary increased", 1, -1);
            // SetPropInt(player, "m_iAmmo.001", 20)
        }
        player.Regenerate(true)
    }

    function OnFrameTickAlive()
    {
        if (DirectHit)
        {
            local projectile = null;
            while (projectile = FindByClassname(projectile, "tf_projectile_rocket"))
            {
                if (projectile.GetOwner() == player) // projectile is a class object, aka an "instance".
                {
                    projectile.ValidateScriptScope()
                    local projectileScope = projectile.GetScriptScope();
                    if (!("CHECKED" in projectileScope))
                    {
                        projectile.SetAbsVelocity(projectile.GetAbsVelocity() * 3.5)
                        // printl(projectile + " | " + projectile.GetAbsVelocity())
                        projectileScope["CHECKED"] <- null;
                    }
                }
            }
        }
    }

    function OnDamageDealt(victim, params)
    {
        lastHitWasAirStrike = player != victim && WeaponIs(params.weapon, "airstrike");

        if (lastHitWasAirStrike)
        {
            RunWithDelay2(this, 0.05, function ()
            {
                local heads = GetPropInt(player, "m_Shared.m_iDecapitations");
                if (player.IsAlive())
                {
                    local move_speed_bonus = player.GetCustomAttribute("move speed bonus", 1.0)
                    local reload_speed_bonus = player.GetCustomAttribute("reload time decreased", 1.0)
                    if (heads < 9)
                    {
                        player.AddCustomAttribute("move speed bonus", move_speed_bonus + 0.04, -1)
                        player.AddCustomAttribute("reload time decreased", reload_speed_bonus - 0.02, -1)
                    }
                }
            })
        }
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (lastHitWasAirStrike)
        {
            damageAccumulated += params.damageamount;
            while (damageAccumulated >= 180)
            {
                AddPropInt(player, "m_Shared.m_iDecapitations", 1);
                damageAccumulated -= 180;
            }
        }
    }

    function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("reload time decreased");
            weapon_primary.RemoveAttribute("health on radius damage");
            weapon_primary.RemoveAttribute("projectile spread angle penalty");
        }
    }
});