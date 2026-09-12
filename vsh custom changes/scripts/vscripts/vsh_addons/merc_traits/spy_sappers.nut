// Script by: Delfite


characterTraitsClasses.push(class extends CharacterTrait
{
	// weapon_secondary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnApply()
    {
		// weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);

        if (WeaponIs(weapon_secondary, "sapper") || WeaponIs(weapon_secondary, "red_tape_recorder"))
        {
            // weapon_secondary.AddAttribute("move speed bonus", 1.25, -1)
            // weapon_secondary.AddAttribute("provide on active", 1, -1)
        }
    }

	function OnDiscard()
	{
		// Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("move speed bonus");
            weapon_secondary.RemoveAttribute("provide on active");
            //printl("Secondary attributes discarded.")
        }
	}
});