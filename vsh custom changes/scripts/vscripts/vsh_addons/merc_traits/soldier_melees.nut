//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_melee = null;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_SOLDIER
	}

	function OnApply()
	{
		weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

		if (WeaponIs(weapon_melee, "shovel"))
		{
			weapon_melee.AddAttribute("damage bonus", 1.30, -1);
		}
		if (WeaponIs(weapon_melee, "escape_plan"))
		{
			weapon_melee.AddAttribute("self mark for death", 0, -1);
			weapon_melee.AddAttribute("mod shovel speed boost", 0, -1);
			weapon_melee.AddAttribute("move speed bonus", 1.4, -1);
			weapon_melee.AddAttribute("damage penalty", 0.65, -1);
			// Delfite: The escape plan already uses the "provide on active" attribute, so there's no need to include it here.
		}
	}

	function OnDiscard()
    {
        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("movement speed bonus");
            weapon_melee.RemoveAttribute("damage bonus");
            weapon_melee.RemoveAttribute("mod shovel speed boost");
            weapon_melee.RemoveAttribute("self mark for death");
            weapon_melee.RemoveAttribute("damage penalty");
        }
    }
});