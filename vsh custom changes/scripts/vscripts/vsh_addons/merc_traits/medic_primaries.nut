//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_MEDIC;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (!WeaponIs(weapon_primary, "crusaders_crossbow"))
        {
            // Delfite: Only god knows why, but the "projectile speed increased" attribute doesn't work on Syringe Guns. Damn you Valve!
            weapon_primary.AddAttribute("fire rate bonus", 0.70, -1)
            weapon_primary.AddAttribute("reload time decreased", 0.60, -1)
            weapon_primary.AddAttribute("maxammo primary increased", 2.0, -1)
            weapon_primary.AddAttribute("Projectile speed increased", 2.0, -1)
            if (WeaponIs(weapon_primary, "syringe_gun"))
            {
                weapon_primary.AddAttribute("damage bonus", 1.50, -1)
                // weapon_primary.AddAttribute("weapon spread bonus", 0.0, -1)
            }
            if (WeaponIs(weapon_primary, "overdose"))
            {
                weapon_primary.AddAttribute("move speed bonus resource level", 1.0, -1)
                // Delfite: Remove the Overdose's old movement speed bonus...
                weapon_primary.AddAttribute("move speed bonus", 1.20, -1)
                // Delfite: ...and replace it with the generic version.
                weapon_primary.AddAttribute("damage penalty", 0.8, -1)
            }
            if (WeaponIs(weapon_primary, "blutsauger"))
            {
                weapon_primary.AddAttribute("heal on hit for rapidfire", 5, -1)
                // weapon_primary.AddAttribute("clip size penalty", 0.75, -1)
            }
        }
        if (WeaponIs(weapon_primary, "crusaders_crossbow"))
        {
            weapon_primary.AddAttribute("damage bonus", 2, -1)
        }
        player.Regenerate(true)
    }

    function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("Projectile speed increased")
            weapon_primary.RemoveAttribute("move speed bonus resource level");
            weapon_primary.RemoveAttribute("move speed bonus");
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("damage penalty");
            weapon_primary.RemoveAttribute("fire rate bonus");
            weapon_primary.RemoveAttribute("heal on hit for rapidfire");
            weapon_primary.RemoveAttribute("clip size penalty");
            weapon_primary.RemoveAttribute("reload time decreased");
            weapon_primary.RemoveAttribute("maxammo primary increased");
        }
    }
});