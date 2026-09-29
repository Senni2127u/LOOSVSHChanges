// ============================================================
// VSH Healing Tracking + Top 3
// Framework-compatible (listeners.nut + game_events.nut)
// Keeps track of total healing done by each player this round.
// Based on the Boss Damage tracker by Pika, Tweaked by Senni
// ============================================================

player_healing <- {}; // [player_entity] = total healing done this round

_healRoundAlreadyLogged <- false;

function ResetHealing()
{
    player_healing.clear();
    _healRoundAlreadyLogged = false;
}

function GetPlayerName(p)
{
    return NetProps.GetPropString(p, "m_szNetname");
}

function GetPlayerSteamID(p)
{
    return NetProps.GetPropString(p, "m_szNetworkIDString");
}

function GetTopHealers(maxCount = 3)
{
    local arr = [];
    foreach (p, heal in player_healing)
    {
        if (!p || !p.IsValid()) continue;
        arr.append({ player = p, healing = heal });
    }

    arr.sort(function(a, b) { return b.healing <=> a.healing; });

    if (arr.len() > maxCount)
        arr.resize(maxCount);

    return arr;
}

function PrintAndLogTopHealers(reason)
{
    if (_healRoundAlreadyLogged) return;
    _healRoundAlreadyLogged = true;

    local top = GetTopHealers(3);

    printl(format("=== TOP HEALING (THIS ROUND) [%s] ===", reason));
    for (local i = 0; i < top.len(); i++)
    {
        local p = top[i].player;
        local name = GetPlayerName(p);
        printl(format("#%d %s - %d", i + 1, name, top[i].healing));
    }

    if (top.len() > 0)
    {
        local msg = "\x01Top Healers:\x01 ";

        for (local i = 0; i < top.len(); i++)
        {
            local p = top[i].player;
            local name = GetPlayerName(p);

            // Gold, Silver, Bronze/Copper
            local color;
            switch (i)
            {
                case 0: color = "FFD700"; break; // Gold
                case 1: color = "C0C0C0"; break; // Silver
                case 2: color = "CD7F32"; break; // Bronze/Copper
                default: color = "FFFFFF"; break; // White
            }

            msg += format(
                "\x01%d) \x07%s%s\x01 - %d",
                i + 1,
                color,
                name,
                top[i].healing
            );

            if (i < top.len() - 1)
                msg += "\x01 | ";
        }

        ClientPrint(null, 3, msg);
    }
}

// ------------------------------------------------------------
// Event hooks (via AddListener)
// ------------------------------------------------------------

// Round/setup start
AddListener("setup_start", 0, function()
{
    ResetHealing();
});

// Track healing
// TF2's "player_healed" event carries keys: healer, patient, amount
// ⚠️ ASSUMPTION: this framework's game_events.nut maps those keys onto
// callback args the same way it does for player_hurt (attacker, victim, params) ->
// i.e. (healer, patient, params). If your framework instead passes
// (patient, healer, params), just swap the two parameter names below.
AddListener("player_healed", 0, function(healer, patient, params)
{
    if (!healer || !healer.IsValid()) return;
    if (!patient || !patient.IsValid()) return;
    if (healer == patient) return; // skip self-heals from health packs/regen if event fires those

    local heal = 0;
    if ("amount" in params) heal = params.amount.tointeger();
    if (heal <= 0) return;

    player_healing[healer] <- (healer in player_healing) ? (player_healing[healer] + heal) : heal;
});

// End-of-round triggers — same set as the damage tracker
AddListener("round_end", 0, function(...){ PrintAndLogTopHealers("round_end"); });
AddListener("round_win", 0, function(...){ PrintAndLogTopHealers("round_win"); });
AddListener("teamplay_round_win", 0, function(...){ PrintAndLogTopHealers("teamplay_round_win"); });
AddListener("teamplay_game_over", 0, function(...){ PrintAndLogTopHealers("teamplay_game_over"); });
AddListener("game_end", 0, function(...){ PrintAndLogTopHealers("game_end"); });
AddListener("teamplay_game_over_panel", 0, function(...){ PrintAndLogTopHealers("game_over_panel"); });

// Optional: if your framework forwards a map-transition event, add it here:
// AddListener("server_changelevel", 0, function(...){ PrintAndLogTopHealers("changelevel"); });
