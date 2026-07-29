// This script handles directory information for custom VSH scripts that are different from the base scripts.

// Saxton Hale Scripts
IncludeScript("vsh_addons/boss_traits/airblast_stun.nut")
IncludeScript("vsh_addons/boss_traits/damage_scaling_rewrite.nut")

// Scout Scripts
IncludeScript("vsh_addons/merc_traits/scout_primaries.nut")
IncludeScript("vsh_addons/merc_traits/scout_secondaries.nut")

// Soldier Scripts
IncludeScript("vsh_addons/merc_traits/soldier_gunboats.nut")
IncludeScript("vsh_addons/merc_traits/soldier_primaries.nut")
IncludeScript("vsh_addons/merc_traits/soldier_secondaries.nut")
IncludeScript("vsh_addons/merc_traits/soldier_melees.nut")
IncludeScript("vsh_addons/merc_traits/soldier_banners.nut")
IncludeScript("vsh_addons/merc_traits/soldier_base_jumper.nut")

// Pyro Scripts
IncludeScript("vsh_addons/merc_traits/pyro_primaries.nut")
IncludeScript("vsh_addons/merc_traits/pyro_secondaries.nut")
IncludeScript("vsh_addons/merc_traits/pyro-axtinguisher_hp_refresh.nut")
IncludeScript("vsh_addons/merc_traits/pyro_manmelter_accumulation.nut")
IncludeScript("vsh_addons/merc_traits/pyro_melees.nut")

// Demoman Scripts
IncludeScript("vsh_addons/merc_traits/demoman_grenade_launchers.nut")
IncludeScript("vsh_addons/merc_traits/demoman_stickybomb_launchers.nut")
IncludeScript("vsh_addons/merc_traits/demoman_melees.nut")
IncludeScript("vsh_addons/merc_traits/demoman_caber_recharge.nut")
IncludeScript("vsh_addons/merc_traits/demoman_base_jumper.nut")
// Boot and Shield scripts can be found in main_pre.nut, since they're both overrides.

// Heavy Scripts
IncludeScript("vsh_addons/merc_traits/heavy_primaries.nut")
IncludeScript("vsh_addons/merc_traits/heavy_secondaries.nut")
IncludeScript("vsh_addons/merc_traits/heavy_melees.nut")

// Engineer Scripts
IncludeScript("vsh_addons/merc_traits/engineer_primaries.nut")
IncludeScript("vsh_addons/merc_traits/engineer_secondaries.nut")
IncludeScript("vsh_addons/merc_traits/engineer_pda.nut")

// Medic Scripts
IncludeScript("vsh_addons/merc_traits/medic_primaries.nut")
IncludeScript("vsh_addons/merc_traits/medic_secondaries.nut")
IncludeScript("vsh_addons/merc_traits/medic_melees.nut")

// Sniper Scripts
IncludeScript("vsh_addons/merc_traits/sniper_primaries.nut")
IncludeScript("vsh_addons/merc_traits/sniper_smgs.nut")

// Spy Scripts
IncludeScript("vsh_addons/merc_traits/spy_primaries.nut")
IncludeScript("vsh_addons/merc_traits/spy_sappers.nut")
IncludeScript("vsh_addons/merc_traits/spy_watches.nut")

//Multi-Class Scripts


// Map Scripts
IncludeScript("map_addons/distillery/distillery_heavyblocker.nut")

// Miscellaneous Scripts
IncludeScript("vsh_addons/miscellaneous/vsh_boss_damage_top3_no_log.nut")
IncludeScript("vsh_addons/miscellaneous/revealplayersat3left.nut")
IncludeScript("vsh_addons/miscellaneous/developers.nut")




// IncludeScript("vsh_addons/merc_traits/soldier_haste.nut") // Delfite: Load this script last so we don't overwrite attributes already applied to weapons.
//Uncomment below line to make sure changes are being loaded.

//printl("Main script loaded");

