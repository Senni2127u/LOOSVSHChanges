// Script by Senni, Assistance from Bradasparky.
// Script handles Scout's Backscatter accuracy increase.
// This script requires modification to weapon_primarys.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    // weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnApply()
    {
        // weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "scattergun"))
        {
            weapon_primary.AddAttribute("projectile penetration", 1, -1);
            weapon_primary.AddAttribute("damage bonus", 1.30, -1);
        }
        if (WeaponIs(weapon_primary, "backscatter"))
        {
            weapon_primary.AddAttribute("spread penalty", 1.0, -1);
        }
        if (WeaponIs(weapon_primary, "shortstop"))
        {
            weapon_primary.AddAttribute("weapon spread bonus", 0.35, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.9, -1);
            weapon_primary.AddAttribute("damage bonus", 1.15, -1);
        }
    }

    lastTimeApplied = 0;

    function OnDamageDealt(victim, params)
    {
        // Delfite: Removed check for the Festive FaN, since it's bundled into the regular FaN's index list.
        if (Time() - lastTimeApplied < 0.1 || !IsBoss(victim)
            || (!WeaponIs(params.weapon, "force_a_nature")))
            return;
        local deltaVector = victim.GetOrigin() - player.GetOrigin();
        deltaVector.z = 100;
        local distance = deltaVector.Norm();
        if (distance < 600)
            victim.Yeet(deltaVector * (300 - distance / 2));
    }

    function OnDiscard()
	{
		// Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("weapon spread bonus");
            weapon_primary.RemoveAttribute("reload time decreased");
            //printl("Secondary attributes discarded.")
        }
	}
});