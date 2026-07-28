// Script by: Delfite, with assistance from Bradasparky.
// This monstrosity of a script is responsible for making the mercs more efficient while under the Buff Banner's effects.


characterTraitsClasses.push(class extends CharacterTrait
{
    didWeApplyOurStatsYetWhileUnderTheBanner = false;
    secondaryIsWrangler = null;
    isWranglerNerfApplied = null;
    weapon = null;
    weapon_primary = null;
    primary_id = null;
    weapon_secondary = null;
    secondary_id = null;
    weapon_melee = null;
    melee_id = null;
    weapon_pda = null;

    weapon_primary_fire_rate = 1;
    weapon_primary_reload_speed = 1;
    weapon_primary_SRifle_charge_rate = 1;
    weapon_secondary_fire_rate = 1;
    weapon_secondary_reload_speed = 1;
    weapon_secondary_ubercharge_rate = 1;
    weapon_melee_fire_rate = 1;
    weapon_melee_construction_rate = 1;
    weapon_melee_sentry_fire_rate = 1;
    //TODO: Make sniper rifles charge faster while under the banner's effects.

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        weapon_pda = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA);
        primary_id = GetItemID(weapon_primary);
        secondary_id = GetItemID(weapon_secondary);
        melee_id = GetItemID(weapon_melee);

        secondaryIsWrangler = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY).GetClassname() == "tf_weapon_laser_pointer"
    }

    function OnFrameTickAlive()
    {
        // Delfite: Don't apply the banner buffs if the server's player count is low, otherwise the mercs might become too strong.
        // if (GetValidClients().len() < 5)
        //     return;
        if (player.InCond(TF_COND_OFFENSEBUFF))
        {
            if (didWeApplyOurStatsYetWhileUnderTheBanner)
                return;

            didWeApplyOurStatsYetWhileUnderTheBanner = true;

            if (weapon_primary)
            {
                //Integer checks run faster than string comparisons. Do them first, then strings later.
                if (primary_id != 45 && weapon_primary.GetClassname() != "tf_weapon_soda_popper" && !WeaponIs(weapon_primary, "rocket_jumper"))
                {
                    if (weapon_primary.GetClassname() == "tf_weapon_rocketlauncher" || WeaponIs(weapon_primary, "any_grenadelauncher"))
                    {
                        weapon_primary_fire_rate = weapon_primary.GetAttribute("fire rate bonus", 1.0)
                        weapon_primary_reload_speed = weapon_primary.GetAttribute("Reload time decreased", 1.0)
                        weapon_primary.AddAttribute("fire rate bonus", weapon_primary_fire_rate - 0.25, -1);
                        weapon_primary.AddAttribute("Reload time decreased", weapon_primary_reload_speed - 0.35, -1);
                        //printl("Rocket/Grenade Launcher buffs applied.")
                    }
                    else if (weapon_primary.GetClassname() == "tf_weapon_flamethrower")
                    {
                        weapon_primary_fire_rate = weapon_primary.GetAttribute("fire rate bonus", 1.0)
                        weapon_primary.AddAttribute("damage bonus", weapon_primary_fire_rate - 0.15, -1)
                        //printl("Flamethrower buff applied.")
                    }
                    else if (weapon_primary.GetClassname() == "tf_weapon_rocketlauncher_fireball") // Delfite: The damage bonus attribute gets inverted on the DF for some reason.
                    {
                        weapon_primary_fire_rate = weapon_primary.GetAttribute("fire rate bonus", 1.0)
                        weapon_primary.AddAttribute("damage bonus", weapon_primary_fire_rate + 0.15, -1)
                        //printl("Dragon's Fury buff applied.")
                    }
                    else
                    {
                        weapon_primary_fire_rate = weapon_primary.GetAttribute("fire rate bonus", 1.0)
                        weapon_primary_reload_speed = weapon_primary.GetAttribute("Reload time decreased", 1.0)
                        weapon_primary.AddAttribute("fire rate bonus", weapon_primary_fire_rate - 0.15, -1);
                        weapon_primary.AddAttribute("Reload time decreased", weapon_primary_reload_speed - 0.5, -1);
                        //printl("Generic primary buffs applied.")
                        if (WeaponIs(weapon_primary, "any_sniperrifle"))
                        {
                            weapon_primary_SRifle_charge_rate = weapon_primary.GetAttribute("SRifle Charge rate increased", 1.0)
                            weapon_primary.AddAttribute("SRifle Charge rate increased", weapon_primary_SRifle_charge_rate + 1.0, -1)
                            //printl("Sniper Rifle buff applied.")
                        }
                    }
                }
            }
            if (weapon_secondary)
            {
                if (!WeaponIs(weapon_secondary, "sticky_jumper"))
                    {
                    weapon_secondary_fire_rate = weapon_secondary.GetAttribute("fire rate bonus", 1.0);
                    weapon_secondary_reload_speed = weapon_secondary.GetAttribute("Reload time decreased", 1.0)
                    weapon_secondary_ubercharge_rate = weapon_secondary.GetAttribute("ubercharge rate bonus", 1.0)
                    weapon_secondary.AddAttribute("fire rate bonus", weapon_secondary_fire_rate - 0.15, -1);
                    weapon_secondary.AddAttribute("Reload time decreased", weapon_secondary_reload_speed - 0.5, -1);
                    if (player.GetPlayerClass() == 5) // Delfite: Is the player a Medic?
                    {
                        weapon_secondary.AddAttribute("ubercharge rate bonus", weapon_secondary_ubercharge_rate + 0.15, -1);
                        //printl("Ubercharge buff removed.")
                    }
                    //printl("Generic secondary buff applied.")
                    //TODO: Make buildings construct much faster while under Mini-crits
                }
            }
            if (weapon_melee)
            {
                if (!WeaponIs(weapon_melee, "market_gardener"))
                {
                    weapon_melee_fire_rate = weapon_melee.GetAttribute("fire rate bonus", 1.0)
                    weapon_melee.AddAttribute("fire rate bonus", weapon_melee_fire_rate - 0.10, -1);
                    if (player.GetPlayerClass() == 9) // Delfite: Check if the player is an Engineer.
                    {
                        weapon_melee_construction_rate = weapon_melee.GetAttribute("Construction rate increased", 1.0)
                        weapon_melee_sentry_fire_rate = weapon_melee.GetAttribute("engy sentry fire rate increased", 1.0)
                        weapon_melee.AddAttribute("Construction rate increased", weapon_melee_construction_rate + 0.7, -1);
                        weapon_melee.AddAttribute("engy sentry fire rate increased", weapon_melee_sentry_fire_rate - 0.10, -1)
                        //printl("Building construction buff applied.")
                    }
                    //printl("Generic melee buff applied.")
                }
            }
            //printl("didWeApplyOurStatsYetWhileUnderTheBanner = true"); //Debug
        }
        else
        {
            if (!didWeApplyOurStatsYetWhileUnderTheBanner)
                return;

            didWeApplyOurStatsYetWhileUnderTheBanner = false;

            if (weapon_primary)
            {
                if (!WeaponIs(primary_id != 45 && weapon_primary.GetClassname() != "tf_weapon_soda_popper" && weapon_primary, "rocket_jumper"))
                {
                    if (weapon_primary.GetClassname() == "tf_weapon_rocketlauncher" || WeaponIs(weapon_primary, "any_grenadelauncher"))
                    {
                        weapon_primary.AddAttribute("fire rate bonus", weapon_primary_fire_rate, -1);
                        weapon_primary.AddAttribute("Reload time decreased", weapon_primary_reload_speed, -1);
                        //printl("Rocket/Grenade Launcher buffs removed.")
                    }
                    else if (weapon_primary.GetClassname() == "tf_weapon_flamethrower")
                    {
                        weapon_primary.AddAttribute("damage bonus", weapon_primary_fire_rate, -1)
                        //printl("Flamethrower buff removed.")
                    }
                    else if (weapon_primary.GetClassname() == "tf_weapon_rocketlauncher_fireball") // Delfite: The damage bonus attribute gets inverted on the DF for some reason.
                    {
                        weapon_primary.AddAttribute("damage bonus", weapon_primary_fire_rate, -1)
                        //printl("Dragon's Fury buff removed.")
                    }
                    else
                    {
                        weapon_primary.AddAttribute("fire rate bonus", weapon_primary_fire_rate, -1);
                        weapon_primary.AddAttribute("Reload time decreased", weapon_primary_reload_speed, -1);
                        //printl("Generic primary buffs removed.")
                        if (WeaponIs(weapon_primary, "any_sniperrifle"))
                        {
                            weapon_primary.AddAttribute("SRifle Charge rate increased", weapon_primary_SRifle_charge_rate, -1)
                            //printl("Sniper Rifle buff removed.")
                        }
                    }
                }
            }

            if (weapon_secondary)
            {
                if (!WeaponIs(weapon_secondary, "sticky_jumper"))
                {
                    weapon_secondary.AddAttribute("fire rate bonus", weapon_secondary_fire_rate, -1);
                    weapon_secondary.AddAttribute("Reload time decreased", weapon_secondary_reload_speed, -1);
                    if (player.GetPlayerClass() == 5) // Delfite: Is the player a Medic?
                    {
                        weapon_secondary.AddAttribute("ubercharge rate bonus", weapon_secondary_ubercharge_rate, -1);
                        //printl("Ubercharge buff removed.")
                    }

                    //printl("Generic secondary buffs removed.")
                }
            }

            if (weapon_melee)
            {
                if (!WeaponIs(weapon_melee, "market_gardener"))
                {
                    weapon_melee.AddAttribute("fire rate bonus", weapon_melee_fire_rate, -1);
                    //printl("Generic melee buff removed.")
                    if (player.GetPlayerClass() == 9) // Delfite: Is the player an Engineer?
                    {
                        weapon_melee.AddAttribute("Construction rate increased", weapon_melee_construction_rate, -1);
                        weapon_melee.AddAttribute("engy sentry fire rate increased", weapon_melee_sentry_fire_rate, -1)
                        //printl("Building construction buff removed.")
                    }
                }
            }
        }
    }

    function OnDiscard()
    {
        // Delfite: We perform IsValid on the weapons so we know they're not still storing information on an entity that doesn't exist.
        if (weapon_primary && weapon_primary.IsValid())
        {
            weapon_primary.RemoveAttribute("fire rate bonus");
            weapon_primary.RemoveAttribute("Reload time decreased");
            weapon_primary.RemoveAttribute("damage bonus");
            weapon_primary.RemoveAttribute("SRifle Charge rate increased");
            //printl("Primary attributes discarded.")
        }

        if (weapon_secondary && weapon_secondary.IsValid())
        {
            weapon_secondary.RemoveAttribute("fire rate bonus");
            weapon_secondary.RemoveAttribute("Reload time decreased");
            weapon_secondary.RemoveAttribute("engy sentry fire rate increased");
            weapon_secondary.RemoveAttribute("ubercharge rate bonus");
            //printl("Secondary attributes discarded.")
        }

        if (weapon_melee && weapon_melee.IsValid())
        {
            weapon_melee.RemoveAttribute("fire rate bonus");
            weapon_melee.RemoveAttribute("Construction rate increased");
            weapon_melee.RemoveAttribute("engy sentry fire rate increased");
            //printl("Melee attributes discarded.")
        }
    }
});