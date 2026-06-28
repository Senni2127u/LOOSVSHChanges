// Script by Senni, Assistance from Bradasparky
// Script handles Pyro HP change, sets Pyro's HP to 200 at the start of the round as his base is usually 175, decreases overheal to 10% of normal as compensation.
// No required modification to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
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
});

// Uncomment print line to make sure script is functioning if edits are made.
//printl ("Pyro Health Pool trait loaded\n");