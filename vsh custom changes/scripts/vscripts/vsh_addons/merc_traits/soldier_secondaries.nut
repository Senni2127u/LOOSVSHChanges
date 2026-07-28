// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's Black Box HP on hit increase.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_secondary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnApply()
    {
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);

        if (WeaponIs(weapon_secondary, "shotgun"))
        {
            weapon_secondary.AddAttribute("damage bonus" 1.40, -1);
            weapon_secondary.AddAttribute("weapon spread bonus", 0.70, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.85, -1);
        }
        if (WeaponIs(weapon_secondary, "reserve_shooter"))
        {
            weapon_secondary.AddAttribute("weapon spread bonus" 0.70, -1);
        }
        if (WeaponIs(weapon_secondary, "panic_attack"))
        {
            weapon_secondary.AddAttribute("weapon spread bonus" 0.6, -1);
			weapon_secondary.AddAttribute("damage penalty", 1.0, -1);
        }
        if (WeaponIs(weapon_secondary, "righteous_bison"))
        {
            // weapon_secondary.AddAttribute("damage bonus", 4, -1);
            weapon_secondary.AddAttribute("Projectile speed increased", 2.0, -1);
            weapon_secondary.AddAttribute("fire rate bonus", 0.80, -1);
            weapon_secondary.AddAttribute("reload time decreased", 0.80, -1);
        }
        player.Regenerate(true)
    }

    function OnDiscard()
    {
        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("reload time decreased");
            weapon_secondary.RemoveAttribute("Projectile speed increased");
            weapon_secondary.RemoveAttribute("damage bonus");
            weapon_secondary.RemoveAttribute("weapon spread bonus");
            weapon_secondary.RemoveAttribute("damage penalty");
        }
    }
});