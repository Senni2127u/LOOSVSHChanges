//Script by Senni
// Handles Claidheamh Mor's on kill effects being on hit instead.
// Requires modification to weapons.nut to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        if (WeaponIs(weapon, "claidheamh_mor"))
        {
            weapon.AddAttribute("charge meter on hit" 0.25, -1);
        }
    }
});