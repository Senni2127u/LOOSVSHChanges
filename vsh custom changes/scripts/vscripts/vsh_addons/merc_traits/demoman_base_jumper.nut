characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        if (WeaponIs(weapon, "base_jumper_demoman"))
        {
            	weapon.AddAttribute("max health additive bonus", 25, -1)
				weapon.AddAttribute("rocket jump damage reduction", 0.40, -1)
                player.Regenerate(true)
        }
    }
});