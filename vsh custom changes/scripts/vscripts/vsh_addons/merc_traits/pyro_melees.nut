

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_melee = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        if (WeaponIs(weapon_melee, "powerjack"))
        {
            weapon_melee.AddAttribute("heal on kill", 0, -1)
            weapon_melee.AddAttribute("move speed bonus", 1.30, -1)
            weapon_melee.AddAttribute("dmg taken increased", 1, -1)
            weapon_melee.AddAttribute("damage penalty", 0.40, -1)
            weapon_melee.AddAttribute("provide on active", 1, -1)
        }
    }

    function OnDiscard()
    {
        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("heal on kill");
            weapon_melee.RemoveAttribute("move speed bonus");
            weapon_melee.RemoveAttribute("dmg taken increased");
            weapon_melee.RemoveAttribute("damage penalty");
            weapon_melee.RemoveAttribute("provide on active");
        }
    }
});