// ============================================================
// VSH Boss Damage Tracking + Top 3
// Framework-compatible (listeners.nut + game_events.nut)
// Keeps Track of Damage Dealt By Mercenaries.
// Created by Pika, Tweaked by Senni
// ============================================================

boss_damage <- {}; // [player_entity] = total damage dealt to boss this round

_roundAlreadyLogged <- false;

function ResetBossDamage()
{
    boss_damage.clear();
    _roundAlreadyLogged = false;
}

function GetBoss()
{
    local bosses = GetBossPlayers();
    if (!bosses || bosses.len() <= 0) return null;
    return bosses[0]; // adjust if you have multi-boss
}

function GetPlayerName(p)
{
    return NetProps.GetPropString(p, "m_szNetname");
}

function GetPlayerSteamID(p)
{
    return NetProps.GetPropString(p, "m_szNetworkIDString");
}

function AppendLineToFile(path, line)
{
    local old = FileToString(path);
    if (old == null) old = "";
    StringToFile(path, old + line);
}

function SafeMapName()
{
    try { return GetMapName(); } catch(e) { return "unknown_map"; }
}

function NowStamp()
{
    try { return format("t=%.0f", Time()); } catch(e) { return "t=?"; }
}

function GetTopBossDamagers(maxCount = 3)
{
    local arr = [];
    foreach (p, dmg in boss_damage)
    {
        if (!p || !p.IsValid()) continue;
        arr.append({ player = p, damage = dmg });
    }

    arr.sort(function(a, b) { return b.damage <=> a.damage; });

    if (arr.len() > maxCount)
        arr.resize(maxCount);

    return arr;
}

function PrintAndLogTop3(reason)
{
    if (_roundAlreadyLogged) return;
    _roundAlreadyLogged = true;

    local top = GetTopBossDamagers(3);

    printl(format("=== TOP BOSS DAMAGE (THIS ROUND) [%s] ===", reason));
    for (local i = 0; i < top.len(); i++)
    {
        local p = top[i].player;
        local name = GetPlayerName(p);
        printl(format("#%d %s - %d", i + 1, name, top[i].damage));
    }

if (top.len() > 0)
{
    local msg = "\x01Top Boss Damage:\x01 ";

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
            top[i].damage
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

// Round/setup start (you already see Round_Setup_End in console; framework fires setup_start)
AddListener("setup_start", 0, function()
{
    ResetBossDamage();
});

// Track boss damage
// game_events.nut fires: FireListeners("player_hurt", attacker, victim, params);
AddListener("player_hurt", 0, function(attacker, victim, params)
{
    local boss = GetBoss();
    if (!boss || !boss.IsValid()) return;

    if (!victim || !victim.IsValid()) return;
    if (victim != boss) return;

    if (!attacker || !attacker.IsValid()) return;
    if (attacker == boss) return;

    local dmg = 0;
    if ("damageamount" in params) dmg = params.damageamount.tointeger();
    if (dmg <= 0) return;

    boss_damage[attacker] <- (attacker in boss_damage) ? (boss_damage[attacker] + dmg) : dmg;
});

// Boss death = primary end-of-round trigger
// game_events.nut fires: FireListeners("death", attacker, player, params);
AddListener("death", 0, function(attacker, player, params)
{
    local boss = GetBoss();
    if (!boss || !boss.IsValid()) return;

    if (!player || !player.IsValid()) return;

    if (player == boss)
    {
        PrintAndLogTop3("boss_death");
        // keep boss_damage until next setup_start in case other end events also fire;
        // guard prevents duplicate logs anyway.
    }
});

// Fallback end triggers (forced map change / admin end / unusual endings)
// These will only do something if your framework forwards these events.
AddListener("round_end", 0, function(...){ PrintAndLogTop3("round_end"); });
AddListener("round_win", 0, function(...){ PrintAndLogTop3("round_win"); });
AddListener("teamplay_round_win", 0, function(...){ PrintAndLogTop3("teamplay_round_win"); });
AddListener("teamplay_game_over", 0, function(...){ PrintAndLogTop3("teamplay_game_over"); });
AddListener("game_end", 0, function(...){ PrintAndLogTop3("game_end"); });
AddListener("teamplay_game_over_panel", 0, function(...){ PrintAndLogTop3("game_over_panel"); });

// Optional: if your framework forwards a map-transition event, add it here:
// AddListener("server_changelevel", 0, function(...){ PrintAndLogTop3("changelevel"); });
