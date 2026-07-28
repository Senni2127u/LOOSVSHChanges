//Script by Senni
// Handles Claidheamh Mor's on kill effects being on hit instead.
// Requires modification to weapons.nut to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    weapon_melee = null;
    meleeIsClaidheamhMor = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        if (WeaponIs(weapon_melee, "claidheamh_mor"))
        {
            // weapon.AddAttribute("charge meter on hit" 0.25, -1);
            weapon_melee.AddAttribute("dmg taken increased" 1.0, -1);
            meleeIsClaidheamhMor = true;
        }
        if (WeaponIs(weapon_melee, "ullapool_caber"))
        {
            weapon_melee.AddAttribute("rocket jump damage reduction", 0.75, -1)
        }
    }

    // Delfite: Instead of applying the "charge on hit" attribute to demo's current melee, we'll just add charge via NetProps.
	function OnDamageDealt(victim, params)
    {
        if (params.damage_type & 128 && meleeIsClaidheamhMor)
            SetPropFloat(player, "m_Shared.m_flChargeMeter", clampCeiling(100.0, GetPropFloat(player, "m_Shared.m_flChargeMeter") + 25.0))
    }

    function OnDiscard()
    {
        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("dmg taken increased");
            weapon_melee.RemoveAttribute("rocket jump damage reduction");
        }
    }
});