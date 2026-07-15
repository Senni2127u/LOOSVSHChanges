//Copyright Delfite, Senni, Bradasparky
// Handles Heavy's spin down time being reduced.
// No required modification to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_HEAVYWEAPONS;
    }

function OnFrameTickAlive(timeDelta)
{
    local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
    if (weapon)
    {
        if (weapon && GetPropInt(weapon, "m_iWeaponState") == 0)
        {
            SetPropFloat(weapon, "m_flTimeWeaponIdle", 0.0)
        }
    }

    // Checking value of Idle netprop.
    //local value = NetProps.GetPropFloat(weapon, "m_flTimeWeaponIdle");
    //printl(value);
}
});
