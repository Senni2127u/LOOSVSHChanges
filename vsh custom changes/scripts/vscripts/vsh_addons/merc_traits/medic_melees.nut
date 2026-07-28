//Copyright: Delfite

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_melee = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_MEDIC;
    }

    function OnApply()
    {
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

		if (WeaponIs(weapon_melee, "amputator"))
		{
			weapon_melee.AddAttribute("provide on active", 1, -1)
			// Delfite: Tragically, for reasons beyond my understanding,
			// Delfite: the "health regen" attribute REQUIRES "provide on active"
			// Delfite: be set to 1 in order to function.
			weapon_melee.AddAttribute("health regen", 6, -1)
			// Delfite: Regen: 3 -> 6
			// weapon_melee.AddAttribute("active health regen", 10, -1)
			// Delfite: Unused attribute that overheals with no limit.
			// Delfite: Not recommended for use in VSH, or anywhere really.
			// weapon_melee.AddAttribute("weapon spread bonus", 0.0, -1)
		}
        player.Regenerate(true)
    }

    function OnDiscard()
    {
        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("Projectile speed increased")
            weapon_melee.RemoveAttribute("move speed bonus resource level");
            weapon_melee.RemoveAttribute("move speed bonus");
            weapon_melee.RemoveAttribute("damage bonus");
            weapon_melee.RemoveAttribute("damage penalty");
            weapon_melee.RemoveAttribute("fire rate bonus");
            weapon_melee.RemoveAttribute("heal on hit for rapidfire");
            weapon_melee.RemoveAttribute("clip size penalty");
        }
    }
});