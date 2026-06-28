// Script by Lizard of Oz, modified partially by Senni.
// Handles Manmelter's critical hit storage.
// Requires modification of weapons.nut to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    damageAccumulated = 0;
    lastHitWasPrimary = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnDamageDealt(victim, params)
    {
        lastHitWasPrimary = player != victim && WeaponIs(params.weapon, "any_flamethrower"); // Catch for all flamethrowers in weapons.nut override, including Dragon's Fury.
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (lastHitWasPrimary)
        {
            damageAccumulated += params.damageamount;
            while (damageAccumulated >= 200)
            {
                AddPropInt(player, "m_Shared.m_iRevengeCrits", 2);
                damageAccumulated -= 200;
            }
        }
    }
});