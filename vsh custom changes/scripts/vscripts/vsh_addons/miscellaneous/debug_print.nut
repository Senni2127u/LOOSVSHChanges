// Script by: LizardOfOz.
// Modified by: Delfite.
// Prints debug information to the whitelisted players' console via ClientPrint().
// Useful in situations where specific errors can only be caught in a normal multiplayer setting, rather than standalone testing.


if (!IsDedicatedServer())
    return;


::stv_player <- null; //Homework for you: you can fish for sourcetv player with player_spawn event.

//Add steam ids here in SteamID3 format "[U:N:XXXXXX]"
::steamidWhitelist <- [
    SENNI,
    DELFITE,
    LIZARDOFOZ,
    LANKO
];


::FindValidDevs <- function()
{
    local devs = [];
    for (local i = 1; i <= MaxClients().tointeger(); i++)
    {
        local player = PlayerInstanceFromIndex(i);
        if (player && steamidWhitelist.find((NetProps.GetPropString(player, "m_szNetworkIDString"))) != null)
            devs.push(player);
    }
    if (stv_player)
        devs.push(stv_player);
    return devs;
}

::detectedIssues <- {};

::ErrorHandler <- function (e)
{
    local stackInfo = getstackinfos(2);
    local key = format("'%s' @ %s#%d", e, stackInfo.src, stackInfo.line);

    if (!(key in detectedIssues))
    {
        detectedIssues[key] <- [e, 1];
        foreach(player in FindValidDevs())
            PrintError(player, "A NEW ERROR HAS OCCURRED", e);
    }
    else
    {
        detectedIssues[key][1]++;
        foreach(player in FindValidDevs())
            ClientPrint(player, 3, format("\x07BD3B3B AN ERROR HAS OCCURRED [%d] TIMES: [%s]", detectedIssues[key][1], key));
    }
}
seterrorhandler(ErrorHandler);

::printdev <- function(text)
{
    foreach(player in FindValidDevs())
        ClientPrint(player, 3, text.tostring());
}

::PrintError <- function(player, title, e, printfunc = null)
{
    if (!printfunc)
        printfunc = @(m) ClientPrint(player, 3, m);
    printfunc(format("\n%s [%s]", title, e))
    printfunc("CALLSTACK")
    local s, l = 3
    while (s = getstackinfos(l++))
        printfunc(format("*FUNCTION [%s()] %s line [%d]", s.func, s.src, s.line))
    printfunc("LOCALS")
    if (s = getstackinfos(3))
        foreach (n, v in s.locals)
        {
            local t = type(v)
            t ==    "null" ? printfunc(format("[%s] NULL"  , n))    :
            t == "integer" ? printfunc(format("[%s] %d"    , n, v)) :
            t ==   "float" ? printfunc(format("[%s] %.14g" , n, v)) :
            t ==  "string" ? printfunc(format("[%s] \"%s\"", n, v)) :
                             printfunc(format("[%s] %s %s" , n, t, v.tostring()))
        }
}
