// Script by Senni, Assistance from Bradasparky/Horiuchi
// Script handles Pyro's Gas Passer exploding on ignite, slightly reduces charge rate and sets the damage for a full charge to 800 instead of typical 750.
// This script requires modification of weapons.nut to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_secondary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
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
        if (WeaponIs(weapon_secondary, "gas_passer"))
        {
            weapon_secondary.AddAttribute("explode_on_ignite", 1, -1);
            weapon_secondary.AddAttribute("single wep deploy time decreased", 0.85, -1);
            weapon_secondary.AddAttribute("switch from wep deploy time decreased", 0.85, -1);
            weapon_secondary.AddAttribute("item_meter_damage_for_full_charge", 800, -1);
        }
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