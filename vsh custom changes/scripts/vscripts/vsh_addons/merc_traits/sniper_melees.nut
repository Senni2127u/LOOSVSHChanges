//Copyright: Delfite

::Huntsman_Resistance_Factor <- 0.7

characterTraitsClasses.push(class extends CharacterTrait
{
    // weapon_melee = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SNIPER;
    }

    function OnApply()
    {
        // weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        if (WeaponIs(weapon_melee, "kukri"))
        {
			weapon_melee.AddAttribute("speed boost when active", 1.2, -1)
        }
        if (WeaponIs(weapon_melee, "tribalmans_shiv"))
        {
			weapon_melee.AddAttribute("fire rate bonus", 0.7, -1)
        }
        if (WeaponIs(weapon_melee, "shahanshah"))
        {
			weapon_melee.AddAttribute("dmg bonus while half dead", 1.5, -1)
			weapon_melee.AddAttribute("dmg penalty while half alive", 0.5, -1)
        }
        player.Regenerate(true)
    }

    function OnDiscard()
    {
        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("move speed bonus");
        }
    }
});