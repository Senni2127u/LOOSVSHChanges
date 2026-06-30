::is_thorne <- GetMapName().find("vsh_thorne") == 0;

this.Include <- function(path)
{
	if (is_thorne)
	{
		IncludeScript("vssaxtonhale/" + path);
		return;
	}

	switch (path)
	{
		case "__lizardlib/character_trait.nut":
		case "__lizardlib/game_events.nut":
		case "__lizardlib/weapons.nut":
		case "/bosses/saxton_hale/abilities/saxton_punch.nut":
		case "/bosses/saxton_hale/abilities/sweeping_charge.nut":
		case "/mercs/merc_traits/single_class/demo_shield.nut":
		case "/mercs/merc_traits/single_class/demo_jumper_ammo.nut":
		case "/mercs/merc_traits/single_class/heavy_received_knockback.nut":
		case "/mercs/merc_traits/single_class/heavy_natasha_nerf.nut":
		case "/mercs/merc_traits/single_class/medic_resistance.nut":

        // Dummy case to catch all of the above, add more if you wish
        // Make sure the dir matches the original path. Ex: "/mercs/..." as opposed to "mercs/..."
		case "fallthrough":
        {
            // Slice the / down here so it includes properly (might not be necessary)
            if (path[0] == '/')
                path = path.slice(1);

            // Uncomment the print below to verify in console that
            // all the files that SHOULD be included, are included

            //printl("Including: vsh_overrides/" + path + "\n");
            IncludeScript("vsh_overrides/" + path);
            return;
        }
	}

	IncludeScript("vssaxtonhale/" + path);
}
