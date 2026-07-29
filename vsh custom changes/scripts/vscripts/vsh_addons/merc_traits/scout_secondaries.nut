// Script by: Delfite.

characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_secondary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnApply()
    {
		// TODO: Give Scattergun more damage (probably).
		// TODO: Increase healing granted by the pbpp.
		// TODO: Make Enforcer keep your disguise while shooting.
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        if (WeaponIs(weapon_secondary, "pistol"))
        {
            weapon_secondary.AddAttribute("maxammo secondary increased", 4.0, -1);
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1);
            weapon_secondary.AddAttribute("fire rate bonus", 0.85, -1);
            weapon_secondary.AddAttribute("damage bonus", 1.25, -1);
			//printl("Pistol stats applied.")
        }
        if (WeaponIs(weapon_secondary, "pbpp"))
        {
            weapon_secondary.AddAttribute("maxammo secondary increased", 4.0, -1);
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1);
            weapon_secondary.AddAttribute("heal on hit for rapidfire", 5.0, -1);
			//printl("PBPP stats applied.")
        }
        if (WeaponIs(weapon_secondary, "winger"))
        {
            weapon_secondary.AddAttribute("maxammo secondary increased", 4.0, -1);
            weapon_secondary.AddAttribute("weapon spread bonus", 0.0, -1);
			//printl("Winger stats applied.")
        }
		if (WeaponIs(weapon_secondary, "bonk_atomic_punch"))
        {
            weapon_secondary.AddAttribute("effect bar recharge rate increased", 0.65, -1);
			//printl("Bonk stats applied.")
        }
		if (WeaponIs(weapon_secondary, "crit_a_cola"))
        {
            weapon_secondary.AddAttribute("mod_mark_attacker_for_death", 0, -1);
            weapon_secondary.AddAttribute("effect bar recharge rate increased", 0.65, -1);
			//printl("Crit-a-cola stats applied.")
        }
		if (WeaponIs(weapon_secondary, "flying_guillotine"))
        {
            weapon_secondary.AddAttribute("minicrits become crits", 1, -1);
            // Delfite: 225 damage crit, accounting for bleed.
            // weapon_secondary.AddAttribute("Projectile speed increased", 2.0, -1);
            // Delfite: NO! Projectile speed doesn't work on throwables! I hate you Valve!
            weapon_secondary.AddAttribute("effect bar recharge rate increased", 1.6, -1);
            // Delfite: To compensate for the staggering crit damage, we'll make the cleaver less spammable.
			//printl("Guillotine stats applied.")
        }
		player.Regenerate(true)
    }

	function OnDiscard()
    {
        // Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("maxammo secondary increased");
            weapon_secondary.RemoveAttribute("fire rate bonus");
            weapon_secondary.RemoveAttribute("weapon spread bonus");
            weapon_secondary.RemoveAttribute("mod_mark_attacker_for_death");
            weapon_secondary.RemoveAttribute("effect bar recharge rate increased");
            weapon_secondary.RemoveAttribute("minicrits become crits");
            //printl("Secondary attributes discarded.")
        }
	}
});
