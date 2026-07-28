// Script by: Senni, Delfite, with assistance from Bradasparky
// Script handles everything to do with Pyro's primaries.
// No required modification of the base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
	PyroOverheal = false;
    weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "any_flamethrower"))
        {
            weapon_primary.AddAttribute("max health additive bonus", 25, -1);
			weapon_primary.AddAttribute("patient overheal penalty", 0.60, -1);
        }
        player.Regenerate(true);
    }

	function OnFrameTickAlive()
    {
        // Fixes an issue with the "patient overheal penalty" attribute where Medic gets increased ubercharge rate
        // due to the patient's overheal not technically being "full."
        if (player.GetHealth() == 260 && !PyroOverheal)
        {
            PyroOverheal = true
            player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
            //printl("Pyro's HP is at 260, reducing charge rate for Medic.") //Debug.
        }
        else if (player.GetHealth() <= 258 && PyroOverheal)
        {
            PyroOverheal = false
            player.AddCustomAttribute("ubercharge rate bonus for healer", 1, -1)
            //printl("Pyro's HP at 258 or below, returning charge rate to normal.") //Another debug.
        }
	}
});

// Uncomment print line to make sure script is functioning if edits are made.
//printl ("Pyro Health Pool trait loaded\n");
