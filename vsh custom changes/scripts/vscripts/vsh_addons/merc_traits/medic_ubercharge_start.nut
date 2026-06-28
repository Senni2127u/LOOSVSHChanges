//Script created by Senni, Assistance from Bradasparky.
//Script handles Medic starting with full ubercharge at the beginning of rounds.
// No required modifications to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_MEDIC;
    }

function OnApply()
{
    local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
    if (weapon)
        SetPropFloat(weapon, "m_flChargeLevel", 1.0)
}
});