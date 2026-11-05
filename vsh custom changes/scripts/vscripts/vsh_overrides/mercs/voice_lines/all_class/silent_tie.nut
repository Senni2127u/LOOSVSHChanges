// Script by: Delfite (Don't care, use this for whatever you want.)


PrecacheArbitrarySound("vsh_sfx.silent_tie")

// Delfite: Apparently if you use `foreach (player in GetAliveMercs())`, but don't attach any following code, the entire gamemode gets bricked. How silly.
AddListener("round_end", 1, function (winner)
{
    // Delfite: Simply do nothing if the winner is TF_TEAM_UNASSIGNED.
    // The game will play the voicelines for us.
    if (winner != TF_TEAM_UNASSIGNED)
        return;

    // foreach (player in GetAliveMercs())
    // {
    //     RunWithDelay2(this, RandomFloat(0.00, 0.5), function ()
    //     {
    //         player.AcceptInput("SpeakResponseConcept", "TLK_STALEMATE", null, null)
    //     })
    // }
});