// Script by: Delfite.
// This script handles everything to do with Scout's melees.

totalHealthKits <- 0;

characterTraitsClasses.push(class extends CharacterTrait
{
	// weapon_melee = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnApply()
    {
        // weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        if (WeaponIs(weapon_melee, "bat"))
        {
            // weapon_melee.AddAttribute("damage bonus", 1.86, -1);
            // printl("Bat stats applied.")
        }
        if (WeaponIs(weapon_melee, "atomizer"))
        {
            weapon_melee.AddAttribute("deploy time increased", 1.25, -1);
            // printl("Atomizer stats applied.")
        }
        if (WeaponIs(weapon_melee, "boston_basher"))
        {
            weapon_melee.AddAttribute("damage bonus", 1.5, -1);
            weapon_melee.AddAttribute("bleeding duration", 8, -1);
            // printl("Boston Basher stats applied.")
        }
        if (WeaponIs(weapon_melee, "candy_cane"))
        {
            weapon_melee.AddAttribute("dmg taken from blast increased", 1.0, -1);
            // printl("Candy Cane stats applied.")
        }
        player.Regenerate(true)
    }
    // TODO: Make Boston Basher crit on bleed

    function OnDamageDealt(victim, params)
    {
        if (WeaponIs(params.weapon, "candy_cane"))
        {
            if (!(params.damage_type & 128) || vsh_vscript.totalHealthKits > 30)
                return;
            local healthKit = SpawnEntityFromTable("item_healthkit_small", {
                "OnPlayerTouch": "!self,Kill,,0,-1",
            });
            vsh_vscript.totalHealthKits++;
            healthKit.SetMoveType(Constants.EMoveType.MOVETYPE_FLYGRAVITY, Constants.EMoveCollide.MOVECOLLIDE_FLY_BOUNCE);
            healthKit.SetAbsOrigin(victim.GetCenter());
            healthKit.SetVelocity(Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 250));
            RunWithDelay2(this, 30, function(healthKit)
            {
                vsh_vscript.totalHealthKits--;
                if (healthKit != null && healthKit.IsValid())
                    healthKit.Kill();
            }, healthKit);
        }
        if (WeaponIs(params.weapon, "boston_basher") && params.attacker == player)
        {
            player.RemoveCond(TF_COND_BLEEDING)
            if (params.damage_type & DMG_CLUB && victim == player)
            {
                local deltaVector = player.GetCenter() - params.inflictor.GetOrigin();
                deltaVector.Norm();
                player.Yeet(deltaVector * 400);
                params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
                // printl("Player launched.")
            }
        }
    }

	function OnDiscard()
    {
        // Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("maxammo secondary increased");
            weapon_melee.RemoveAttribute("fire rate bonus");
            weapon_melee.RemoveAttribute("weapon spread bonus");
            weapon_melee.RemoveAttribute("mod_mark_attacker_for_death");
            weapon_melee.RemoveAttribute("effect bar recharge rate increased");
            weapon_melee.RemoveAttribute("minicrits become crits");
            //printl("Secondary attributes discarded.")
        }
	}
});
