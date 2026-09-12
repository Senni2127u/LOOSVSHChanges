// Script by: Delfite, Bradasparky.
// This handy little script tracks your current damage-per-second and prints it to your HUD.


characterTraitsClasses.push(class extends CharacterTrait
{
    damageCounter = null;
	damageLastTick = 0;

    function OnApply()
    {
        damageCounter = [];
    }

    function OnHurtDealtEvent(victim, params)
    {
        damageLastTick += params.damageamount
        // victim.SetHealth(1000)
        // printl(damageLastTick)
    }

    function OnFrameTickAliveOrDead()
    {
        damageCounter.push(damageLastTick);
        if (damageCounter.len() > 66)
            damageCounter.remove(0)

        damageLastTick = 0

        local totalDamage = 0
        foreach (v in damageCounter)
            totalDamage += v

        ClientPrint(player, 4, "Total Damage: " + totalDamage)
    }
})