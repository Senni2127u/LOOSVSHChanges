// Script by: Delfite.
// With help from: Bradasparky.
// This script allows you to override and add any attribute you want to Hale and his fists, though its primary function is
// to fix an oversight in Hale's melee range not actually getting buffed by the "melee range multiplier" and
// "melee bounds multiplier" attributes, since apparently neither one works when applied as a player attribute.


::OldHaleWeaponFunc <- ::TF_CUSTOM_WEAPONS_REGISTRY["Hale's Own Fists"].func;
function HaleWeaponFunc(weapon, player)
{
    OldHaleWeaponFunc(weapon, player);
    weapon.AddAttribute("melee range multiplier", 1.2, -1)
    weapon.AddAttribute("melee bounds multiplier", 1.1, -1)
    // printdev("Melee range fix applied to Hale.");

    // Developer-specific attributes
	switch (GetPlayerSteamIDFromParams(player))
    {
        case SENNI:
        case LANKO:
        case LIZARDOFOZ:
            player.AddCustomAttribute("turn to gold", 1, -1)
			// printdev("Developer attributes applied to Hale.");
        break;

        case DELFITE:
            player.AddCustomAttribute("ragdolls become ash", 1, -1)
			// printdev("Developer attributes applied to Hale.");

            // Delfite: Most unusual effects can't be parented to the player or weapon properly via AddCustomAttribute or AddAttribute and
            // will just appear at the player's center. Effects that follow the player's bones, however, *do* parent correctly.
            // Unusual effect index list: https://tf2b.com/pelist.php
            // Unusual effect wiki page: https://wiki.teamfortress.com/wiki/Unusual
            // Flying Bits: 2
            // Aurora Australis: 3071
            // Prismatic Haze: 3097
            player.AddCustomAttribute("attach particle effect", 2, -1)
            // if (player.GetTeam() == TF_TEAM_BLUE)
            //     player.AddCustomAttribute("attach particle effect", 3206, -1)
            // else
            //     player.AddCustomAttribute("attach particle effect", 3207, -1)
        break;

        default:
        break;
    }
}
::TF_CUSTOM_WEAPONS_REGISTRY["Hale's Own Fists"].func = HaleWeaponFunc;