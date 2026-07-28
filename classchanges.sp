#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

public Plugin myinfo =
{
    name = "VSH Class Changes",
    author = "Senni",
    description = "Displays custom class balance changes in Vscript VSH.",
    version = "1.2c"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_changes", Command_Changes);
    RegConsoleCmd("sm_classchanges", Command_Changes);
}

Handle g_hAdvertTimer = INVALID_HANDLE;

public void OnMapStart()
{
    if (g_hAdvertTimer != INVALID_HANDLE)
    {
        delete g_hAdvertTimer;
    }

    g_hAdvertTimer = CreateTimer(60.0, Timer_Advert, _, TIMER_REPEAT);
}

public Action Timer_Advert(Handle timer)
{
    PrintToChatAll("\x04[VSH]\x01 Type \x03!changes\x01 to view the custom class balance changes.");
    return Plugin_Continue;
}

public Action Command_Changes(int client, int args)
{
    if (!IsClientInGame(client))
        return Plugin_Handled;

    ShowClassChanges(client);
    return Plugin_Handled;
}

void ShowClassChanges(int client)
{
    TFClassType class = TF2_GetPlayerClass(client);

    Panel panel = new Panel();

    switch (class)
    {
        case TFClass_Scout:
        {
            panel.SetTitle("Scout Changes");

            panel.DrawText("- Back Scatter accuracy penalty removed.");
            panel.DrawText("- Crit-a-Cola cooldown reduced by 35%.");
            panel.DrawText("- Bonk! cooldown reduced by 35%.");
            panel.DrawText("- Crit-a-Cola no longer Marks For Death.");
        }

        case TFClass_Soldier:
        {
            panel.SetTitle("Soldier Changes");

            panel.DrawText("- Gunboats cancel fall damage.");
            panel.DrawText("- Black Box heals up to 50 HP.");
            panel.DrawText("- Beggar's Bazooka deviation removed.");
            panel.DrawText("- Battalion's Backup resists Hale abilities.");
            panel.DrawText("- Rocket Launchers gain +25% projectile speed.");
            panel.DrawText("  (Except Direct Hit & Liberty Launcher)");
            panel.DrawText("- Banners charge passively in 60 seconds.");
            panel.DrawText("- No Marked for Death on the Escape Plan.");
        }

        case TFClass_Pyro:
        {
            panel.SetTitle("Pyro Changes");

            panel.DrawText("- Base HP increased to 200.");
            panel.DrawText("- Axtinguisher restores half missing HP.");
            panel.DrawText("- Gas Passer explodes on ignite.");
            panel.DrawText("- Gas Passer now requires 800 damage.");
            panel.DrawText("- Gas Passer deploy speed reduced 15%.");
            panel.DrawText("- Manmelter stores crits from primary damage.");
            panel.DrawText("- Airblast only works directly above/below Hale.");
        }

        case TFClass_DemoMan:
        {
            panel.SetTitle("Demoman Changes");

            panel.DrawText("- Ullapool Caber recharges after 15 sec.");
            panel.DrawText("- Sticky Jumper limited to one sticky.");
            panel.DrawText("- Grenade Launchers gain +25% projectile speed.");
            panel.DrawText("  (Except Loch-n-Load)");
            panel.DrawText("- Claidheamh Mor & Tide Turner");
            panel.DrawText("  gain charge on hit instead of kill.");
        }

        case TFClass_Heavy:
        {
            panel.SetTitle("Heavy Changes");

            panel.DrawText("- Huo-Long Heater spin-up costs no ammo.");
            panel.DrawText("- Brass Beast spin movement penalty reduced.");
            panel.DrawText("- Can switch weapons during minigun unrev.");
            panel.DrawText("- No health drain on Gloves of Running Urgently.");
        }

        case TFClass_Engineer:
        {
            panel.SetTitle("Engineer Changes");

            panel.DrawText("- Teleporters work both directions.");
            panel.DrawText("- No Marked for Death on the Rescue Ranger.");
        }

        case TFClass_Medic:
        {
            panel.SetTitle("Medic Changes");

            panel.DrawText("- Spawn with 100% UberCharge.");
        }

        case TFClass_Sniper:
        {
            panel.SetTitle("Sniper Changes");

            panel.DrawText("No class changes.");
        }

        case TFClass_Spy:
        {
            panel.SetTitle("Spy Changes");

            panel.DrawText("- Cloak and Dagger mirrors stock Invis Watch.");
            panel.DrawText("- Base movement speed increased by 20%.");
            panel.DrawText("- Spy cannot pick up ammo boxes while invisible.");
        }

        default:
        {
            panel.SetTitle("Class Changes");
            panel.DrawText("Join a class first.");
        }
    }

    panel.DrawItem("Close");

    panel.Send(client, PanelHandler, 30);
    delete panel;
}

public int PanelHandler(Menu menu, MenuAction action, int param1, int param2)
{
    return 0;
}
