// Credit: Bradasparky and Senni
// Usage: Reveals all players during Last Mann Standing.
// No required modifications to base gamemode files.

AddListener("setup_end", 999, function()
{
    OutlineRemainingPlayers(false);
});

AddListener("disconnect", -9999, function(player, params)
{
    // Ignore spectators
    if (player.GetTeam() == TEAM_SPECTATOR)
        return;

    // Ignore players that were already dead
    if (!player.IsAlive())
        return;

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
    g_LastMannStandingTriggered = false;
});

local g_LastMannStandingTriggered = false;

function OutlineRemainingPlayers(death)
{
    RunWithDelay2(this, 0.5, function()
    {
        local alive = GetAliveMercs();
        local aliveCount = alive.len();
        local bossalive = GetAliveBossPlayers();

        if (aliveCount == 3 && !g_LastMannStandingTriggered && !IsRoundOver())
        {
            g_LastMannStandingTriggered = true;

            foreach (merc in alive)
            {
                SetPropBool(merc, "m_bGlowEnabled", true);
            }

            foreach (boss in bossalive)
            {
                SetPropBool(boss, "m_bGlowEnabled", true);
            }

            ClientPrint(null, 3, "\x07C9C5B1[VSH] \x07DE3163Last Mann Standing activated! All remaining players have been outlined!");
        }
    });
}
            // Debug stuff, only uncomment if there is issue with alive player tracking.
            //printl("alive.len() = " + alive.len());
            //printl("death = " + death.tointeger());
            //printl("aliveCount = " + aliveCount)
});
}
