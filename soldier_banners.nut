//Copyright: Senni, Delfite
//Remember to put your name next to your comments so we know who changed what.

::isBannerLoopActive <- false; //Boolean used to keep track of StartBannerRecharge's current state. -Delfite


characterTraitsClasses.push(class extends CharacterTrait
{
    //This function is responsible for fixing TF_COND_DEFENSEBUFF from not applying its damage resistance to Hale's abilities.
    //Intended as a fix for the Battalion's Backup, but fixes the condition as a whole. -Delfite
    function OnDamageTaken(attacker, params)
    {
        if (IsValidBoss(attacker))
        {
            if ((params.damage_type & (DMG_CLUB))) //Ignore Saxton's normal hits, the game already handles the resistance. - Senni
            {
                return;
            }

            foreach (player in GetAliveMercs())
            if (player.InCond(TF_COND_DEFENSEBUFF))
            {
                params.damage *= 0.65
                //printl("damage resisted on merc") //Debug to make sure resistance is applied - Senni
            }
        }
    }



    //This function is responsible for adding Rage to every player's currently equipped banner (if any). -Delfite
    function ChargeSoldierBanners()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        foreach (player in GetAliveMercs())
        {
            if (player.GetPlayerClass() == TF_CLASS_SOLDIER) //Always check the player's class before doing something to them, especially if it's a looping function! -Delfite
            {
                //Only affect banners
                if (WeaponIs(weapon, "any_banner")) //I lied, I've already added an entry for this, using that instead. - Senni
                {
                    if (player.GetRageMeter() < 100) //Stop charging it once at full, because that's a waste. - Senni
                    {
                        player.SetRageMeter(clampCeiling(100, player.GetRageMeter() + 0.34)); //Adding 0.34 to the meter every quarter-second gets us a 75-second recharge time. -Delfite
                        //printl(player.GetRageMeter()) //Debug
                    }
                }
            }
        }
    }
    
    //This function is responsible for controlling the interval at which ChargeSoldierBanners runs.
    //This function repeats itself indefinitely until the round ends. -Delfite
    function StartBannerRecharge()
    {
        //Despite the loop being set to run every quarter-second, it doesn't seem to affect server or client performance at all.
        //That works out though, since it means we can have more granular control over the amount added to each player's Rage Meter, which leads to a cleaner-looking recharge effect. -Delfite
        RunWithDelay2(this, 0.25, function() //WARNING: Do not set the delay to 0.0! Doing so will cause a `CUtIRBTree overflow` engine crash!
        {
            //I would've liked to iterate through all the currently alive mercs to see if they have a banner or not...
            //...But since the loop doesn't cause any measureable performance issues, and we're only running one of them at any given time, it turned out to be simpler to just leave the current loop running-
            //-and prevent any new ones from starting. I guess GLaDOS had a point about that whole "simplest solution" thing after all. -Delfite
            //printl("Continuing the loop...")
            ChargeSoldierBanners();
            StartBannerRecharge();
            isBannerLoopActive = true;
            //printl("isBannerLoopActive = " + isBannerLoopActive) //Debug
        });
    }

    //This function is responsible for initiating the loop that charges each player's currently equipped banner.
    //Only one loop runs at any given time, so performance doesn't get worse if there are more banners in a given round. Hooray for smart code! -Delfite
    function OnApply()
    {
        local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        //printl("OnApply triggered! Time to run the infamous recharge script!") //Debug
        //printl("isBannerLoopActive = " + isBannerLoopActive)
        if (isBannerLoopActive == false)
        {
            //printl("A recharge loop isn't running... Should we start a new one?") //Debug
            if (player.GetPlayerClass() == TF_CLASS_SOLDIER) //Only initiate the recharge loop if the player is a soldier, since OnApply and CanApply triggers every time a class change occurs. -Delfite
            {
                //printl("Well, the player is a soldier...") //Debug
                if (WeaponIs(weapon, "any_banner")) //Only continue if the soldier has a banner equipped, since there's no point in starting the loop unless a banner is in play. -Delfite
                {
                    //printl("...and they have a banner equipped!") //Debug
                    //printl("Starting banner recharge loop...") //Debug
                     StartBannerRecharge();
                }
                else if (!WeaponIs(weapon, "any_banner"))
                {
                    //printl("...but they don't have a banner equipped!") //Debug
                    //printl("Returning out of function...") //Debug
                    return;
                }
            }
            else if (player.GetPlayerClass() != TF_CLASS_SOLDIER) //If a recharge loop isn't running, but the player isn't a soldier...
            {
                //printl("Well, the player isn't a soldier...") //Debug
                if (WeaponIs(weapon, "any_banner")) //Or we can initiate the recharge loop if the player just has a banner equipped. -Delfite
                {
                    //printl("...but our top scientists can't figure out how they managed to equip a banner!") //Debug
                    //printl("Regardless of how silly that may seem, no loop is currently running, so we'll start a new one.") //Debug
                    StartBannerRecharge();
                }
                else if (!WeaponIs(weapon, "any_banner"))
                {
                    //printl("...and as expected, they don't have a banner equipped.") //Debug
                    //printl("Returning out of function...") //Debug
                    return;
                }
            }
        }
        else if (isBannerLoopActive != false)
        {
            //printl("isBannerLoopActive did not return false!")
            //printl("Returning out of function...")
            return;
        }
    }
    
    
    /*
    //Apparently, you can't nest OnTickAlive inside characterTraitsClasses without it breaking other gamemode-associated logic. -Delfite
    function ChargeSoldierBanners() //Over time, we charge soldier's currently equipped banner.
    {
        local playerClass = player.GetPlayerClass(); //It would be nice if we didn't include these definitions in the loop, but I'm unaware of a better way to do this.
        local banner = (player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY), "any_banner");
        local rage = GetPropFloat(banner, "m_flRageMeter");
        if (playerClass == TF_CLASS_SOLDIER)
        {
        if (banner)
        {
        SetPropFloat(banner, "m_flRageMeter", (rage + 0.17, 100.0))
        //printl(m_flRageMeter); //Debug
    }
}
}

    //This was an attempt at changing the banners from using a Rage Meter to an Item Meter via AddAttribute.
    //Interestingly, the Rage Meter appears to be hard-coded for soldier's banners, so replacing it with something else is off the table.
    //The Rage Meter also seems to work differently from an Item Meter. Rage Meters drain over time, whereas Item Meters reset to 0 immediately upon the item's use. -Delfite
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnApply()
    {
        local banner = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        local classname = banner.GetClassname();
        if (classname = "tf_weapon_buff_item")
        {
            banner.AddAttribute("kill_eater_score_type", 0, -1)
            banner.AddAttribute("item_meter_charge_type", 3, -1)
            banner.AddAttribute("item_meter_charge_rate", 60, -1)
            //printl(banner) //Debug
        }
    }
});*/
});
