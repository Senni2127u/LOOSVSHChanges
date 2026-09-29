// This script handles directory information for custom VSH scripts that are different from the base scripts.

// Saxton Hale Scripts
IncludeScript("vsh_addons/boss_traits/airblast_stun.nut")
IncludeScript("vsh_addons/boss_traits/damage_scaling_rewrite.nut")

// Scout Scripts
IncludeScript("vsh_addons/merc_traits/scout_weapons.nut")

// Soldier Scripts
IncludeScript("vsh_addons/merc_traits/soldier_weapons.nut")

// Pyro Scripts
IncludeScript("vsh_addons/merc_traits/pyro_weapons.nut")

// Demoman Scripts
IncludeScript("vsh_addons/merc_traits/demoman_weapons.nut")

// Heavy Scripts
IncludeScript("vsh_addons/merc_traits/heavy_weapons.nut")

// Engineer Scripts
IncludeScript("vsh_addons/merc_traits/engineer_weapons.nut")

// Medic Scripts
IncludeScript("vsh_addons/merc_traits/medic_weapons.nut")

// Sniper Scripts
IncludeScript("vsh_addons/merc_traits/sniper_weapons.nut")

// Spy Scripts
IncludeScript("vsh_addons/merc_traits/spy_weapons.nut")

//Multi-Class Scripts
IncludeScript("vsh_addons/merc_traits/__player_traits.nut")


// Map Scripts
IncludeScript("map_addons/distillery/distillery_heavyblocker.nut")

// Miscellaneous Scripts
IncludeScript("vsh_addons/miscellaneous/vsh_boss_damage_top3_no_log.nut")
IncludeScript("vsh_addons/miscellaneous/vsh_healing_top3_no_log.nut")
IncludeScript("vsh_addons/miscellaneous/reveal_players_at_3_left.nut")
IncludeScript("vsh_addons/miscellaneous/developers.nut")
IncludeScript("vsh_addons/miscellaneous/debug_print.nut")
// IncludeScript("vsh_addons/miscellaneous/dps_tracker.nut")




// IncludeScript("vsh_addons/merc_traits/soldier_haste.nut") // Delfite: Load this script last so we don't overwrite attributes already applied to weapons.
//Uncomment below line to make sure changes are being loaded.

//printdev("Main script loaded");

