//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SNIPER;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "any_bow"))
        {
			weapon_primary.AddAttribute("move speed bonus", 1.1, -1)
			weapon_primary.AddAttribute("max health additive bonus", 50, -1)
			//175 HP feels more satisfying than 150. Probably because no other class has 175 HP at this point.
			weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1)
			weapon_primary.AddAttribute("Reload time decreased", 0.75, -1)
			weapon_primary.AddAttribute("fire rate bonus", 0.65, -1)
			weapon_primary.AddAttribute("maxammo primary increased", 2.0, -1)
			// weapon_primary.AddAttribute("damage bonus", 1.25, -1)
			//The Huntsman's charge speed is directly tied to its fire rate. We want it to charge quickly.
            //weapon_primary.AddAttribute("overheal penalty", 1.2, -1) //Need to test this with Senni later.
        }
        if (WeaponIs(weapon_primary, "any_sniper_rifle"))
        {
            if (!WeaponIs(weapon_primary, "machina") && !WeaponIs(weapon_primary, "sydney_sleeper"))
            {
                // Delfite: Enabling the tracers on the Sydney causes it to do normal headshot damage, which we don't want.
                weapon_primary.AddAttribute("sniper fires tracer", 1, -1)
                weapon_primary.AddAttribute("lunchbox adds minicrits", 3, -1)
                // Delfite: For whatever reason, this attribute controls the visuals of a sniper rifle's tracer rounds.
                // Delfite: A value of 3 enables the tracer rounds used by the Classic.
            }
        }
        if (WeaponIs(weapon_primary, "sniper_rifle"))
        {
            weapon_primary.AddAttribute("SRifle charge rate increased", 1.15, -1)
            weapon_primary.AddAttribute("move speed bonus", 1.30, -1)
            weapon_primary.AddAttribute("max health additive bonus", 25, -1)
        }
        if (WeaponIs(weapon_primary, "machina"))
        {
            weapon_primary.AddAttribute("move speed bonus", 1.1, -1)
            weapon_primary.AddAttribute("dmg pierces resists absorbs", 1, -1)
            weapon_primary.AddAttribute("max health additive bonus", 25, -1)
            weapon_primary.AddAttribute("sniper only fire zoomed", 0, -1)
            weapon_primary.AddAttribute("sniper full charge damage bonus", 1.25, -1)
        }
        if (WeaponIs(weapon_primary, "hitmans_heatmaker"))
        {
            weapon_primary.AddAttribute("move speed bonus", 1.15, -1)
            weapon_primary.AddAttribute("SRifle charge rate increased", 1.15, -1)
            weapon_primary.AddAttribute("max health additive bonus", 25, -1)
            weapon_primary.AddAttribute("minicrits become crits", 1, -1)
        }
        if (WeaponIs(weapon_primary, "classic"))
        {
            weapon_primary.AddAttribute("SRifle charge rate increased", 1.30, -1)
            weapon_primary.AddAttribute("max health additive bonus", 75, -1)
            weapon_primary.AddAttribute("move speed bonus", 1.10, -1)
            weapon_primary.AddAttribute("aiming movespeed increased", 2.7, -1)
            weapon_primary.AddAttribute("sniper no headshot without full charge", 0, -1)
        }
        if (WeaponIs(weapon_primary, "sydney_sleeper"))
        {
            weapon_primary.AddAttribute("SRifle charge rate increased", weapon_primary.GetAttribute("SRifle charge rate increased", 1.0) + 0.10, -1)
        }
        if (WeaponIs(weapon_primary, "bazaar_bargain"))
        {
            weapon_primary.AddAttribute("move speed bonus", 1.1, -1)
        }
        player.Regenerate(true)
    }

	//At first, I thought giving the Darwin's Danger Shield this resistance would make sense, since it's a "shield".
	//However, I decided to give it to the Huntsman instead, for the following reasons:

    // 1. Unlike sniper rifles, the Huntsman forces you to get close to Hale in order to hit your shots more consistently.
	// 2. Having the resistance be on the primary instead of the secondary enables other close-quarter playstyles (SMG sniper, anyone?)
	// 3. It enforces more courageous gameplay that makes the sniper easy to spot and relatively easy to chase down, but still takes effort to kill on Hale's part.
	function OnDamageTaken(attacker, params)
    {
        if (IsValidBoss(attacker) && WeaponIs(weapon_primary, "any_bow"))
        {
            params.damage *= 0.70;
            local deltaVector = player.GetOrigin() - attacker.GetOrigin();
            deltaVector.z = 0;
            deltaVector.Norm();
            player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
            params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
        }
    }

    function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("move speed bonus");
            weapon_primary.RemoveAttribute("aiming movespeed increased");
            weapon_primary.RemoveAttribute("sniper no headshot without full charge");
            weapon_primary.RemoveAttribute("minicrits become crits");
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("fire rate bonus");
        }
    }
});