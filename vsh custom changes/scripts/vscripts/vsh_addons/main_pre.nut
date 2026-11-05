// Delfite: Due to unforeseen consequences, attempting to run the gamemode with
// our scripts on a Listen Server will cause it to crash. This check will stop the crash,
// but it will also stop you from testing your changes outside of a Dedicated Server.
// If anyone can figure out why the crashes happen, make an Issue on the Github about it.
if (!IsDedicatedServer())
	return;

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
		// Delfite: Do not override `constants.nut`! Doing so will put the mercs and Hale on the wrong teams for certain maps.
		// case "__lizardlib/constants.nut":
		case "__lizardlib/game_events.nut":
		case "__lizardlib/listeners.nut":
		case "__lizardlib/netprops.nut":
		case "__lizardlib/player_util.nut":
		case "__lizardlib/util.nut":
		case "__lizardlib/weapons.nut":
		case "_gamemode/boss_queue.nut":
		case "_gamemode/forced_arena.nut":
		// Delfite: WARNING! Do not override `saxton_hale.nut` unless you know what you're doing!
		// Some maps store custom abilities, models, and sound effects in that script. Don't touch it
		// unless absolutely necessary!
		// case "/bosses/saxton_hale/saxton_hale.nut":
		case "/bosses/saxton_hale/misc/colored_arms.nut":
		case "/bosses/generic/passives/aoe_punch.nut":
		case "/bosses/generic/passives/debuff_resistance.nut":
		case "/bosses/generic/passives/head_stomp.nut":
		case "/bosses/generic/passives/received_damage_scaling.nut":
		case "/bosses/generic/passives/stun_breakout.nut":
		case "/bosses/saxton_hale/abilities/mighty_slam.nut":
		case "/bosses/saxton_hale/abilities/saxton_punch.nut": // Extender fix.
		case "/bosses/saxton_hale/abilities/sweeping_charge.nut": // Extender fix.
		case "/mercs/merc_traits/single_class/demo_boots.nut":
		case "/mercs/merc_traits/single_class/demo_head_collecting.nut":
		case "/mercs/merc_traits/single_class/demo_jumper_ammo.nut":
		case "/mercs/merc_traits/single_class/demo_katana.nut":
		case "/mercs/merc_traits/single_class/demo_shield.nut":
		case "/mercs/merc_traits/single_class/engineer_sentry.nut":
		case "/mercs/merc_traits/single_class/engineer_telefrag_scaling.nut":
		case "/mercs/merc_traits/single_class/heavy_kgb_crits.nut":
		case "/mercs/merc_traits/single_class/heavy_minigun_nerf.nut":
		case "/mercs/merc_traits/single_class/heavy_natasha_nerf.nut":
		case "/mercs/merc_traits/single_class/heavy_received_knockback.nut":
		case "/mercs/merc_traits/single_class/heavy_warriors_spirit.nut":
		case "/mercs/merc_traits/single_class/medic_resistance.nut":
		case "/mercs/merc_traits/single_class/medic_uber_rate.nut":
		case "/mercs/merc_traits/single_class/pyro_powerjack.nut":
		case "/mercs/merc_traits/single_class/scout_candy_cane.nut":
		case "/mercs/merc_traits/single_class/scout_stronger_fan.nut":
		case "/mercs/merc_traits/single_class/sniper_focus.nut":
		case "/mercs/merc_traits/single_class/sniper_head_collecting.nut":
		case "/mercs/merc_traits/single_class/soldier_airstrike.nut":
		case "/mercs/merc_traits/single_class/soldier_jumper_ammo.nut":
		case "/mercs/merc_traits/single_class/soldier_market_gardener.nut":
		case "/mercs/merc_traits/single_class/spy_backstab.nut":
		case "/mercs/merc_traits/single_class/spy_invis_res.nut":
		case "/mercs/merc_traits/all_class/airborne_minicrits.nut":
		case "/mercs/merc_traits/all_class/melee_buffs.nut": // Wallclimb melee range buff.
		case "/mercs/merc_traits/all_class/last_mann_standing.nut":
		case "/mercs/voice_lines/single_class/demo_trap_cheer.nut":
		case "/mercs/voice_lines/single_class/sniper_run.nut":
		case "/mercs/voice_lines/all_class/silent_tie.nut":
		case "/mercs/voice_lines/all_class/tracing_boss.nut":
		case "/mercs/voice_lines/all_class/victory.nut":
		case "/mercs/voice_lines/all_class/wall_climb.nut":

        // Dummy case to catch all of the above, add more if you wish
        // Make sure the dir matches the original path. Ex: "/mercs/..." as opposed to "mercs/..."
		case "fallthrough":
        {
            // Slice the / down here so it includes properly (might not be necessary)
            if (path[0] == '/')
                path = path.slice(1);

            // Uncomment the print below to verify in console that
            // all the files that SHOULD be included, are included

            //printdev("Including: vsh_overrides/" + path + "\n");
            IncludeScript("vsh_overrides/" + path);
            return;
        }
	}

	IncludeScript("vssaxtonhale/" + path);
}
