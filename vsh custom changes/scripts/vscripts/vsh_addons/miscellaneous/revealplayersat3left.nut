// Credit: Bradasparky and Senni
// Usage: Reveals all players during Last Mann Standing.
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

function OutlineRemainingPlayers(death)
{
    RunWithDelay2(this, 0.5, function() //Need this delay to avoid respawn issues.
{
        local alive = GetAliveMercs();
        local aliveCount = alive.len();
        local bossalive = GetAliveBossPlayers();
         if (aliveCount == 3 && !IsRoundOver()) //Preventing duplicates if Hale dies, Merc's killbind, or Mercs disconnect at the end of a round, as those instances are counted as a death to the listener.
         {
            foreach (merc in alive)
                {
                    SetPropBool(merc, "m_bGlowEnabled", true);
                }

            foreach (boss in bossalive)
            {
                SetPropBool(boss, "m_bGlowEnabled", true);
            }

        if (!IsRoundOver())
            ClientPrint( null 3 "\x07C9C5B1[VSH] \x07DE3163Last Mann Standing activated! All remaining players have been outlined!") //Maybe comment this out, can get jarring.
         }

            // Debug stuff, only uncomment if there is issue with alive player tracking.
            //printl("alive.len() = " + alive.len());
            //printl("death = " + death.tointeger());
            //printl("aliveCount = " + aliveCount)
});
}
