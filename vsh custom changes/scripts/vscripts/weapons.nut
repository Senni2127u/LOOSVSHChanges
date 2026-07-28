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

//Why does this table exist? Because the same weapon can have multiple IDs, namely, pre-JI weapon skins.
::weaponModels <- {
    market_gardener = GetModelIndex("models/workshop/weapons/c_models/c_market_gardener/c_market_gardener.mdl"),
    holiday_punch = GetModelIndex("models/workshop/weapons/c_models/c_xms_gloves/c_xms_gloves.mdl"),
    eyelander = GetModelIndex("models/weapons/c_models/c_claymore/c_claymore.mdl"),
    eyelander_xmas = GetModelIndex("models/weapons/c_models/c_claymore/c_claymore_xmas.mdl"),
    headtaker = GetModelIndex("models/weapons/c_models/c_headtaker/c_headtaker.mdl"),
    golf_club = GetModelIndex("models/workshop/weapons/c_models/c_golfclub/c_golfclub.mdl"),
    claymore_xmas = GetModelIndex("models/weapons/c_models/c_claymore/c_claymore_xmas.mdl"),
    natasha = GetModelIndex("models/weapons/c_models/c_minigun/c_minigun_natascha.mdl"),
    kunai = GetModelIndex("models/workshop_partner/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl"),
    big_earner = GetModelIndex("models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl"),
    your_eternal_reward = GetModelIndex("models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl"),
    wanga_prick = GetModelIndex("models/workshop/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl"),
    warriors_spirit = GetModelIndex("models/workshop/weapons/c_models/c_bear_claw/c_bear_claw.mdl"),
    direct_hit = GetModelIndex("models/weapons/c_models/c_directhit/c_directhit.mdl"),
    reserve_shooter = GetModelIndex("models/workshop/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl"),
    candy_cane = GetModelIndex("models/workshop/weapons/c_models/c_candy_cane/c_candy_cane.mdl"),
    fan_o_war = GetModelIndex("models/workshop_partner/weapons/c_models/c_shogun_warfan/c_shogun_warfan.mdl"),
    rocket_jumper = GetModelIndex("models/weapons/c_models/c_rocketjumper/c_rocketjumper.mdl"),
    dead_ringer = GetModelIndex("models/weapons/v_models/v_watch_pocket_spy.mdl"),
    // ubersaw = GetModelIndex("models/weapons/c_models/c_ubersaw/c_ubersaw.mdl"),
    // ubersaw_xmas = GetModelIndex("models/weapons/c_models/c_ubersaw/c_ubersaw_xmas.mdl"),
    // quick_fix = GetModelIndex("models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl"),
    scottish_resistance = GetModelIndex("models/weapons/c_models/c_scottish_resistance/c_scottish_resistance.mdl"),
    // force_a_nature = GetModelIndex("models/weapons/c_models/c_double_barrel.mdl"),
    // force_a_nature_xmas = GetModelIndex("models/weapons/c_models/c_xms_double_barrel.mdl"),
    // sticky_jumper = GetModelIndex("models/weapons/c_models/c_sticky_jumper/c_sticky_jumper.mdl"),
    disciplinary_action = GetModelIndex("models/workshop/weapons/c_models/c_riding_crop/c_riding_crop.mdl"),
    eviction_notice = GetModelIndex("models/workshop/weapons/c_models/c_eviction_notice/c_eviction_notice.mdl"),
    diamondback = GetModelIndex("models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl"),
    powerjack = GetModelIndex("models/workshop/weapons/c_models/c_powerjack/c_powerjack.mdl"),
    sunonastick = GetModelIndex("models/workshop/weapons/c_models/c_rift_fire_mace/c_rift_fire_mace.mdl"), //From here on out is added changes.
    cloakanddagger = GetModelIndex("models/weapons/v_models/v_watch_leather_spy.mdl"),
    // backscatter = GetModelIndex("models/workshop/weapons/c_models/c_scatterdrum/c_scatterdrum.mdl"),
    gas_passer = GetModelIndex("models/weapons/c_models/c_gascan/c_gascan.mdl"),
    ullapoolcaber = GetModelIndex("models/workshop/weapons/c_models/c_caber/c_caber.mdl"),
    beggarsbazooka = GetModelIndex("models/workshop/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl"),
    blackbox = GetModelIndex("models/workshop/weapons/c_models/c_blackbox/c_blackbox.mdl"),
    brass_beast = GetModelIndex("models/workshop/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl"),
    huolongheater = GetModelIndex("models/workshop_partner/weapons/c_models/c_canton/c_canton.mdl"),
    // lochnload = GetModelIndex("models/workshop/weapons/c_models/c_lochnload/c_lochnload.mdl"),
    liberty_launcher = GetModelIndex("models/workshop/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl"),
    // loosecannon = GetModelIndex("models/workshop/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"),
    escape_plan = GetModelIndex("models/weapons/c_models/c_pickaxe/c_pickaxe.mdl"), //The Escape Plan and Equalizer use different models, they're just under the same folder. -Delfite
    equalizer = GetModelIndex("models/weapons/c_models/c_pickaxe/c_pickaxe_s2.mdl")
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
    if (name == "parachute" || name == "base_jumper")
        return weapon.GetClassname() == "tf_weapon_parachute";
    else if (name == "half_zatoichi" || name == "katana")
        return weapon.GetClassname() == "tf_weapon_katana";
    else if (name == "any_scattergun")
        return weapon.GetClassname() == "tf_weapon_scattergun" || weapon.GetClassname() == "tf_weapon_handgun_scout_primary" || weapon.GetClassname() == "tf_weapon_soda_popper" || weapon.GetClassname() == tf_weapon_pep_brawler_blaster;
    else if (name == "any_drink" || name == "energydrink")
        return weapon.GetClassname() == "tf_weapon_lunchbox_drink";
    else if (name == "mad_milk")
        return weapon.GetClassname() == "tf_weapon_jar_milk";
    else if (name == "airstrike")
        return weapon.GetClassname() == "tf_weapon_rocketlauncher_airstrike";
    else if (name == "any_banner")
        return weapon.GetClassname() == "tf_weapon_buff_item";
    else if (name == "any_flamethrower") // Senni: Catches both regular flamethrowers and Dragon's Fury, which is classified as a rocket launcher instead.
        return weapon.GetClassname() == "tf_weapon_flamethrower" || weapon.GetClassname() == "tf_weapon_rocketlauncher_fireball";
    else if (name == "any_grenadelauncher" || name == "any_grenade_launcher")
        return weapon.GetClassname() == "tf_weapon_grenadelauncher" || weapon.GetClassname() == "tf_weapon_cannon";
    else if (name == "any_demo_shield" || name == "any_shield")
        return weapon.GetClassname() == "tf_wearable_demoshield";
    else if (name == "any_stickybomb_launcher")
        return weapon.GetClassname() == "tf_weapon_pipebomblauncher";
    else if (name == "any_sword")
        return weapon.GetClassname() == "tf_weapon_sword" || weapon.GetClassname() == "tf_weapon_katana";
    else if (name == "rescue_ranger")
        return weapon.GetClassname() == "tf_weapon_shotgun_building_rescue";
    else if (name == "wrangler")
        return weapon.GetClassname() == "tf_weapon_laser_pointer"
    else if (name == "any_wrench")
        return weapon.GetClassname() == "tf_weapon_wrench" || weapon.GetClassname() == "tf_weapon_robot_arm";
    else if (name == "any_syringegun")
        return weapon.GetClassname() == "tf_weapon_syringegun_medic" || weapon.GetClassname() == "tf_weapon_crossbow"
    else if (name == "any_medigun")
        return weapon.GetClassname() == "tf_weapon_medigun"
    else if (name == "any_bonesaw")
        return weapon.GetClassname() == "tf_weapon_bonesaw" || weapon.GetClassname() == "saxxy"
    else if (name == "any_sniperrifle")
        return weapon.GetClassname() == "tf_weapon_sniperrifle" || weapon.GetClassname() == "tf_weapon_sniperrifle_decap" || weapon.GetClassname() == "tf_weapon_sniperrifle_classic"
    else if (name == "any_bow")
        return weapon.GetClassname() == "tf_weapon_compound_bow"
    else if (name == "any_smg")
        return weapon.GetClassname() == "tf_weapon_smg" || weapon.GetClassname() == "tf_weapon_charged_smg"
    else if (name == "scattergun")
    {
        local id = GetItemID(weapon)
        return id == 13 || id == 200 || id == 669 || id == 799 || id == 808 || id == 888 || id == 897 || id == 906 || id == 915 || id == 964 || id == 973 || id == 15002 || id == 15015 || id == 15021 || id == 15029 || id == 15036 || id == 15053 || id == 15065 || id == 15069 || id == 15106 || id == 15107 || id == 15108 || id == 15131 || id == 15151 || id == 15157;
    }
    else if (name == "force_a_nature")
    {
        local id = GetItemID(weapon)
        return id == 45 || id == 1078;
    }
    else if (name == "shortstop")
    {
        local id = GetItemID(weapon)
        return id == 220;
    }
    else if (name == "soda_popper")
    {
        local id = GetItemID(weapon)
        return id == 448;
    }
    else if (name == "baby_faces_blaster" || "bfb")
    {
        local id = GetItemID(weapon)
        return id == 772;
    }
    else if (name == "back_scatter" || "backscatter")
    {
        local id = GetItemID(weapon)
        return id == 1103;
    }
    else if (name == "gunboats")
    {
        local id = GetItemID(weapon)
        return id == 133;
    }
    else if (name == "axtinguisher") // Senni: Need to get Axtinguisher, Festive Axtinguisher, and Postal Pummeler, different IDs for same weapon.
    {
        local id = GetItemID(weapon)
        return id == 38 || id == 457 || id == 1000;
    }
    else if (name == "any_demo_boots" || name == "any_boots")
    {
        local id = GetItemID(weapon)
        return id == 608 || id == 405;
    }
    else if (name == "grenade_launcher")
    {
        local id = GetItemID(weapon)
        return id == 19 || id == 206 || id == 1007 || id == 15077 || id == 15079 || id == 15091 || id == 15092 || id == 15116 || id == 15117 || id == 15142 || id == 15158;
    }
    else if (name == "lochnload" || name == "loch_n_load")
    {
        local id = GetItemID(weapon)
        return id == 308;
    }
    else if (name == "loosecannon" || name == "loose_cannon")
    {
        local id = GetItemID(weapon)
        return id == 996;
    }
    else if (name == "iron_bomber")
    {
        local id = GetItemID(weapon)
        return id == 1151;
    }
    else if (name == "chargin_targe")
    {
        local id = GetItemID(weapon)
        return id == 131 || id == 1144;
    }
    else if (name == "splendid_screen")
    {
        local id = GetItemID(weapon)
        return id == 406;
    }
    else if (name == "tideturner")
    {
        local id = GetItemID(weapon)
        return id == 1099;
    }
    else if (name == "stickybomb_launcher")
    {
        local id = GetItemID(weapon)
        return id == 20 || id == 207 || id == 661 || id == 797 || id == 806 || id == 886 || id == 895 || id == 904 || id == 913 || id == 962 || id == 971 || id == 15009 || id == 15012 || id == 15024 || id == 15038 || id == 15045 || id == 15048 || id == 15082 || id == 15083 || id == 15084 || id == 15113 || id == 15137 || id == 15138 || id == 15155;
    }
    else if (name == "scottish_resistance")
    {
        local id = GetItemID(weapon)
        return id == 130;
    }
    else if (name == "sticky_jumper")
    {
        local id = GetItemID(weapon)
        return id == 265;
    }
    else if (name == "quickiebomb_launcher")
    {
        local id = GetItemID(weapon)
        return id == 1150;
    }
    else if (name == "gru")
    {
        local id = GetItemID(weapon)
        return id == 239 || id == 1084 || id == 1100;
    }
    if (name == "kgb")
    {
        local id = GetItemID(weapon)
        return id == 43;
    }
    else if (name == "syringe_gun")
    {
        local id = GetItemID(weapon)
        return id == 17 || id == 204;
    }
    else if (name == "blutsauger")
    {
        local id = GetItemID(weapon)
        return id == 36;
    }
    else if (name == "crossbow")
    {
        local id = GetItemID(weapon)
        return id == 305 || id == 1079;
    }
    else if (name == "overdose")
    {
        local id = GetItemID(weapon)
        return id == 412;
    }
    else if (name == "medigun")
    {
        local id = GetItemID(weapon)
        return id == 29 || id == 211 || id == 663 || id == 796 || id == 805 || id == 885 || id == 894 || id == 903 || id == 912 || id == 961 || id == 970 || id == 15008 || id == 15010 || id == 15025 || id == 15039 || id == 15050 || id == 15078 || id == 15097 || id == 15121 || id == 15122 || id == 15123 || id == 15145 || id == 15146;
    }
    else if (name == "kritzkrieg")
    {
        local id = GetItemID(weapon)
        return id == 35;
    }
    else if (name == "quick_fix" || name == "quickfix")
    {
        local id = GetItemID(weapon)
        return id == 411;
    }
    else if (name == "vaccinator")
    {
        local id = GetItemID(weapon)
        return id == 998;
    }
    else if (name == "bonesaw")
    {
        local id = GetItemID(weapon)
        return id == 8 || id == 198 || id == 264 || id == 423 || id == 474 || id == 880 || id == 939 || id == 954 || id == 1013 || id == 1071 || id == 1123 || id == 1127 || id == 1143 || id == 30758;
    }
    else if (name == "ubersaw")
    {
        local id = GetItemID(weapon)
        return id == 37 || id == 1003;
    }
    else if (name == "vitasaw")
    {
        local id = GetItemID(weapon)
        return id == 173;
    }
    else if (name == "amputator")
    {
        local id = GetItemID(weapon)
        return id == 304;
    }
    else if (name == "solemn_vow")
    {
        local id = GetItemID(weapon)
        return id == 413;
    }
    else if (name == "sniper_rifle")
    {
        local id = GetItemID(weapon)
        return id == 14 || id == 201 || id == 664 || id == 792 || id == 801 || id == 851 || id == 881 || id == 890 || id == 899 || id == 908 || id == 957 || id == 966 || id == 15000 || id == 15007 || id == 15019 || id == 15023 || id == 15033 || id == 15059 || id == 15070 || id == 15071 || id == 15072 || id == 15111 || id == 15112 || id == 15135 || id == 15136 || id == 15154 || id == 30665;
    }
    else if (name == "sydney_sleeper")
    {
        local id = GetItemID(weapon)
        return id == 230;
    }
    else if (name == "bazaar_bargain")
    {
        local id = GetItemID(weapon)
        return id == 402;
    }
    else if (name == "machina")
    {
        local id = GetItemID(weapon)
        return id == 526;
    }
    else if (name == "hitmans_heatmaker")
    {
        local id = GetItemID(weapon)
        return id == 752;
    }
    else if (name == "classic")
    {
        local id = GetItemID(weapon)
        return id == 1098;
    }
    return (name in weaponModels ? weaponModels[name] : null) == GetPropInt(weapon, "m_iWorldModelIndex");
}
