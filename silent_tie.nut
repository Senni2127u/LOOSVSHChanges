//Copyright: Delfite (Don't care, use this for whatever you want.)


// You would think removing this block of code would just bring back the mercs' stalemate voicelines, but it just ends up turning them mute again.
/*AddListener("round_end", 0, function (winnerTeam)
{
    if (winnerTeam = TF_TEAM_UNASSIGNED)
        return;
});*/

// Side Note: Apparently if you use `foreach (player in GetAliveMercs())`, but don't attach any following code, the entire gamemode gets bricked. How silly. -Delfite

PrecacheArbitrarySound("vsh_sfx.silent_tie")

AddListener("round_end", 0, function (winnerTeam)
{
    if (winnerTeam != TF_TEAM_UNASSIGNED) //If the winning team is not TF_TEAM_UNASSIGNED, return early. -Delfite
        return;
    foreach (player in GetAliveMercs()) //Should the winning team be TF_TEAM_UNASSIGNED, play the mercs' stalemate voicelines. -Delfite
    {
        RunWithDelay2(this, 0.12, function ()
        {
            player.AcceptInput("SpeakResponseConcept", "TLK_STALEMATE", null, null)
        })
        EmitSoundOn("vsh_sfx.silent_tie", player);
    }
});