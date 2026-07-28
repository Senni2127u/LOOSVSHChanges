// Script by: Delfite


characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_building = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnApply()
    {
		weapon_building = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);

        if (WeaponIs(weapon_building, "sapper") || WeaponIs(weapon_building, "red_tape_recorder"))
        {
            // weapon_building.AddAttribute("move speed bonus", 1.25, -1)
            // weapon_building.AddAttribute("provide on active", 1, -1)
        }
    }

	function OnDiscard()
	{
		// Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_building && weapon_building.IsValid())
        {
            weapon_building.RemoveAttribute("move speed bonus");
            weapon_building.RemoveAttribute("provide on active");
            //printl("Secondary attributes discarded.")
        }
	}
});