// Script by Senni, some code adapted from Lizard of Oz's code.
// Handles Axtinguisher's mechanics towards Hale, grants HP when Hale, while burning, is hit with Axtinguisher.
// This script requires modification to weapons.nut script to function.

characterTraitsClasses.push(class extends CharacterTrait
{
    damageAccumulated = 0;
    lastHitWasAxtinguisher = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnDamageDealt(victim, params)
    {
        lastHitWasAxtinguisher = player != victim && WeaponIs(params.weapon, "axtinguisher");
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (lastHitWasAxtinguisher)
        {
            damageAccumulated += params.damageamount;
            while (damageAccumulated <= 190)
            {
                damageAccumulated = 0;
                return;
            }
        }
        if (lastHitWasAxtinguisher)
        {
            damageAccumulated += params.damageamount;
            while (damageAccumulated >= 191)
            {
            local newHealth = player.GetHealth() + player.GetMaxHealth() / 2.0;
            local maxOverheal = player.GetMaxHealth() * 1
            player.SetHealth(clampCeiling(newHealth, maxOverheal));
                damageAccumulated = 0;
            }
        }
    }
    });