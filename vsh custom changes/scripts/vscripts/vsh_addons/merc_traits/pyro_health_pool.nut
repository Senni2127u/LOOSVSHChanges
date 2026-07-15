// Script by Senni, Assistance from Bradasparky
// Script handles Pyro HP change.
// Modifications required to weapons.nut

characterTraitsClasses.push(class extends CharacterTrait
{
	
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        RunWithDelay2(this, 0.01, function() //This delay is needed because of how the game handles spawning, it wouldn't apply the health bonus if done immediate.
        {
            local primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
            if (WeaponIs(primary, "any_flamethrower")) //Reason for this is if the CanApply check fails.
                {
                    primary.AddAttribute("max health additive bonus", 25, -1);
			        primary.AddAttribute("patient overheal penalty", 0.60, -1);
                    player.SetHealth(200);
                }
        });	
    }

	function OnTickAlive(timeDelta) // Function fixes issue where Medic gets increased charge because the patient's overheal amount, is not the "full" amount.
    {
        Overheal = false
        local health = player.GetHealth()

    if (health == 260 && !Overheal)
        {
            Overheal = true
            player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
            //printl("Pyro's HP is at 260, reducing charge rate for Medic.") //Debug.
        }
    else if (health == 258) //Reason we check for 258 is because the game will periodically drop Medic's patient to -1 overheal point for a tick and go back to the full amount.
        {
            Overheal = false
            player.AddCustomAttribute("ubercharge rate bonus for healer", 1, -1)
            //printl("Pyro's HP is at 258 or below, returning charge rate to normal.") //Another debug.
        }
	}
});

