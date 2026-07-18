// Script by Senni, Assistance from Bradasparky
// Script handles Pyro HP change, sets Pyro's HP to 200 at the start of the round as his base is usually 175, decreases overheal to 10% of normal as compensation.
// No required modification to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
	Overheal = false
	
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        RunWithDelay2(this, 0.01, function()
        {
            local primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
            if (WeaponIs(primary, "any_flamethrower"))
            {
                primary.AddAttribute("max health additive bonus", 25, -1);
			    primary.AddAttribute("patient overheal penalty", 0.60, -1);
                player.SetHealth(200);
            }
        });	
    }

	function OnTickAlive(timeDelta) // This function fixes an issue where a overheal penalty applied player will give Medic more Ubercharge rate than others.
    {
        local health = player.GetHealth()
        if (health == 260 && !Overheal)
            {
                Overheal = true
                player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
                //printl("Pyro's HP is at 260, reducing charge rate for Medic.") //Debug.
            }
        else if (health == 258)
            {
                Overheal = false
                player.AddCustomAttribute("ubercharge rate bonus for healer", 1, -1)
                //printl("Pyro's HP at 259 or below, returning charge rate to normal.") //Another debug.
            }
	}
});
