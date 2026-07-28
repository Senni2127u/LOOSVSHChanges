//Copyright: Delfite (I don't care if you use this code. Open source stuff quite literally runs the world.)


characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;

	function CanApply()
	{
		return player.GetPlayerClass() == TF_CLASS_ENGINEER
	}

	function OnApply()
	{
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

		if (WeaponIs(weapon_primary, "shotgun"))
		{
			weapon_primary.AddAttribute("damage bonus", 1.40, -1);
			weapon_primary.AddAttribute("weapon spread bonus", 0.7, -1);
			weapon_primary.AddAttribute("reload time decreased", 0.85, -1);
		}
		if (WeaponIs(weapon_primary, "panic_attack"))
		{
			weapon_primary.AddAttribute("weapon spread bonus", 0.6, -1);
			weapon_primary.AddAttribute("damage penalty", 1.0, -1);
		}
		if (WeaponIs(weapon_primary, "rescue_ranger"))
		{
			weapon_primary.AddAttribute("mark for death on building pickup", 0, -1)
		}
		if (WeaponIs(weapon_primary, "pomson_6000"))
		{
			// weapon_primary.AddAttribute("damage bonus", 3, -1)
			weapon_primary.AddAttribute("fire rate bonus", 0.8, -1)
			weapon_primary.AddAttribute("reload time decreased", 0.8, -1)
			weapon_primary.AddAttribute("Projectile speed increased", 2.0, -1)
		}
	}

	function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("weapon spread bonus");
            weapon_primary.RemoveAttribute("reload time decreased");
            weapon_primary.RemoveAttribute("fire rate bonus");
            weapon_primary.RemoveAttribute("mark for death on building pickup");
            weapon_primary.RemoveAttribute("damage penalty");
        }
    }
});