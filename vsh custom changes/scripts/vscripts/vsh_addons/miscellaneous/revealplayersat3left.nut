// Credit: Bradasparky and Senni
// Usage: Reveals all players during Last Mann Standing, and disables Spy's Cloak during LMS.
// No required modifications to base gamemode files.

AddListener("setup_end", 999, function()
{
    OutlineRemainingPlayers(false);
});

AddListener("disconnect", -9999, function(player, params)
{
        if (!IsRoundSetup())
        OutlineRemainingPlayers(true);
});

AddListener("death", 999, function (attacker, victim, params)
{
    if (!IsRoundSetup())
        OutlineRemainingPlayers(true);
});

AddListener("setup_start", 999, function()
{
    foreach (player in GetValidClients())
        SetPropBool(player, "m_bGlowEnabled", false);
});

function StripCloak()
    {
        foreach (merc in GetAliveMercs())
        {
            if (merc.IsValid() && merc.InCond(TF_COND_STEALTHED))
                {
                    merc.RemoveCond(TF_COND_STEALTHED);
                    //printl("cloak condition removed")
                    //Uncomment above line to debug cloak removal.
                }

            if (merc.GetPlayerClass() == TF_CLASS_SPY) //Spy is the only one who can cloak, if there is none left, this stops the check to save resources, uncomment printl to debug this.
                {
                     RunWithDelay2(this, 0.25, StripCloak);
                     //printl("There is a spy in here")
                }
        }
    }

function OutlineRemainingPlayers(death)
{
    RunWithDelay2(this, 0.5, function() //Need this delay to avoid respawn issues.
{
        local alive = GetAliveMercs();
        local aliveCount = alive.len();
        local bossalive = GetAliveBossPlayers();
         if (aliveCount == 3)
         {
            foreach (merc in alive)
                {
                    SetPropBool(merc, "m_bGlowEnabled", true);
                    //StripCloak() //Commented out because of server stability issues, revisit this at a later date.
                }

            foreach (boss in bossalive)
            {
                SetPropBool(boss, "m_bGlowEnabled", true);
            }
            ClientPrint( null 3 "\x07C9C5B1[VSH] \x07DE3163Last Mann Standing activated! All remaining players have been outlined!") //Maybe comment this out, can get jarring.
         }

            // Debug stuff, only uncomment if there is issue with alive player tracking.
            //printl("alive.len() = " + alive.len());
            //printl("death = " + death.tointeger());
            //printl("aliveCount = " + aliveCount)
});
}