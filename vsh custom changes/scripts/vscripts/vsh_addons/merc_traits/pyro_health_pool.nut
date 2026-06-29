// Script by Senni, Assistance from Bradasparky
// Script handles Pyro HP change, sets Pyro's HP to 200 at the start of the round as his base is usually 175, decreases overheal to 10% of normal as compensation.
// No required modification to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
	PyroOverheal = false
	
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        RunWithDelay2(this, 0.01, function()
        {
          local flamethrower = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        if (flamethrower)
        {
            flamethrower.AddAttribute("max health additive bonus", 25, -1);
			flamethrower.AddAttribute("patient overheal penalty", 0.60, -1);
            player.SetHealth(200);
        }
        });	
    }

	function OnTickAlive(timeDelta)
    {
    if (player.GetHealth() == 260 && !PyroOverheal) // fixes issue with Overheal penalty where Medic gets increased charge rate because the patient's overheal current amount, is not the full overheal.
        {
            PyroOverheal = true
            player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
            //printl("Pyro's HP is at 260, reducing charge rate for Medic.") //Debug.
        }
    else if (player.GetHealth() == 259)
        {
            PyroOverheal = false
            player.AddCustomAttribute("ubercharge rate bonus for healer", 1, -1)
            //printl("Pyro's HP at 259 or below, returning charge rate to normal.") //Another debug.
        }
	}
});

// Uncomment print line to make sure script is functioning if edits are made.
//printl ("Pyro Health Pool trait loaded\n");
