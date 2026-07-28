//Copyright Delfite, Senni, Bradasparky
// Handles Heavy's spin down time being reduced.
// No required modification to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "huo_long_heater"))
        {
            weapon_primary.AddAttribute("uses ammo while aiming", 0, -1);
        }
        if (WeaponIs(weapon_primary, "brass_beast"))
        {
            weapon_primary.AddAttribute("aiming movespeed decreased", 0.80, -1);
        }
    }

    function OnFrameTickAlive()
    {
        // Checking value of Idle netprop.
        if (weapon_primary && GetPropInt(weapon_primary, "m_iWeaponState") == 0)
        {
            SetPropFloat(weapon_primary, "m_flTimeWeaponIdle", 0.0)
            //local value = NetProps.GetPropFloat(weapon_primary, "m_flTimeWeaponIdle");
        }
        //printl(value);
    }
});