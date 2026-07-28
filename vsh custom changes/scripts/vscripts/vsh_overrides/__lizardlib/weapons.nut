//=========================================================================
//Copyright LizardOfOz.
//
//Credits:
//  LizardOfOz - Programming, game design, promotional material and overall development. The original VSH Plugin from 2010.
//  Maxxy - Saxton Hale's model imitating Jungle Inferno SFM; Custom animations and promotional material.
//  Velly - VFX, animations scripting, technical assistance.
//  JPRAS - Saxton model development assistance and feedback.
//  MegapiemanPHD - Saxton Hale and Gray Mann voice acting.
//  James McGuinn - Mercenaries voice acting for custom lines.
//  Yakibomb - give_tf_weapon script bundle (used for Hale's first-person hands model).
//=========//  Phe - game design assistance.
//=========================================================================

//The models list has been deprecated, Delfite made it so we use the indexes instead, but we will leave it here just in case. - Senni.

::weaponModels <- {
}

::SetItemId <- function(item, id)
{
    if (item != null)
        SetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", id);
}

::ClearPlayerWearables <- function(player)
{
    local item = null;
    local itemsToKill = [];
    while (item = FindByClassname(item, "tf_we*"))
    {
        if (item.GetOwner() == player)
            itemsToKill.push(item);
    }
    item = null;
    while (item = FindByClassname(item, "tf_powerup_bottle"))
    {
        if (item.GetOwner() == player)
            itemsToKill.push(item);
    }
    foreach (item in itemsToKill)
        item.Kill();
}

::WeaponIs <- function(weapon, name)
{
    SetPropBool(weapon, "m_bForcePurgeFixedupStrings", true);
    if (weapon == null)
        return false;
    local id = GetItemID(weapon)


    // Dell's Weapon List Navigation and Stylization Guide

    // Every class and weapon slot has a number assigned to it.
    // Values for classes range from 0 (Multi-Class) to 9 (Spy).
    // Values for weapon slots range from 0 (Primary) to 5 (Toolbox).
    // For example: If you wanted to find Heavy's melees quickly, you would press CTRL+F, then type 5,2 into the search bar.
    // Individual weapons do not have numeric identifiers, since at that point you're better off just searching with a string.

    // Speaking of strings, all weapons are assigned a name that's used in the WeaponIs function.
    // Weapon names will never and should never include words such as "The", since most if not all weapons contain it,
    // -and you likely already include it automatically when you say the name of the weapon out loud to someone.

    // Weapon names that would normally be seperated by spaces or dashes should instead have underscores to act as a stand-in.
        // Example: The Scottish Resistance             -> scottish_resistance
        // Example: The Quick-Fix                       -> quick_fix
        // Example: The Force-a-Nature                  -> force_a_nature

    // Some weapon names will have abbreviated/less verbose versions for the sake of faster navigation, but will still have their regular versions available for use.
        // Example: The Gloves of Running Urgently      -> gru        ||  gloves_of_running_urgently
        // Example: The Killing Gloves of Boxing        -> kgb        ||  killing_gloves_of_boxing
        // Example: The Baby Face's Blaster             -> bfb        ||  baby_faces_blaster
        // Example: The Phlogistinator                  -> phlog      ||  phlogistinator
        // Example: The Shahanshah                      -> yatagan    ||  shahanshah

    // Of course, it should go without saying to NEVER include special characters in a weapon's name, and to always keep the names in lowercase.
    // If you wish to add entries to this file, use this list as a reference point: https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes


    //Multi-Class Weapons [0]
    if (name == "shotgun")
        return id == 9      // Engineer's shotgun
            || id == 10     // Soldier's shotgun
            || id == 11     // Heavy's shotgun
            || id == 12     // Pyro's shotgun
            || id == 199
            || id == 1141
            || id == 15003
            || id == 15016
            || id == 15044
            || id == 15047
            || id == 15085
            || id == 15109
            || id == 15132
            || id == 15133
            || id == 15152;
    else if (name == "pistol")
        return id == 22     // Engineer's pistol
            || id == 23     // Scout's pistol
            || id == 160
            || id == 209
            || id == 294
            || id == 15013
            || id == 15018
            || id == 15035
            || id == 15041
            || id == 15046
            || id == 15056
            || id == 15060
            || id == 15061
            || id == 15100
            || id == 15101
            || id == 15102
            || id == 15126
            || id == 15148
            || id == 30666;
    else if (name == "panic_attack")
        return id == 1153;
    else if (name == "reserve_shooter")
        return id == 415;
    else if (name == "base_jumper" || name == "parachute")
        return id == 1101;
    else if (name == "half_zatoichi" || name == "katana")
        return id == 357;
    else if (name == "pain_train")
        return id == 154;


    //Scout Primaries [1,0]
    else if (name == "any_scattergun")
        return weapon.GetClassname() == "tf_weapon_scattergun"
            || weapon.GetClassname() == "tf_weapon_handgun_scout_primary"
            || weapon.GetClassname() == "tf_weapon_soda_popper"
            || weapon.GetClassname() == "tf_weapon_pep_brawler_blaster";
    else if (name == "scattergun")
        return id == 13
            || id == 200
            || id == 669
            || id == 799
            || id == 808
            || id == 888
            || id == 897
            || id == 906
            || id == 915
            || id == 964
            || id == 973
            || id == 15002
            || id == 15015
            || id == 15021
            || id == 15029
            || id == 15036
            || id == 15053
            || id == 15065
            || id == 15069
            || id == 15106
            || id == 15107
            || id == 15108
            || id == 15131
            || id == 15151
            || id == 15157;
    else if (name == "force_a_nature")
        return id == 45
            || id == 1078;
    else if (name == "shortstop")
        return id == 220;
    else if (name == "soda_popper")
        return id == 448;
    else if (name == "baby_faces_blaster" || name == "bfb")
        return id == 772;
    else if (name == "back_scatter" || name == "backscatter")
        return id == 1103;

    //Scout Secondaries [1,1]
    else if (name == "any_drink" || name == "energydrink")
        return weapon.GetClassname() == "tf_weapon_lunchbox_drink";
    else if (name == "mad_milk")
        return id == 222
            || id == 1121;
    else if (name == "bonk_atomic_punch" || name == "bonk")
        return id == 46
            || id == 1145;
    else if (name == "crit_a_cola" || name == "critacola")
        return id == 163;
    else if (name == "flying_guillotine" || name == "guillotine")
        return id == 812
            || id == 833;
    else if (name == "winger")
        return id == 449;
    else if (name == "pretty_boys_pocket_pistol" || name == "pbpp")
        return id == 773;

    //Scout Melees [1,2]
    else if (name == "bat")
        return id == 0
            || id == 190
            || id == 221
            || id == 264
            || id == 474
            || id == 572
            || id == 660
            || id == 423
            || id == 880
            || id == 939
            || id == 954
            || id == 999
            || id == 1013
            || id == 1071
            || id == 1123
            || id == 1127
            || id == 30667
            || id == 30758;
    else if (name == "sandman")
        return id == 44;
    else if (name == "candy_cane")
        return id == 317;
    else if (name == "boston_basher")
        return id == 325
            || id == 452;
    else if (name == "sun_on_a_stick" || name == "soas")
        return id == 349;
    else if (name == "fan_o_war")
        return id == 355;
    else if (name == "atomizer")
        return id == 450;

    //Soldier Primaries [2,0]
    else if (name == "rocket_launcher")
        return id == 18
            || id == 205
            || id == 513
            || id == 658
            || id == 800
            || id == 809
            || id == 889
            || id == 898
            || id == 907
            || id == 916
            || id == 965
            || id == 974
            || id == 15006
            || id == 15014
            || id == 15028
            || id == 15043
            || id == 15052
            || id == 15057
            || id == 15081
            || id == 15104
            || id == 15105
            || id == 15129
            || id == 15130
            || id == 15150;
    else if (name == "direct_hit")
        return id == 127;
    else if (name == "black_box")
        return id == 228
            || id == 1085;
    else if (name == "rocket_jumper")
        return id == 237;
    else if (name == "liberty_launcher")
        return id == 414;
    else if (name == "cow_mangler_5000" || name == "cow_mangler")
        return id == 441;
    else if (name == "beggars_bazooka")
        return id == 730;
    else if (name == "air_strike" || name == "airstrike")
        return id == 1104;

    //Soldier Secondaries [2,1]
    else if (name == "any_banner")
        return weapon.GetClassname() == "tf_weapon_buff_item";
    else if (name == "buff_banner")
        return id == 129
            || id == 1001;
    else if (name == "gunboats")
        return id == 133;
    else if (name == "battalions_backup")
        return id == 226;
    else if (name == "concheror")
        return id == 354;
    else if (name == "righteous_bison")
        return id == 442;
    else if (name == "mantreads")
        return id == 444;

    //Soldier Melees [2,2]
    else if (name == "shovel")
        return id == 6
            || id == 196
            || id == 264
            || id == 423
            || id == 474
            || id == 880
            || id == 939
            || id == 954
            || id == 1013
            || id == 1071
            || id == 1123
            || id == 1127
            || id == 30758;
    else if (name == "equalizer")
        return id == 128;
    else if (name == "market_gardener")
        return id == 416;
    else if (name == "disciplinary_action" || name == "disc_action")
        return id == 447;
    else if (name == "escape_plan")
        return id == 775;


    //Pyro Primaries [3,0]
    else if (name == "any_flamethrower") // Catches both regular flamethrowers and Dragon's Fury, which is classified as a rocket launcher instead. - Senni
        return weapon.GetClassname() == "tf_weapon_flamethrower" || weapon.GetClassname() == "tf_weapon_rocketlauncher_fireball";
    else if (name == "flame_thrower" || name == "flamethrower")
        return id == 21
            || id == 208
            || id == 659
            || id == 741
            || id == 798
            || id == 807
            || id == 887
            || id == 896
            || id == 905
            || id == 914
            || id == 963
            || id == 972
            || id == 15005
            || id == 15017
            || id == 15030
            || id == 15034
            || id == 15049
            || id == 15054
            || id == 15066
            || id == 15067
            || id == 15068
            || id == 15089
            || id == 15090
            || id == 15115
            || id == 15141
            || id == 30474;
    else if (name == "backburner")
        return id == 40
            || id == 1146;
    else if (name == "degreaser")
        return id == 215;
    else if (name == "phlogistinator" || name == "phlog")
        return id == 594;
    else if (name == "dragons_fury")
        return id == 1178;

    //Pyro Secondaries [3,1]
    else if (name == "flare_gun" || name == "flaregun")
        return id == 39
            || id == 1081;
    else if (name == "detonator")
        return id == 351;
    else if (name == "manmelter")
        return id == 595;
    else if (name == "scorch_shot")
        return id == 740;
    else if (name == "thermal_thruster")
        return id == 1179;
    else if (name == "gas_passer")
        return id == 1180;


    //Pyro Melees [3,2]
    else if (name == "fire_axe")
        return id == 2
            || id == 192
            || id == 264
            || id == 423
            || id == 474
         // || id == 593
            || id == 739
            || id == 880
            || id == 939
            || id == 954
            || id == 1013
            || id == 1071
            || id == 1123
            || id == 1127
            || id == 30758;
    else if (name == "axtinguisher") //Need to get Axtinguisher, Festive Axtinguisher, and Postal Pummeler, different IDs for same weapon.
        return id == 38
            || id == 457
            || id == 1000;
    else if (name == "homewrecker")
        return id == 153
            || id == 466;
    else if (name == "powerjack")
        return id == 214;
    else if (name == "back_scratcher")
        return id == 326;
    else if (name == "volcano_fragment")
        return id == 348;
    else if (name == "third_degree")
        return id == 593;
    else if (name == "neon_annihilator")
        return id == 813
            || id == 834;


    //Demoman Primaries [4,0]
    else if (name == "any_grenadelauncher" || name == "any_grenade_launcher")
        return weapon.GetClassname() == "tf_weapon_grenadelauncher" || weapon.GetClassname() == "tf_weapon_cannon";
    else if (name == "any_demo_boots" || name == "any_boots")
        return id == 608
            || id == 405;
    else if (name == "grenade_launcher")
        return id == 19
            || id == 206
            || id == 1007
            || id == 15077
            || id == 15079
            || id == 15091
            || id == 15092
            || id == 15116
            || id == 15117
            || id == 15142
            || id == 15158;
    else if (name == "lochnload" || name == "loch_n_load")
        return id == 308;
    else if (name == "loosecannon" || name == "loose_cannon")
        return id == 996;
    else if (name == "iron_bomber")
        return id == 1151;

    //Demoman Secondaries [4,1]
    else if (name == "any_demo_shield" || name == "any_shield")
        return weapon.GetClassname() == "tf_wearable_demoshield";
    else if (name == "any_stickybomb_launcher")
        return weapon.GetClassname() == "tf_weapon_pipebomblauncher";
    else if (name == "chargin_targe")
        return id == 131
            || id == 1144;
    else if (name == "splendid_screen")
        return id == 406;
    else if (name == "tideturner")
        return id == 1099;
    else if (name == "stickybomb_launcher")
        return id == 20
            || id == 207
            || id == 661
            || id == 797
            || id == 806
            || id == 886
            || id == 895
            || id == 904
            || id == 913
            || id == 962
            || id == 971
            || id == 15009
            || id == 15012
            || id == 15024
            || id == 15038
            || id == 15045
            || id == 15048
            || id == 15082
            || id == 15083
            || id == 15084
            || id == 15113
            || id == 15137
            || id == 15138
            || id == 15155;
    else if (name == "scottish_resistance")
        return id == 130;
    else if (name == "sticky_jumper")
        return id == 265;
    else if (name == "quickiebomb_launcher")
        return id == 1150;

    //Demoman Melees [4,2]
    else if (name == "any_sword")
        return weapon.GetClassname() == "tf_weapon_sword" || weapon.GetClassname() == "tf_weapon_katana";
    else if (name == "bottle")
        return id == 1
            || id == 191
            || id == 264
            || id == 423
            || id == 474
            || id == 609
            || id == 880
            || id == 939
            || id == 954
            || id == 1013
            || id == 1071
            || id == 1123
            || id == 1127
            || id == 30758;
    else if (name == "eyelander")
        return id == 132
            || id == 266
            || id == 482
            || id == 1082;
    else if (name == "scotsmans_skullcutter" || name == "skullcutter")
        return id == 172;
    else if (name == "ullapool_caber" || name == "caber")
        return id == 307;
    else if (name == "claidheamh_mor" || name == "claymore")
        return id == 327;
    else if (name == "persian_persuader" || name == "persuader")
        return id == 404;


    //Heavy Primaries [5,0]
    else if (name == "minigun")
        return id == 15
            || id == 202
            || id == 298
            || id == 654
            || id == 793
            || id == 802
            || id == 882
            || id == 891
            || id == 900
            || id == 909
            || id == 958
            || id == 967
            || id == 15004
            || id == 15020
            || id == 15026
            || id == 15026
            || id == 15031
            || id == 15040
            || id == 15055
            || id == 15086
            || id == 15087
            || id == 15088
            || id == 15098
            || id == 15099
            || id == 15123
            || id == 15124
            || id == 15125
            || id == 15147;
    else if (name == "natascha" || name == "natasha")
        return id == 41;
    else if (name == "brass_beast")
        return id == 312;
    else if (name == "tomislav")
        return id == 424;
    else if (name == "huo_long_heater" || name == "huo_long")
        return id == 811
            || id == 832;

    //Heavy Secondaries [5,1]
    else if (name == "sandvich")
        return id == 42
            || id == 863
            || id == 1002;
    else if (name == "dalokohs_bar" || name == "dalokohs" || name == "chocolate_bar")
        return id == 159
            || id == 433;
    else if (name == "buffalo_steak_sandvich" || name == "buffalo_steak" || name == "steak")
        return id == 311;
    else if (name == "family_business")
        return id == 425;
    else if (name == "second_banana" || name == "banana")
        return id == 1190;

    //Heavy Melees [5,2]
    else if (name == "fists")
        return id == 5
            || id == 195
            || id == 264
            || id == 423
            || id == 474
            || id == 587
            || id == 880
            || id == 939
            || id == 954
            || id == 1013
            || id == 1071
            || id == 1123
            || id == 1127
            || id == 30758;
    else if (name == "killing_gloves_of_boxing" || name == "kgb")
        return id == 43;
    else if (name == "gloves_of_running_urgently" || name == "gru")
        return id == 239
            || id == 1084
            || id == 1100;
    else if (name == "warriors_spirit")
        return id == 310;
    else if (name == "fists_of_steel")
        return id == 331;
    else if (name == "eviction_notice")
        return id == 426;
    else if (name == "holiday_punch")
        return id == 656;



    //Engineer Primaries [6,0]
    else if (name == "frontier_justice")
        return id == 141
            || id == 1004;
    else if (name == "widowmaker")
        return id == 527;
    else if (name == "pomson_6000" || name == "pomson")
        return id == 588;
    else if (name == "rescue_ranger")
        return id == 997;

    //Engineer Secondaries [6,1]
    else if (name == "wrangler")
        return id == 140
            || id == 1086
            || id == 30668;
    else if (name == "short_circuit")
        return id == 528;

    //Engineer Melees [6,2]
    else if (name == "any_wrench")
        return weapon.GetClassname() == "tf_weapon_wrench" || weapon.GetClassname() == "tf_weapon_robot_arm";
    else if (name == "wrench")
        return id == 7
            || id == 197
            || id == 169
            || id == 423
            || id == 662
            || id == 795
            || id == 804
            || id == 884
            || id == 893
            || id == 902
            || id == 911
            || id == 960
            || id == 969
            || id == 1071
            || id == 1123
            || id == 15073
            || id == 15074
            || id == 15075
            || id == 15114
            || id == 15139
            || id == 15140
            || id == 15156
            || id == 30758;
    else if (name == "gunslinger")
        return id == 142;
    else if (name == "southern_hospitality")
        return id == 155;
    else if (name == "jag")
        return id == 329;
    else if (name == "eureka_effect")
        return id == 589;

    //Engineer Construction PDA [6,3]
    else if (name == "pda")
        return id == 25     // Construction PDA
            || id == 737;   // Renamed/Strange Construction PDA

    //Engineer Destruction PDA [6,4]
    else if (name == "destruction_pda" || name == "pda2")
        return id == 26;

    //Engineer Toolbox [6,5]
    else if (name == "toolbox")
        return id == 28;

    //Medic Primaries [7,0]
    else if (name == "any_syringegun" || name == "any_syringe_gun")
        return weapon.GetClassname() == "tf_weapon_syringegun_medic" || weapon.GetClassname() == "tf_weapon_crossbow";
    else if (name == "syringe_gun")
        return id == 17
            || id == 204;
    else if (name == "blutsauger")
        return id == 36;
    else if (name == "crusaders_crossbow" || name == "crossbow")
        return id == 305
            || id == 1079;
    else if (name == "overdose")
        return id == 412;

    //Medic Secondaries [7,1]
    else if (name == "any_medigun")
        return weapon.GetClassname() == "tf_weapon_medigun";
    else if (name == "medigun")
        return id == 29
            || id == 211
            || id == 663
            || id == 796
            || id == 805
            || id == 885
            || id == 894
            || id == 903
            || id == 912
            || id == 961
            || id == 970
            || id == 15008
            || id == 15010
            || id == 15025
            || id == 15039
            || id == 15050
            || id == 15078
            || id == 15097
            || id == 15121
            || id == 15122
            || id == 15123
            || id == 15145
            || id == 15146;
    else if (name == "kritzkrieg")
        return id == 35;
    else if (name == "quick_fix" || name == "quickfix")
        return id == 411;
    else if (name == "vaccinator")
        return id == 998;

    //Medic Melees [7,2]
    else if (name == "any_bonesaw")
        return weapon.GetClassname() == "tf_weapon_bonesaw" || weapon.GetClassname() == "saxxy";
    else if (name == "bonesaw")
        return id == 8
            || id == 198
            || id == 264
            || id == 423
            || id == 474
            || id == 880
            || id == 939
            || id == 954
            || id == 1013
            || id == 1071
            || id == 1123
            || id == 1127
            || id == 1143
            || id == 30758;
    else if (name == "ubersaw")
        return id == 37 || id == 1003;
    else if (name == "vitasaw")
        return id == 173;
    else if (name == "amputator")
        return id == 304;
    else if (name == "solemn_vow")
        return id == 413;



    //Sniper Primaries [8,0]
    else if (name == "any_sniper_rifle" || name == "any_sniperrifle")
        return weapon.GetClassname() == "tf_weapon_sniperrifle" || weapon.GetClassname() == "tf_weapon_sniperrifle_decap" || weapon.GetClassname() == "tf_weapon_sniperrifle_classic";
    else if (name == "any_bow")
        return weapon.GetClassname() == "tf_weapon_compound_bow";
    else if (name == "sniper_rifle")
        return id == 14
            || id == 201
            || id == 664
            || id == 792
            || id == 801
            || id == 851
            || id == 881
            || id == 890
            || id == 899
            || id == 908
            || id == 957
            || id == 966
            || id == 15000
            || id == 15007
            || id == 15019
            || id == 15023
            || id == 15033
            || id == 15059
            || id == 15070
            || id == 15071
            || id == 15072
            || id == 15111
            || id == 15112
            || id == 15135
            || id == 15136
            || id == 15154
            || id == 30665;
    else if (name == "sydney_sleeper")
        return id == 230;
    else if (name == "bazaar_bargain")
        return id == 402;
    else if (name == "machina")
        return id == 526;
    else if (name == "hitmans_heatmaker")
        return id == 752;
    else if (name == "classic")
        return id == 1098;

    //Sniper Secondaries [8,1]
    else if (name == "any_smg")
        return weapon.GetClassname() == "tf_weapon_smg" || weapon.GetClassname() == "tf_weapon_charged_smg";
    else if (name == "smg")
        return id == 16
            || id == 203
            || id == 1105
            || id == 1149
            || id == 15001
            || id == 15022
            || id == 15032
            || id == 15037
            || id == 15058
            || id == 15076
            || id == 15110
            || id == 15134
            || id == 15153;
    else if (name == "razorback")
        return id == 57;
    else if (name == "jarate")
        return id == 58
            || id == 1083;
    else if (name == "darwins_danger_shield" || name == "darwins")
        return id == 231;
    else if (name == "cozy_camper")
        return id == 642;
    else if (name == "cleaners_carbine")
        return id == 751;

    //Sniper Melees [8,2]
    else if (name == "kukri")
        return id == 3
            || id == 193
            || id == 264
            || id == 423
            || id == 474
            || id == 880
            || id == 939
            || id == 954
            || id == 1013
            || id == 1071
            || id == 1123
            || id == 1127
            || id == 30758;
    else if (name == "tribalmans_shiv")
        return id == 171;
    else if (name == "bushwacka")
        return id == 232;
    else if (name == "shahanshah" || name == "yatagan")
        return id == 401;




    //Spy Secondaries [9,0] (This is how they're defined in TF2's code.)
    // Delfite: Use "TF_WEAPONSLOTS.PRIMARY" when checking for the slot the revolvers use.
    else if (name == "any_revolver")
        return weapon.GetClassname() == "tf_weapon_revolver";
    else if (name == "revolver")
        return id == 24
            || id == 210
            || id == 161
            || id == 1142
            || id == 15011
            || id == 15027
            || id == 15042
            || id == 15051
            || id == 15062
            || id == 15063
            || id == 15064
            || id == 15103
            || id == 15127
            || id == 15128
            || id == 15149;
    else if (name == "ambassador")
        return id == 61
            || id == 1006;
    else if (name == "letranger")
        return id == 224;
    else if (name == "enforcer")
        return id == 460;
    else if (name == "diamondback")
        return id == 525;

    //Spy Buildings [9,1]
    // Delfite: Use "TF_WEAPONSLOTS.SECONDARY" when checking for the slot the sappers use.
    else if (name == "sapper")
        return id == 735
            || id == 736
            || id == 933
            || id == 1080
            || id == 1102;
    else if (name == "red_tape_recorder" || name == "red_tape")
        return id == 810
            || id == 831;

    //Spy Melees [9,2]
    else if (name == "knife")
        return id == 4
            || id == 194
            || id == 423
            || id == 638
            || id == 665
            || id == 727
            || id == 794
            || id == 803
            || id == 883
            || id == 892
            || id == 901
            || id == 910
            || id == 959
            || id == 968
            || id == 1071
            || id == 15062
            || id == 15094
            || id == 15095
            || id == 15096
            || id == 15118
            || id == 15119
            || id == 15143
            || id == 15144
            || id == 30758;
    else if (name == "your_eternal_reward" || name == "eternal_reward" || name == "yer")
        return id == 225
            || id == 574;
    else if (name == "connivers_kunai" || name == "kunai")
        return id == 356;
    else if (name == "big_earner")
        return id == 461;
    else if (name == "spy_cicle")
        return id == 649;

    //Spy PDA [6,3]
    else if (name == "disguise_kit")
        return id == 27;

    //Spy PDA2 [6,4]
    else if (name == "invis_watch")
        return id == 30
            || id == 212
            || id == 297
            || id == 947;
    else if (name == "dead_ringer")
        return id == 59;
    else if (name == "cloak_and_dagger" || name == "cloakanddagger")
        return id == 60;

    return (name in weaponModels ? weaponModels[name] : null) == GetPropInt(weapon, "m_iWorldModelIndex");
}
