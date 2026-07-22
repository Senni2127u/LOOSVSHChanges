//Copyright: Delfite (Don't care, use this for whatever you want.)

setup_finished = false;

function OnGameEvent_teamplay_setup_finished()
{
    setup_finished = true;
    printl("setup_finished = " + setup_finished)
}


PrecacheArbitrarySound("vsh_sfx.silent_tie")

// Side Note: Apparently if you use `foreach (player in GetAliveMercs())`, but don't attach any following code, the entire gamemode gets bricked. How silly. -Delfite
AddListener("round_end", 0, function (winnerTeam)
{
    if (winnerTeam != TF_TEAM_UNASSIGNED) //If the winning team is not TF_TEAM_UNASSIGNED, return early. -Delfite
        return;
    foreach (player in GetAliveMercs()) //Should the winning team be TF_TEAM_UNASSIGNED, play the mercs' stalemate voicelines. -Delfite
        player.AcceptInput("SpeakResponseConcept", "TLK_STALEMATE", null, null)
    if (setup_finished == true && player.IsValidBoss()) //Stop Hale from saying anything if a stalemate happens after setup ends. -Delfite
    {
        EmitSoundOn("vsh_sfx.silent_tie", player);
    }
});