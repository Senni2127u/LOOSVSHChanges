// Script by: Senni, Delfite, with assistance from Bradasparky
// This script handles everything to do with Pyro's primaries.

characterTraitsClasses.push(class extends CharacterTrait
{
	isUberRatePenaltyApplied = false;
	primaryIsPhlog = false;
	primaryIsDragonsFury = false;

    // weapon_primary = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnApply()
    {
        // weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        if (WeaponIs(weapon_primary, "flamethrower"))
        {
			weapon_primary.AddAttribute("patient overheal penalty", 0.60, -1);
        }
        if (WeaponIs(weapon_primary, "backburner"))
        {
			weapon_primary.AddAttribute("patient overheal penalty", 0.60, -1);
        }
        if (WeaponIs(weapon_primary, "degreaser"))
        {
			weapon_primary.AddAttribute("patient overheal penalty", 0.60, -1);
        }
        if (WeaponIs(weapon_primary, "phlog"))
        {
            primaryIsPhlog = true;
        }
        if (WeaponIs(weapon_primary, "dragons_fury"))
        {
            primaryIsDragonsFury = true;
        }
        player.Regenerate(true);
    }

	function OnFrameTickAlive()
    {
        if (primaryIsPhlog || primaryIsDragonsFury)
            return;

        local patient_health = player.GetHealth()
        // Fixes an issue with the "patient overheal penalty" attribute where Medic gets increased ubercharge rate
        // due to the patient's overheal not technically being "full."
        if (patient_health == 260 && !isUberRatePenaltyApplied)
        {
            player.AddCustomAttribute("ubercharge rate bonus for healer", 0.5, -1)
            isUberRatePenaltyApplied = true
            //printl("Pyro's HP is at 260, reducing charge rate for Medic.") //Debug.
        }
        else if (patient_health <= 258 && isUberRatePenaltyApplied)
        {
            player.AddCustomAttribute("ubercharge rate bonus for healer", 1, -1)
            isUberRatePenaltyApplied = false
            //printl("Pyro's HP at 258 or below, returning charge rate to normal.") //Another debug.
        }
        // printl(player.GetAttribute("ubercharge rate bonus for healer", 1.0))
	}
});

// Uncomment print line to make sure script is functioning if edits are made.
//printl ("pyro_primaries.nut loaded.\n");
