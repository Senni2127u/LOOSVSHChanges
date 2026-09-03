//=========================================================================
//Copyright LizardOfOz.
//
//Credits:
//  LizardOfOz - Programming, game design, promotional material and overall development. The original VSH Plugin from 2010.
//  Maxxy - Saxton Hale's model imitating Jungle Inferno SFM; Custom animations and promotional material.
//  Velly - VFX, animations scripting, technical assistance.
//  JPRAS - Saxton model development assistance and feedback.
//  MegapiemanPHD - Saxton Hale and Gray Mann voice acting.
//  James McGuinn - Mercenaries voice acting for custom lines.
//  Yakibomb - give_tf_weapon script bundle (used for Hale's first-person hands model).
//  Phe - game design assistance.
//=========================================================================

::SetNextBossByEntity <- function(playerEnt)
{
    SetPersistentVar("next_boss", playerEnt.entindex());
}

::SetNextBossByEntityIndex <- function(playerEntIndex)
{
    SetPersistentVar("next_boss", playerEntIndex);
}

::SetNextBossByUserId <- function(userId)
{
    local playerEnt = GetPlayerFromUserID(userId);
    SetPersistentVar("next_boss", playerEnt.entindex());
}

//=========================================================================
// Boss opt-out
//
// Players can type !noboss (or !boss) in chat to toggle whether they're
// eligible for random boss selection. Opt-out is keyed by entindex, so it
// lasts for as long as the player stays connected; it does not affect a
// boss explicitly assigned via SetNextBossBy... (that's treated as an
// intentional override).
//=========================================================================

::GetBossOptOuts <- function()
{
    local optOuts = GetPersistentVar("boss_opt_outs", null);
    if (optOuts == null)
        SetPersistentVar("boss_opt_outs", optOuts = {});
    return optOuts;
}

::IsBossOptedOut <- function(player)
{
    if (!IsValidPlayer(player))
        return false;
    return player.entindex() in GetBossOptOuts();
}

::SetBossOptOut <- function(player, optedOut)
{
    local optOuts = GetBossOptOuts();
    local index = player.entindex();
    if (optedOut)
        optOuts[index] <- true;
    else if (index in optOuts)
        delete optOuts[index];
}

function OnGameEvent_player_say(event)
{
    local player = GetPlayerFromUserID(event.userid);
    if (!IsValidPlayer(player))
        return;

    local text = event.text.tolower();
    if (text == "!noboss" || text == "/noboss")
    {
        SetBossOptOut(player, true);
        ClientPrint(player, 3, "[Boss Queue] You have opted out of being selected as the boss.");
    }
    else if (text == "!boss" || text == "/boss")
    {
        local optedOut = !IsBossOptedOut(player);
        SetBossOptOut(player, optedOut);
        ClientPrint(player, 3, optedOut
            ? "[Boss Queue] You have opted out of being selected as the boss."
            : "[Boss Queue] You are eligible to be selected as the boss again.");
    }
}
RegisterScriptGameEventListener("player_say");

function ProgressBossQueue(iterations = 0)
{
    try
    {
        local nextBossIndex = GetPersistentVar("next_boss", null);
        if (nextBossIndex != null)
        {
            SetPersistentVar("next_boss", null);
            local nextBossPlayer = PlayerInstanceFromIndex(nextBossIndex);
            if (IsValidPlayer(nextBossPlayer))
                return nextBossPlayer;
        }

        local playedAsBossAlready = GetPersistentVar("played_as_boss");
        if (playedAsBossAlready == null)
            SetPersistentVar("played_as_boss", playedAsBossAlready = []);

        local candidates = GetValidPlayers().slice();

        //Exclude players who opted out via !noboss, unless doing so would leave no one to pick from
        local optedIn = candidates.filter(function(index, player) { return !IsBossOptedOut(player); });
        if (optedIn.len() > 0)
            candidates = optedIn;

        if (iterations < 3 && RandomInt(1, 10) != 1) //We leave a small chance for a completely random selection
        {
            foreach (played in playedAsBossAlready)
            {
                local index = candidates.find(played);
                if (index != null)
                    candidates.remove(index);
            }
            if (candidates.len() == 0)
            {
                for (local i = 0; i < clampCeiling(6, playedAsBossAlready.len()); i++)
                    playedAsBossAlready.remove(0);
                return ProgressBossQueue(iterations + 1);
            }
        }
        local newBossPlayer = candidates[RandomInt(0, candidates.len() - 1)];
        playedAsBossAlready.push(newBossPlayer);
        return newBossPlayer;
    }
    catch(e)
    {
        try
        {
            return GetValidPlayers()[RandomInt(0, GetValidPlayers().len() - 1)];
        }
        catch(e1)
        {
            return GetValidClients()[RandomInt(0, GetValidClients().len() - 1)];
        }
    }
}