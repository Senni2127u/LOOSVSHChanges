// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's Black Box HP on hit increase.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "rocket_launcher"))
        {
            weapon_primary.AddAttribute("reload time decreased" 0.75, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
        }
        if (WeaponIs(weapon_primary, "black_box"))
        {
            weapon_primary.AddAttribute("health on radius damage" 50, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
        }
        if (WeaponIs(weapon_primary, "beggars_bazooka"))
        {
            weapon_primary.AddAttribute("projectile spread angle penalty" 0, -1);
            weapon_primary.AddAttribute("Projectile speed increased", 1.25, -1);
            weapon_primary.AddAttribute("reload time decreased", 0.75, -1);
        }
        if (WeaponIs(weapon_primary, "air_strike"))
        {
            weapon_primary.AddAttribute("Projectile speed increased", 1.4, -1);
        }
        if (WeaponIs(weapon_primary, "liberty_launcher"))
        {
            weapon_primary.AddAttribute("Projectile speed increased", 1.65, -1);
            weapon_primary.AddAttribute("rocket jump damage reduction", 0.4, -1);
        }
        if (WeaponIs(weapon_primary, "direct_hit"))
        {
            weapon_primary.AddAttribute("Projectile speed increased", 2.0, -1)
        }
        player.Regenerate(true)
    }

    function OnDiscard()
    {
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("reload time decreased");
            weapon_primary.RemoveAttribute("Projectile speed increased");
            weapon_primary.RemoveAttribute("health on radius damage");
            weapon_primary.RemoveAttribute("projectile spread angle penalty");
        }
    }
});