// Script by: Delfite
// Considering the fact that Lanko, without warning, can break Sourcemod on the server when he makes changes to the backend,
// I figured it would eventually become necessary to make this script as a backup means of testing things on the server.
// It also saves us the hassle of having to manage permissions in Sourcemod, but at the downside of needing to assign each
// player their own case in the switch.

::devModeActive <- GetPersistentVar("devModeActive")

AddListener("setup_start", 0, function ()
{
	if (devModeActive)
		return;

	SetPersistentVar("devModeActive", false)
})


function OnGameEvent_player_say(params)
{
    local speaker = GetPlayerFromUserID(params.userid);
    if (!IsValidPlayer(speaker))
        return;
    // local userid = GetPlayerFromParams(params, "userid");
    // if (!IsValidPlayer(userid))
    //     return;
    FireListeners("player_say", speaker, userid, params);
}

// function OnGameEvent_player_disconnect(params)
// {
// 	printl(params.reason)
// 	DisconnectOutput("Silly bots! Don't you have anything better to do?")
// }

// function OnGameEvent_player_connect_client(params)
// {
// 	printl("Player kicked.")
// 	SendToServerConsole("kickid " + userid + " Silly bots! Don't you have anything better to do?")
// }

AddListener("setup_start", 0, function ()
{
	local map_list = SendToServerConsole("maps *")
	local map_list_output = split(map_list, "\n", false)
	for (local i = 0; i < map_list_output.len(); i++)
	{
		printl(map_list_output[i])
	}
})

AddListener("player_say", 0, function (speaker, userid, params)
{
	local text = params.text
	local output = split(text, " ", false)
	for(local i = 0; i < output.len(); i++)
	{
		printl(output[i])
	}

	switch (speaker.GetPlayerSteamID())
	{
		case SENNI:
		case LIZARDOFOZ:
		case LANKO:
		case DELFITE:
			if (output.find("/vsh") != null)
			{
				if (output.find("dev") != null)
				{
					if (output.find("query") != null)
						ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46devModeActive = " + devModeActive)
					else if (output.find("enable") != null)
					{
						if (devModeActive)
						{
							ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Developer mode is already active! Returning...")
							return;
						}
						ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Attention! Developer mode activated by " + speaker.GetPlayerName() + ". If they give you instructions, please follow them!");
						devModeActive = true;
					}
					else if (output.find("disable") != null)
					{
						if (!devModeActive)
						{
							ClientPrint(null, 3, "\x076914FF[VSH] \x0728FF46Developer mode is already inactive! Returning...")
							return;
						}
						ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Developer mode deactivated by " + speaker.GetPlayerName() + ".");
						devModeActive = false;
					}
					else
					{
						ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Valid parameters: query, enable, disable")
					}
				}
				else if (output.find("hale") != null)
				{
					if (output.find("next") != null)
						ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46The next Hale will be: " + GetNextBoss().GetPlayerName());
					else if (output.find("set") != null)
					{
						if (output.find("!self") != null)
						{
							SetNextBossByUserId(params.userid)
							ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Next Hale set to: " + speaker.GetPlayerName());
						}
						else if (output.find(userid) != null)
						{
							if (GetPlayerFromUserID(userid) == null)
							{
								ClientPrint(null, 3, "\x076914FF[VSH DEV] \x07F2AC0AError: The provided userid no longer exists. Please try again.")
								return;
							}
							else
							{
								SetNextBossByUserId(userid)
								ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Next Hale set to: " + GetPlayerFromUserID(userid).GetPlayerName());
							}
						}
						else
						{
							printl("userid: " + userid)
							ClientPrint(null, 3, "\x076914FF[VSH DEV] \x07F2AC0AError: Insufficient parameters. Please provide a valid userid.")
						}
					}
				}
				else if (output.find("newround") != null)
				{
					ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Starting new round...");
					SendToServerConsole("mp_restartgame_immediate 1")
				}
				else if (output.find("changelevel") != null)
				{
					if (output.find("*") != null)
					{
						destination <- output.find(" *");


						// RunWithDelay2(this, 1.5, function ()
						// {
						// 	SendToServerConsole("changelevel " + destination)
						// })
						ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Changing level to: " + destination);
					}
					else
						ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Error: No map provided.");
				}
				else
				{
					ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46===LOOS VSH===");
					ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Version: 9.0");
					ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Created by: Senni, Delfite");
					ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46With help from: Dice, Horiuchi, Bradasparky");
				}
			}
		break;

		default:
			if (output.find("/vsh") != null)
			{
				ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46===LOOS VSH===");
				ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Version: 9.0");
				ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46Created by: Senni, Delfite");
				ClientPrint(null, 3, "\x076914FF[VSH DEV] \x0728FF46With help from: Dice, Horiuchi, Bradasparky");
			}
		break;
	}
})