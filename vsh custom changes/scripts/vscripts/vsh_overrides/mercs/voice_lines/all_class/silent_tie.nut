// Script by: Delfite (Don't care, use this for whatever you want.)


PrecacheArbitrarySound("vsh_sfx.silent_tie")

// Delfite: Apparently if you use `foreach (player in GetAliveMercs())`, but don't attach any following code, the entire gamemode gets bricked. How silly.
AddListener("round_end", 0, function (winnerTeam)
{
    if (winnerTeam != TF_TEAM_UNASSIGNED) // Delfite: If the winning team is not TF_TEAM_UNASSIGNED, return early.
        return;
    foreach (player in GetAliveMercs()) // Delfite: Should the winning team be TF_TEAM_UNASSIGNED, play the mercs' stalemate voicelines.
    {
        player.AcceptInput("SpeakResponseConcept", "TLK_STALEMATE", null, null)
    }
});