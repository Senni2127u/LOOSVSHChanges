// Script by: Senni, Delfite.
// With assistance from: Bradasparky, Horiuchi.
// This script handles everything to do with Spy's weapons.
//


characterTraitsClasses.push(class extends CharacterTrait
{
	weapon_primary = null;
	weapon_secondary = null;
	weapon_melee = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnApply()
    {
		weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
		weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
		weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
		local pda2 = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA2);

		// Revolver definitions.
		weapon_primary.AddAttribute("weapon spread bonus", 0.0, -1)
		weapon_primary.AddAttribute("maxammo secondary increased", 2.0, -1)
		if (WeaponIs(weapon_primary, "revolver"))
		{
			weapon_primary.AddAttribute("damage bonus", 2.0, -1)
			weapon_primary.AddAttribute("fire rate bonus", 0.85, -1)
			weapon_primary.AddAttribute("reload time decreased", 0.85, -1)
		}
		else if (WeaponIs(weapon_primary, "ambassador"))
		{
			weapon_primary.AddAttribute("damage penalty", 0.8, -1)
			weapon_primary.AddAttribute("headshot damage increase", 2.25, -1)
			weapon_primary.AddAttribute("crit_dmg_falloff", 0, -1)
			weapon_primary.AddAttribute("reload time decreased", 0.85, -1)
		}
		else if (WeaponIs(weapon_primary, "diamondback"))
		{
			weapon_primary.AddAttribute("damage penalty", 1.0, -1)
		}
		else if (WeaponIs(weapon_primary, "enforcer"))
		{
			weapon_primary.AddAttribute("fire rate penalty", 1.0, -1)
		}
		else if (WeaponIs(weapon_primary, "letranger"))
		{
			// Delfite: Nothing. This revolver already serves its purpose very well.
		}

		// Sapper definitions.
		if (WeaponIs(weapon_secondary, "sapper"))
        {
            // weapon_secondary.AddAttribute("move speed bonus", 1.25, -1)
            // weapon_secondary.AddAttribute("provide on active", 1, -1)
        }
		else if (WeaponIs(weapon_secondary, "red_tape_recorder"))
		{

		}

		// Watch definitions.
        if (WeaponIs(pda2, "invis_watch"))
        {
            pda2.AddAttribute("mult decloak rate", -5, -1)
        }
        else if (WeaponIs(pda2, "cloak_and_dagger"))
        {
            pda2.AddAttribute("set cloak is movement based", 0, -1);
            pda2.AddAttribute("mult cloak meter regen rate", 1, -1);
            pda2.AddAttribute("NoCloakWhenCloaked", 1, -1);
            pda2.AddAttribute("ReducedCloakFromAmmo", 1, -1);
        }
		player.Regenerate(true)
    }

	// TODO: Reduce backstab damage based on how many spies are within a certain radius of Hale.
    // Turns out, spies who work together become very powerful since they take up Hale's attention. Even good Hales struggle against
    // multiple spies due to only being able to focus on one at a time. Trolldiers have the same issue with spies acting as a powerful
    // distraction, so a nerf may be needed for them as well.

    // foreach (player in GetAliveMercs())
    // {
    //     if (player.GetPlayerClass() == TF_CLASS_SPY)
    //         vsh_vscript.spies++
    // }

	function OnFrameTickAlive()
    {
        StealthThink()
    }

	function OnDamageTaken(attacker, params)
    {
        if (player.InCond(TF_COND_STEALTHED) && IsBoss(attacker))
            params.damage *= 0.5;

        // Delfite: Decloak the player if they get hit by Saxton Punch! so they have a chance to save themselves from the ensuing fall.
		if (params.inflictor == custom_dmg_saxton_punch && player.IsStealthed())
		{
			RunWithDelay2(this, 0.1, function ()
			{
				player.RemoveCond(TF_COND_STEALTHED)
				EmitSoundOnClient("Weapon_Sapper.Removed", player)

				// Delfite: Stop the player from accidentally re-cloaking during the fall.
				SetPropFloat(player, "m_Shared.m_flStealthNextChangeTime", Time() + 2.0);
			})
		}
    }

	function StealthThink()
	{
		if (player.IsStealthed())
			player.RemoveCondEx(TF_COND_OFFENSEBUFF, true)
	}

	function OnDiscard()
	{
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("move speed bonus");
            weapon_primary.RemoveAttribute("provide on active");
            //printdev("Secondary attributes discarded.")
        }

        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("move speed bonus");
            weapon_secondary.RemoveAttribute("provide on active");
            //printdev("Secondary attributes discarded.")
        }
	}
});