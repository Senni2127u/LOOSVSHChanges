#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION  "2.2"
#define MAX_LINE_LEN    512
#define MAX_WEAPON_NAME 64

public Plugin myinfo =
{
    name        = "VSH Class Changes",
    author      = "Senni, Delfite",
    description = "Displays custom class balance changes, filtered to the weapons the player currently has equipped.",
    version     = PLUGIN_VERSION
};

#define MAX_ITEM_DEFS   6

// Controls display order of weapon-specific entries within a class (lower = shown first).
// Slot_PDA covers watches/PDAs and anything else that isn't primary/secondary/melee.
enum
{
    Slot_PDA = 0,
    Slot_Primary,
    Slot_Secondary,
    Slot_Melee
}

enum struct ChangeEntry
{
    TFClassType classType;
    char weaponName[MAX_WEAPON_NAME]; // empty = class-wide, always shown regardless of loadout
    int  itemDefs[MAX_ITEM_DEFS];     // any of these matching the player's equipped weapon shows this entry
    int  itemDefCount;                // 0 = unresolved/none set - falls back to "always show"
    int  slot;                        // Slot_* - governs ordering within Pass 2 (weapon-specific entries)
    ArrayList lines;                  // handle to an ArrayList of strings (ByteCountToCells(MAX_LINE_LEN) blocks)
}

ArrayList g_Entries;        // blocks of ChangeEntry
Handle    g_hAdvertTimer = null;

// ------------------------------------------------------------------
// Setup
// ------------------------------------------------------------------

public void OnPluginStart()
{
    RegConsoleCmd("sm_loadout", Command_Loadout);
    RegConsoleCmd("sm_loadoutchanges", Command_Loadout);
    RegAdminCmd("sm_weaponid", Command_WeaponId, ADMFLAG_GENERIC,
        "Prints the item definition index + schema name of your active weapon. Use this to check why a change entry isn't matching your loadout.");

    g_Entries = new ArrayList(sizeof(ChangeEntry));
    BuildChangeEntries();
    ApplyDefindexOverrides();
    HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public void OnMapStart()
{
    if (g_hAdvertTimer != null)
    {
        delete g_hAdvertTimer;
    }
    g_hAdvertTimer = CreateTimer(90.0, Timer_Advert, _, TIMER_REPEAT);
}

void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client_id = event.GetInt("userid");
    int client = GetClientOfUserId(client_id);
    
    ShowLoadoutChanges(client);
}

public Action Timer_Advert(Handle timer)
{
    PrintToChatAll("\x04[VSH]\x01 Type \x03!loadout\x01 to view the changes for your current loadout.");
    // PrintToChatAll("\x04[VSH]\x01 Type \x03!changes\x01 to view all changes made to the gamemode.");
    return Plugin_Continue;
}

// ------------------------------------------------------------------
// Commands
// ------------------------------------------------------------------

public Action Command_Loadout(int client, int args)
{
    if (client == 0 || !IsClientInGame(client))
        return Plugin_Handled;

    ShowLoadoutChanges(client);
    return Plugin_Handled;
}

public Action Command_WeaponId(int client, int args)
{
    if (client == 0 || !IsClientInGame(client))
        return Plugin_Handled;

    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (weapon <= MaxClients || !IsValidEntity(weapon))
    {
        ReplyToCommand(client, "[VSH] No active weapon.");
        return Plugin_Handled;
    }

    int def = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));

    ReplyToCommand(client, "[VSH] Active weapon defindex: %d | entity classname: \"%s\"", def, classname);
    ReplyToCommand(client, "[VSH] Add this line near the bottom of classchanges.sp: SetWeaponDef(\"<exact name used in AddEntry>\", %d);", def);
    return Plugin_Handled;
}

// ------------------------------------------------------------------
// Resolving weapon names against the live item schema
// ------------------------------------------------------------------

// Applies a verified item definition index to every entry that has this exact
// weaponName (optionally scoped to one class, for cases like "Shotgun" where you
// want to confirm it's really the same defindex across classes before assuming so).
// Until you call this for a given weapon, that weapon's entries stay itemDefCount = 0,
// which ShowLoadoutChanges() treats as "always show" - so nothing is ever silently
// hidden by a wrong or missing number, it just isn't filtered by loadout yet.
void SetWeaponDefs(const char[] weaponName, const int[] itemDefs, int count, TFClassType class = TFClass_Unknown)
{
    if (count > MAX_ITEM_DEFS)
        count = MAX_ITEM_DEFS; // silently clamp rather than overflow the struct's fixed array

    int total = g_Entries.Length;
    for (int i = 0; i < total; i++)
    {
        ChangeEntry e;
        g_Entries.GetArray(i, e);

        if (!StrEqual(e.weaponName, weaponName, false))
            continue;
        if (class != TFClass_Unknown && e.classType != class)
            continue;

        for (int k = 0; k < count; k++)
        {
            e.itemDefs[k] = itemDefs[k];
        }
        e.itemDefCount = count;
        g_Entries.SetArray(i, e);
    }
}

// Convenience wrapper for the common case of a single defindex - used by most
// of the calls below. Use SetWeaponDefs() directly when a weapon needs to
// match more than one defindex (e.g. a Strange/Renamed variant, see usage note
// in ApplyDefindexOverrides()).
void SetWeaponDef(const char[] weaponName, int itemDef, TFClassType class = TFClass_Unknown)
{
    int ids[1];
    ids[0] = itemDef;
    SetWeaponDefs(weaponName, ids, 1, class);
}

// ------------------------------------------------------------------
// Display
// ------------------------------------------------------------------

void DrawEntryLines(Panel panel, ChangeEntry e)
{
    if (e.lines == null)
        return;

    int count = e.lines.Length;
    char buffer[MAX_LINE_LEN];
    for (int l = 0; l < count; l++)
    {
        e.lines.GetString(l, buffer, sizeof(buffer));
        panel.DrawText(buffer);
    }
}

bool ClientHasAnyWeaponDef(int client, const int[] itemDefs, int count)
{
    for (int slot = 0; slot <= 5; slot++)
    {
        int weapon = GetPlayerWeaponSlot(client, slot);
        if (weapon == -1 || !IsValidEntity(weapon))
            continue;

        if (EntityMatchesDefs(weapon, itemDefs, count))
            return true;
    }

    // Boots and shields (Gunboats, Chargin' Targe, Tide Turner, etc.) are wearables,
    // not weapons, so they never appear in GetPlayerWeaponSlot().
    if (ClientWearsAnyDef(client, "tf_wearable", itemDefs, count))
        return true;
    if (ClientWearsAnyDef(client, "tf_wearable_demoshield", itemDefs, count))
        return true;

    return false;
}

bool EntityMatchesDefs(int entity, const int[] itemDefs, int count)
{
    int def = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
    for (int k = 0; k < count; k++)
    {
        if (def == itemDefs[k])
            return true;
    }
    return false;
}

bool ClientWearsAnyDef(int client, const char[] classname, const int[] itemDefs, int count)
{
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, classname)) != -1)
    {
        if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") != client)
            continue;

        if (EntityMatchesDefs(ent, itemDefs, count))
            return true;
    }
    return false;
}

void ShowLoadoutChanges(int client)
{
    TFClassType class = TF2_GetPlayerClass(client);

    Panel panel = new Panel();

    if (class == TFClass_Unknown)
    {
        panel.SetTitle("Class Changes");
        panel.DrawText("Pick a class first and wait to respawn.");
        panel.DrawItem("Close");
        panel.Send(client, PanelHandler, 30);
        delete panel;
        return;
    }

    char className[16];
    GetClassName(class, className, sizeof(className));

    char title[64];
    FormatEx(title, sizeof(title), "%s Changes (Your Loadout)", className);
    panel.SetTitle(title);

    int total = g_Entries.Length;
    bool printedAnything = false;

    // Pass 1: class-wide entries first (no weapon needed to see these).
    for (int i = 0; i < total; i++)
    {
        ChangeEntry e;
        g_Entries.GetArray(i, e);

        if (e.classType != class || e.weaponName[0] != '\0')
            continue;

        DrawEntryLines(panel, e);
        printedAnything = true;
    }

    // Pass 2: weapon-specific entries, only for weapons the player currently has equipped
    // (or entries whose name failed to resolve, shown as a safe fallback). Grouped by slot
    // (PDA, then primary, then secondary, then melee) so e.g. secondaries always list above
    // melee weapons, regardless of the order they were added in BuildChangeEntries().
    static const int slotOrder[] = { Slot_PDA, Slot_Primary, Slot_Secondary, Slot_Melee };
    for (int s = 0; s < sizeof(slotOrder); s++)
    {
        for (int i = 0; i < total; i++)
        {
            ChangeEntry e;
            g_Entries.GetArray(i, e);

            if (e.classType != class || e.weaponName[0] == '\0' || e.slot != slotOrder[s])
                continue;

            bool show = (e.itemDefCount == 0) || ClientHasAnyWeaponDef(client, e.itemDefs, e.itemDefCount);
            if (!show)
                continue;

            // Weapon name shown as a selectable menu item (matches the rest of the panel's
            // clickable style), but PanelHandler() is a no-op, so selecting it does nothing.
            panel.DrawItem(e.weaponName);

            DrawEntryLines(panel, e);
            printedAnything = true;
        }
    }

    if (!printedAnything)
    {
        panel.DrawText("No changes to your current loadout.");
    }

    panel.DrawItem("Close");
    panel.Send(client, PanelHandler, 30);
    delete panel;
}

public int PanelHandler(Menu menu, MenuAction action, int param1, int param2)
{
    return 0;
}

void GetClassName(TFClassType class, char[] buffer, int maxlen)
{
    switch (class)
    {
        case TFClass_Scout:    strcopy(buffer, maxlen, "Scout");
        case TFClass_Soldier:  strcopy(buffer, maxlen, "Soldier");
        case TFClass_Pyro:     strcopy(buffer, maxlen, "Pyro");
        case TFClass_DemoMan:  strcopy(buffer, maxlen, "Demoman");
        case TFClass_Heavy:    strcopy(buffer, maxlen, "Heavy");
        case TFClass_Engineer: strcopy(buffer, maxlen, "Engineer");
        case TFClass_Medic:    strcopy(buffer, maxlen, "Medic");
        case TFClass_Sniper:   strcopy(buffer, maxlen, "Sniper");
        case TFClass_Spy:      strcopy(buffer, maxlen, "Spy");
        default:               strcopy(buffer, maxlen, "Unknown");
    }
}

// ------------------------------------------------------------------
// Data - one AddEntry() + a run of AddLine() calls per weapon / per
// class-wide note. weaponName == "" means "always show for this class".
// ------------------------------------------------------------------

void AddEntry(TFClassType class, const char[] weaponName, int slot = Slot_Primary)
{
    ChangeEntry e;
    e.classType = class;
    strcopy(e.weaponName, MAX_WEAPON_NAME, weaponName);
    e.itemDefCount = 0; // 0 = unresolved, falls back to "always show" until SetWeaponDef(s) is called
    e.slot = slot;
    e.lines = new ArrayList(ByteCountToCells(MAX_LINE_LEN));
    g_Entries.PushArray(e);
}

void AddLine(const char[] line)
{
    int last = g_Entries.Length - 1;
    ChangeEntry e;
    g_Entries.GetArray(last, e);

    // e.lines is a handle - the ArrayList itself is mutated in place,
    // so no need to write the struct back afterward.
    e.lines.PushString(line);
}

void BuildChangeEntries()
{
    // ===================== SCOUT =====================
    AddEntry(TFClass_Scout, "Scattergun");
    AddLine("Damage increased: +40%.");
    AddLine("Reload speed increased: +10%.");
    AddLine("Fire rate increased: +10%.");
    AddLine("Accuracy increased: +15%.");

    AddEntry(TFClass_Scout, "Force-A-Nature");
    AddLine("-10% Damage penalty removed.");
    AddLine("Pellets per shot increased: +80%.");
    AddLine("Reserve ammo reduced: +50%.");
    AddLine("Now uses the Panic Attack's fixed pellet spread.");

    AddEntry(TFClass_Scout, "Shortstop");
    AddLine("Accuracy increased: +65%.");
    AddLine("Reload speed increased: +10%.");
    AddLine("Damage increased: +15%.");

    AddEntry(TFClass_Scout, "Back Scatter");
    AddLine("No accuracy penalty.");


    AddEntry(TFClass_Scout, "Pistol", Slot_Secondary);
    AddLine("Reserve ammo quadrupled (36 -> 144).");
    AddLine("Perfectly accurate.");
    AddLine("Fire rate increased: +15%.");
    AddLine("Damage per bullet increased: 15 -> 18 (+20%).");

    AddEntry(TFClass_Scout, "Winger", Slot_Secondary);
    AddLine("Reserve ammo quadrupled (36 -> 144).");
    AddLine("Perfectly accurate.");

    AddEntry(TFClass_Scout, "Pretty Boy's Pocket Pistol", Slot_Secondary);
    AddLine("Reserve ammo quadrupled (36 -> 144).");
    AddLine("Perfectly accurate.");
    AddLine("Healing per bullet increased: 3 -> 5.");

    AddEntry(TFClass_Scout, "Bonk! Atomic Punch", Slot_Secondary);
    AddLine("Recharge time reduced by 35%.");

    AddEntry(TFClass_Scout, "Crit-a-Cola", Slot_Secondary);
    AddLine("Recharge time reduced by 35%.");
    AddLine("No Marked For Death While Active.");

    AddEntry(TFClass_Scout, "Flying Guillotine", Slot_Secondary);
    AddLine("Crits whenever it would normally mini-crit.");
    AddLine("Recharge time increased: 5 -> 8 seconds (+60%).");
    AddLine("Projectile speed doubled.");


    AddEntry(TFClass_Scout, "Bat", Slot_Melee);
    AddLine("Damage per swing increased: 105 -> 195 (+86%).");

    AddEntry(TFClass_Scout, "Atomizer", Slot_Melee);
    AddLine("Deploy speed penalty halved (+50% -> +25%).");

    AddEntry(TFClass_Scout, "Candy Cane", Slot_Melee);
    AddLine("+25% Blast vulnerability removed.");
    AddLine("Spawns a small medkit for every melee hit you land.");
    AddLine("Spawns a small medkit for every 150 damage dealt.");

    AddEntry(TFClass_Scout, "Boston Basher", Slot_Melee);
    AddLine("Bleed duration increased: 6 seconds -> 10 seconds.");
    AddLine("Causes all bleed damage to crit.");
    AddLine("Hitting yourself inflicts no bleed.");
    AddLine("Hitting yourself grants more upward force than usual.");

    // ===================== SOLDIER =====================
    AddEntry(TFClass_Soldier, "");
    AddLine("Base movement speed increased: 240 HU/s -> 300 HU/s.");


    AddEntry(TFClass_Soldier, "Rocket Launcher");
    AddLine("Projectile speed increased: +40%.");
    AddLine("Reload speed increased: +25%.");
    AddLine("Fire rate increased: +10%.");

    AddEntry(TFClass_Soldier, "Black Box");
    AddLine("Gain up to 50 health on hit.");
    AddLine("Projectile speed increased: +40%.");

    AddEntry(TFClass_Soldier, "Beggar's Bazooka");
    AddLine("Projectile speed increased: +40%.");
    AddLine("Reload speed increased: +25%.");
    AddLine("Random rocket deviation removed.");

    AddEntry(TFClass_Soldier, "Air Strike");
    AddLine("Projectile speed increased: +25% -> +40%.");

    AddEntry(TFClass_Soldier, "Liberty Launcher");
    AddLine("Projectile speed increased: +40% -> +65%.");
    AddLine("Blast jump resistance increased: +25% -> +100%.");

    AddEntry(TFClass_Soldier, "Direct Hit");
    AddLine("Damage bonus reduced: +25% -> +15%");
    AddLine("Projectile speed increased: +80% -> +250%.");
    AddLine("Airborne mini-crits are now crits instead.");


    AddEntry(TFClass_Soldier, "Righteous Bison", Slot_Secondary);
    AddLine("Damage increased: +50%.");
    AddLine("Crit damage reduced: -33%.");
    AddLine("Fire rate increased: +20%.");
    AddLine("Reload speed increased: +20%.");
    AddLine("Projectile speed tripled.");

    AddEntry(TFClass_Soldier, "Buff Banner", Slot_Secondary);
    AddLine("Rage builds passively over 60 seconds.");
    AddLine("Buff duration increased: 10 seconds -> 15 seconds (+50%).");
    AddLine("Buff range increased: 450 HU -> 700 HU (+55%).");
    AddLine("Activates automatically and instantly when swapped to.");

    AddEntry(TFClass_Soldier, "Battalion's Backup", Slot_Secondary);
    AddLine("Rage builds passively over 60 seconds.");
    AddLine("The Battalions' effects now resist Hale's abilities.");
    AddLine("Buff duration increased: 10 seconds -> 15 seconds (+50%).");
    AddLine("Buff range increased: 450 HU -> 700 HU (+55%).");
    AddLine("Activates automatically and instantly when swapped to.");

    AddEntry(TFClass_Soldier, "Concheror", Slot_Secondary);
    AddLine("Rage builds passively over 60 seconds.");
    AddLine("Buff duration increased: 10 seconds -> 15 seconds (+50%).");
    AddLine("Buff range increased: 450 HU -> 700 HU (+55%).");
    AddLine("Activates automatically and instantly when swapped to.");

    AddEntry(TFClass_Soldier, "Gunboats", Slot_Secondary);
    AddLine("Wearer takes no fall damage.");


    AddEntry(TFClass_Soldier, "Shovel", Slot_Melee);
    AddLine("Damage increased: 195 -> 253 (+30%).");

    AddEntry(TFClass_Soldier, "Escape Plan", Slot_Melee);
    AddLine("Movement speed no longer scales with missing health.");
    AddLine("Movement speed while active: +20%.");
    AddLine("Damage reduced: 195 -> 126 (-35%).");
    AddLine("User is no longer Marked-For-Death.");
    AddLine("Tauntkill inflicts no self-damage.");

    AddEntry(TFClass_Soldier, "Equalizer", Slot_Melee);
    AddLine("Tauntkill inflicts no self-damage.");

    AddEntry(TFClass_Soldier, "Market Gardener", Slot_Melee);
    AddLine("Movement speed reduced: -10%");
    AddLine("Can now deal knockback to Hale while grounded.");
    AddLine("Knockback is reduced while blast-jumping.");


    // ===================== PYRO =====================
    AddEntry(TFClass_Pyro, "");
    AddLine("Base HP increased: 175 -> 200.");
    AddLine("Airblast only works when looking straight up or down.");
    AddLine("Airblast no longer locks Hale's movement.");


    AddEntry(TFClass_Pyro, "Flamethrower");
    AddLine("-40% Max overheal.");

    AddEntry(TFClass_Pyro, "Degreaser");
    AddLine("-40% Max overheal.");

    AddEntry(TFClass_Pyro, "Backburner");
    AddLine("-40% Max overheal.");

    AddEntry(TFClass_Pyro, "Dragon's Fury");
    AddLine("No changes.");

    AddEntry(TFClass_Pyro, "Phlogistinator");
    AddLine("No changes.");


    AddEntry(TFClass_Pyro, "Gas Passer", Slot_Secondary);
    AddLine("Explodes on ignite.");
    AddLine("Damage required to charge: 750 -> 800.");
    AddLine("Deploy/Holster speed increased: +30%.");

    AddEntry(TFClass_Pyro, "Flare Gun", Slot_Secondary);
    AddLine("Damage increased: 38 -> 75 (+100%).");
    AddLine("Crit damage increased: +66%.");
    AddLine("Projectile speed increased: +50%.");

    AddEntry(TFClass_Pyro, "Detonator", Slot_Secondary);
    AddLine("Wearer is immune to their own flare damage.");
    AddLine("Projectile speed increased: +25%");
    AddLine("Blast radius increased: +35%");
    AddLine("Fire rate increased: +80%");
    AddLine("Increased momentum gained from flare-jumping.");
    AddLine("Air control while flare-jumping increased: +300%");
    AddLine("Wearer can Mantreads-stomp Hale.");

    AddEntry(TFClass_Pyro, "Detonator", Slot_Secondary);
    AddLine("Deploy/Holster speed drastically increased.");
    AddLine("Launch delay reduced.");
    AddLine("User can re-launch in mid-air.");
    AddLine("Momentum is preserved when (re)launching.");
    AddLine("User only takes fall damage when stomping Hale.");
    AddLine("Recharge time reduced (in seconds): 30 -> 20 (10 per charge).");
    AddLine("Recharges with damage dealt: 800 total, 400 per charge.");
    AddLine("Air control while jetpacking increased: +500%");

    AddEntry(TFClass_Pyro, "Manmelter", Slot_Secondary);
    AddLine("Stores crits from primary fire damage.");


    AddEntry(TFClass_Pyro, "Axtinguisher", Slot_Melee);
    AddLine("Restores +50% of max health on burning hits.");
    AddLine("No longer grants a speed boost on burning hits.");

    AddEntry(TFClass_Pyro, "Powerjack", Slot_Melee);
    AddLine("Movement speed while active increased: +15% -> +30%.");
    AddLine("20% damage vulnerability removed.");
    AddLine("Damage reduced: -60%.");
    AddLine("+25 health on hit removed.");

    // ===================== DEMOMAN =====================
    AddEntry(TFClass_DemoMan, "");
    AddLine("Base health increased: 175 -> 200.");
    AddLine("Base movement speed increased: 280 HU/s -> 300 HU/s.");


    AddEntry(TFClass_DemoMan, "Grenade Launcher");
    AddLine("Projectile speed increased: +35%.");
    AddLine("Mag size increased: 4 -> 6 (+50%).");
    AddLine("Reserve ammo increased: 16 -> 24 (+50%).");
    AddLine("Reload speed increased: +20%.");
    AddLine("Fire rate increased: +15%.");
    AddLine("Grenades have very little roll.");

    AddEntry(TFClass_DemoMan, "Iron Bomber");
    AddLine("Projectile speed increased: +50%.");
    AddLine("Fuse time decreased: -30% -> -80%.");
    AddLine("Blast radius increased: -15% -> +35%.");
    AddLine("Blast-jump resistance increased: +75%.");
    AddLine("Self-damage push force increased: +20%.");
    AddLine("Reserve ammo increased: 16 -> 24 (+50%).");
    AddLine("Damage reduced: 150 -> 120 (-20%).");

    AddEntry(TFClass_DemoMan, "Loch-n-Load");
    AddLine("Projectile speed increased: +25% -> +60%.");
    AddLine("Damage increased: 150 -> 180 (+20%).");
    AddLine("Fire rate increased: +20%.");
    AddLine("Mag size increased: 3 -> 4 (+33%).");

    AddEntry(TFClass_DemoMan, "Loose Cannon");
    AddLine("Projectile speed increased: +55%.");

    AddEntry(TFClass_DemoMan, "B.A.S.E. Jumper", Slot_Secondary);
    AddLine("Blast-jump resistance increased: +60%.");


    AddEntry(TFClass_DemoMan, "Stickybomb Launcher", Slot_Secondary);
    AddLine("Projectile speed increased: +20%.");
    AddLine("Blast radius increased: +20%.");
    AddLine("Fire rate increased: +25%.");

    AddEntry(TFClass_DemoMan, "Scottish Resistance", Slot_Secondary);
    AddLine("Damage reduced: -10%.");
    AddLine("Reload speed increased: +15%.");

    AddEntry(TFClass_DemoMan, "Quickiebomb Launcher", Slot_Secondary);
    AddLine("Projectile speed increased: +20%.");
    AddLine("Blast radius increased: +50%.");
    AddLine("Mag size penalty reduced: -50% -> -25%.");
    AddLine("Max stickybombs out reduced: 8 -> 6 (-25%).");

    AddEntry(TFClass_DemoMan, "Sticky Jumper", Slot_Secondary);
    AddLine("Max stickybombs out reduced: 2 -> 1 (-50%).");

    AddEntry(TFClass_DemoMan, "Chargin' Targe", Slot_Secondary);
    AddLine("Blast resistance increased: +30% -> +60%.");
    AddLine("Blast jump resistance increased: +60%.");
    AddLine("Charge turn control increased: +100%.");

    AddEntry(TFClass_DemoMan, "Splendid Screen", Slot_Secondary);
    AddLine("Blast resistance increased: +20% -> +30%.");
    AddLine("Fire resistance increased: +20% -> +30%.");
    AddLine("Charge turn control increased: +250%.");
    AddLine("Charge-on-hit increased: +20%.");

    AddEntry(TFClass_DemoMan, "Tide Turner", Slot_Secondary);
    AddLine("Gains charge on hit instead of on kill.");
    AddLine("Shield bash knockback reduced: 300 -> 180.");


    AddEntry(TFClass_DemoMan, "Bottle", Slot_Melee);
    AddLine("Movement speed while active: +20%.");

    AddEntry(TFClass_DemoMan, "Eyelander", Slot_Melee);
    AddLine("-25 Max health penalty removed.");
    AddLine("Health-on-hit increased: +15 -> +40.");
    AddLine("Max overheal reduced: -65%.");

    AddEntry(TFClass_DemoMan, "Claidheamh Mor", Slot_Melee);
    AddLine("+15% Damage vulnerability removed.");
    AddLine("Gains charge on hit instead of on kill.");

    AddEntry(TFClass_DemoMan, "Scotsman's Skullcutter", Slot_Melee);
    AddLine("-15% Movement speed penalty removed.");
    AddLine("Damage increased: +20% -> +40%.");

    AddEntry(TFClass_DemoMan, "Ullapool Caber", Slot_Melee);
    AddLine("Blast-jump resistance increased: +25%.");
    AddLine("Recharges in 12 seconds.");


    // ===================== HEAVY =====================
    AddEntry(TFClass_Heavy, "");
    AddLine("Base movement speed increased: 230 HU/s -> 300 HU/s.");


    AddEntry(TFClass_Heavy, "Minigun");
    AddLine("Can switch weapons while spinning down.");

    AddEntry(TFClass_Heavy, "Natascha");
    AddLine("Can switch weapons while spinning down.");
    AddLine("Damage resistance is no longer dependent on remaining health.");
    AddLine("Damage resistance reduced: +50% -> +30%.");

    AddEntry(TFClass_Heavy, "Tomislav");
    AddLine("Can switch weapons while spinning down.");

    AddEntry(TFClass_Heavy, "Huo-Long Heater");
    AddLine("Can switch weapons while spinning down.");
    AddLine("Spin-up costs no ammo.");

    AddEntry(TFClass_Heavy, "Brass Beast");
    AddLine("Can switch weapons while spinning down.");
    AddLine("Movement speed while spun-up increased: -60% -> -20%.");
    AddLine("Damage resistance is no longer dependent on remaining health.");
    AddLine("Damage resistance reduced: +50% -> +30%.");
    AddLine("Max overheal reduced: -50%.");
    AddLine("+20% Damage bonus removed.");


    AddEntry(TFClass_Heavy, "Family Business");
    AddLine("Pellets per shot increased: +50%.");
    AddLine("Reload speed increased: +50%.");
    AddLine("Accuracy increased: +30%.");
    AddLine("Fire rate increased: +15% -> +50%.");
    AddLine("-15% Damage penalty removed.");

    AddEntry(TFClass_Heavy, "Sandvich", Slot_Secondary);
    AddLine("Healing from medkits increased: +50%.");

    AddEntry(TFClass_Heavy, "Dalokohs Bar", Slot_Secondary);
    AddLine("Max health on wearer increased: +50.");
    AddLine("Health per meal increased: +100 -> +133.");
    // AddLine("Recharge rate doubled.");  // Doesn't work. Need to find a workaround.
    AddLine("No longer grants max health on consumption.");

    AddEntry(TFClass_Heavy, "Second Banana", Slot_Secondary);
    AddLine("Eating speed increased: +37.5%.");
    AddLine("Heals about half of your max health when eaten.");

    AddEntry(TFClass_Heavy, "Buffalo Steak Sandvich", Slot_Secondary);
    AddLine("Removed damage vulnerability.");
    AddLine("Eating speed increased: +37.5%."); // Need to test this.
    AddLine("Buff duration increased (in seconds): 10 -> 15.");
    AddLine("Movement speed bonuses now work alongside the Steak.");
    AddLine("No longer restricts you to melee.");
    AddLine("Accuracy increased while buffed: +20%.");
    AddLine("Melee swing speed increased while buffed: +15%.");


    AddEntry(TFClass_Heavy, "Fists", Slot_Melee);
    AddLine("Swing speed increased: +20%.");

    AddEntry(TFClass_Heavy, "Gloves of Running Urgently", Slot_Melee);
    AddLine("Max health drain removed.");

    AddEntry(TFClass_Heavy, "Killing Gloves of Boxing", Slot_Melee);
    AddLine("Critboost duration increased (in seconds): 5 -> 8.");
    AddLine("Now plays a sound effect when gaining your critboost.");

    AddEntry(TFClass_Heavy, "Eviction Notice", Slot_Melee);
    AddLine("Max health drain removed.");
    AddLine("Swing speed reduced: +40% -> +10%.");
    AddLine("Damage penalty reduced: -60% -> -50%.");
    AddLine("Speed boost duration increased (in seconds): 5 -> 8.");
    AddLine("Melee knockback halved.");

    AddEntry(TFClass_Heavy, "Fists of Steel", Slot_Melee);
    AddLine("+100% Melee vulnerability removed.");
    AddLine("Holster speed increased: -100% -> -50%.");

    AddEntry(TFClass_Heavy, "Warrior's Spirit", Slot_Melee);
    AddLine("Removed damage vulnerability.");
    AddLine("Health-on-hit increased: +50 -> +100.");
    AddLine("Holster speed reduced: -50%.");

    AddEntry(TFClass_Heavy, "Holiday Punch", Slot_Melee);
    AddLine("DO NOT USE! The HP's stun is currently broken!");
    AddLine("Please use a different melee in the meantime.");

    // ===================== ENGINEER =====================
    AddEntry(TFClass_Engineer, "");
    AddLine("Base health increased: 125 -> 150.");
    AddLine("Base movement speed increased: 300 HU/s -> 345 HU/s.");
    AddLine("Base metal increased: 200 -> 300.");
    AddLine("Toolbox deploy/holster speed increased: +50%.");
    AddLine("Teleporters work in both directions and always cost 50% less.");
    AddLine("Teleporter/Dispenser build speed increased: +300%.");
    AddLine("Sentries can deal critical hits.");
    AddLine("Sentry damage contributes to building upgrade progress.");
    AddLine("Upgrade progress triples under crits and auto-upgrades buildings.");
    AddLine("Sentry knockback drastically reduced.");
    AddLine("Sentry rocket velocity doubled.");

    AddEntry(TFClass_Engineer, "Frontier Justice");
    AddLine("Fire rate increased: +30%.");
    AddLine("Revenge crits are no longer stored in the sentry.");
    AddLine("Damage needed for a crit: 200 -> 150.");
    AddLine("Deal damage with your sentry or secondary to gain a crit.");
    AddLine("A sound effect will play upon receiving your first crit.");

    AddEntry(TFClass_Engineer, "Widowmaker");
    AddLine("Accuracy increased: +40%.");

    AddEntry(TFClass_Engineer, "Rescue Ranger");
    AddLine("User is no longer Marked-For-Death.");
    AddLine("Fire rate increased: +30%.");
    AddLine("Building teleport metal cost: -100 -> -50.");

    AddEntry(TFClass_Engineer, "Pomson 6000");
    AddLine("Damage increased: +50%.");
    AddLine("Crit damage reduced: -33%.");
    AddLine("Fire rate increased: +20%.");
    AddLine("Reload speed increased: +20%.");
    AddLine("Projectile speed tripled.");


    AddEntry(TFClass_Engineer, "Pistol", Slot_Secondary);
    AddLine("Fire rate increased: +15%.");
    AddLine("Damage increased: 15 -> 18 (+20%).");
    AddLine("Deploy/holster speed increased: +25%.");
    AddLine("Perfectly accurate.");

    AddEntry(TFClass_Engineer, "Short Circuit", Slot_Secondary);
    AddLine("Primary fire damage increased: 10 -> 20.");
    AddLine("Primary fire metal cost removed: 5 -> 0.");
    AddLine("Deploy/holster speed increased: +25%.");
    AddLine("Max metal increased: 300 -> 400 (+33%).");
    AddLine("This poor thing still has no range. I'm so sorry. -Delfite");

    AddEntry(TFClass_Engineer, "Wrangler", Slot_Secondary);
    // AddLine("Deploy speed increased: +35%.");
    AddLine("Wrangled sentries now emit a louder, pitched-up beeping sound.");
    AddLine("Hale hears a sound whenever a wrangled sentry is targeting him.");


    AddEntry(TFClass_Engineer, "Wrench", Slot_Melee);
    AddLine("Repair rate increased: +50%.");
    AddLine("Movement speed while active: +20%.");
    AddLine("Movement speed applies to your Toolbox and PDAs.");

    AddEntry(TFClass_Engineer, "Jag", Slot_Melee);
    AddLine("Sentry targeting range increased: +20%.");

    AddEntry(TFClass_Engineer, "Eureka Effect", Slot_Melee);
    AddLine("No longer reduces the cost of teleporters.");
    AddLine("Teleport buildings for 50 metal, just like the Rescue Ranger.");

    AddEntry(TFClass_Engineer, "Southern Hospitality", Slot_Melee);
    AddLine("Dispenser range increased: +200%.");

    AddEntry(TFClass_Engineer, "Gunslinger", Slot_Melee);
    AddLine("Melee and fall resistance increased: +30%.");
    AddLine("Sentry targeting range increased: +20%.");

    // ===================== MEDIC =====================
    AddEntry(TFClass_Medic, "");
    AddLine("Spawn with 100% UberCharge.");
    AddLine("Ubercharge build rate halved while healing another Medic.");
    AddLine("Ubercharge builds passively during Last Mann Standing.");
    // AddLine("^ 60 seconds to full, -15 seconds for each player that dies.");

    AddEntry(TFClass_Medic, "Syringe Gun");
    AddLine("Fire rate increased: +15%.");
    AddLine("Damage per syringe increased: 10 -> 15 (+50%).");

    AddEntry(TFClass_Medic, "Blutsauger");
    AddLine("Fire rate increased: +15%.");
    AddLine("Health-on-hit increased: 3 -> 5.");

    AddEntry(TFClass_Medic, "Overdose");
    AddLine("Fire rate increased: +15%.");
    AddLine("Movement speed increased: +20%.");
    AddLine("Movement speed no longer scales with UberCharge.");

    AddEntry(TFClass_Medic, "Crusader's Crossbow");
    AddLine("Damage while Kritkrieg'd reduced: -60%");


    AddEntry(TFClass_Medic, "Medigun", Slot_Secondary);
    AddLine("Heal yourself with your Ubercharge.");
    AddLine("-90% healing from other Medics while healing yourself.");

    AddEntry(TFClass_Medic, "Kritzkrieg", Slot_Secondary);
    AddLine("Heal yourself with your Ubercharge.");
    AddLine("-90% healing from other Medics while healing yourself.");
    AddLine("Your Ubercharge's effects remains active regardless of your held weapon.");
    AddLine("Ubercharge grants infinite ammo to you and your patient.");
    AddLine("Ubercharge duration increased (in seconds): 0 -> 2.");

    AddEntry(TFClass_Medic, "Quickfix", Slot_Secondary);
    AddLine("-50% Overheal penalty removed.");
    AddLine("Ubercharge duration increased (in seconds): 0 -> 4.");


    AddEntry(TFClass_Medic, "Bonesaw", Slot_Melee);
    AddLine("Movement speed while active: +25%.");

    AddEntry(TFClass_Medic, "Ubersaw", Slot_Melee);
    AddLine("Uber-on-hit reduced: +25% -> +20%.");
    AddLine("-20% Swing speed penalty removed.");

    AddEntry(TFClass_Medic, "Solemn Vow", Slot_Melee);
    AddLine("-10% Swing speed penalty removed.");
    AddLine("Restores half of your max health upon getting hit.");

    AddEntry(TFClass_Medic, "Vita-Saw", Slot_Melee);
    AddLine("Organs now grant +15 max health and +7% movement speed each.");
    AddLine("Stats cap out at 4 organs.");
    AddLine("Health-on-hit increased: +15.");

    AddEntry(TFClass_Medic, "Amputator", Slot_Melee);
    AddLine("Health regen while active increased: 3 -> 8");

    // ===================== SNIPER =====================
    AddEntry(TFClass_Sniper, "");
    AddLine("Base health increased: 125 -> 150.");
    AddLine("Base movement speed increased: 300 HU/s -> 345 HU/s.");

    AddEntry(TFClass_Sniper, "Sniper Rifle");
    AddLine("Fires the Classic's tracer rounds.");
    AddLine("Movement speed increased: +16%.");
    AddLine("Rifle charge rate increased: +15%.");

    AddEntry(TFClass_Sniper, "Machina");
    AddLine("Fires the Classic's tracer rounds.");
    AddLine("Damage pierces Hale's crit resistance.");
    AddLine("Max-charge damage increased: +15% -> +25%.");
    AddLine("Can now be fired while unscoped.");

    AddEntry(TFClass_Sniper, "Hitman's Heatmaker");
    AddLine("Fires the Classic's tracer rounds.");
    AddLine("Fire rate increased: +25%.");
    AddLine("Reload speed increased: +25%.");
    AddLine("Crits whenever it would normally mini-crit.");
    AddLine("Rifle charge rate increased: +15%.");

    AddEntry(TFClass_Sniper, "The Classic");
    AddLine("Rifle charge rate increased: +30%.");
    AddLine("Aiming movement speed increased: +180%.");
    AddLine("Can headshot even while not fully charged.");

    AddEntry(TFClass_Sniper, "Sydney Sleeper");
    AddLine("Rifle charge rate increased: +25% -> +35%.");

    AddEntry(TFClass_Sniper, "Huntsman");
    AddLine("Max health increased: +25 (150 -> 175).");
    AddLine("Projectile speed increased: +25%.");
    AddLine("Reload speed increased: +25%.");
    AddLine("Fire rate increased: +35%.");
    AddLine("Reserve ammo increased: 12 -> 25 (+100%).");
    AddLine("Melee and fall resistance increased: +30%.");


    AddEntry(TFClass_Sniper, "SMG", Slot_Secondary);
    AddLine("Fire rate increased: +15%.");
    AddLine("Damage per bullet increased: 8 -> 16 (+100%).");
    AddLine("Reserve ammo increased: 75 -> 200.");
    AddLine("Perfectly accurate.");

    AddEntry(TFClass_Sniper, "Cleaner's Carbine", Slot_Secondary);
    AddLine("25% fire rate penalty removed.");
    AddLine("Damage per bullet increased: 8 -> 14 (+75%).");
    AddLine("Reserve ammo increased: 75 -> 200.");
    AddLine("Perfectly accurate.");

    AddEntry(TFClass_Sniper, "Razorback", Slot_Secondary);
    AddLine("Upon getting hit by Hale:");
    AddLine("^ The Razorback will break, reducing damage taken by 60%.");
    AddLine("Recharge time reduced (in seconds): 30 -> 15.");
    AddLine("Now recharges with 550 damage dealt.");
    AddLine("Wearer takes no fall damage.");
    AddLine("-100% Overheal penalty removed.");

    AddEntry(TFClass_Sniper, "Darwin's Danger Shield", Slot_Secondary);
    AddLine("+50% Blast resistance.");

    AddEntry(TFClass_Sniper, "Cozy Camper", Slot_Secondary);
    AddLine("Health regen increased: +4 -> +10");
    AddLine("+50 Max health.");
    AddLine("-60% Max overheal.");


    AddEntry(TFClass_Sniper, "Kukri", Slot_Melee);
    AddLine("+20% Movement speed while active.");
    AddLine("Bonus is halved while the Sniper Rifle is equipped.");

    AddEntry(TFClass_Sniper, "Tribalmans' Shiv", Slot_Melee);
    AddLine("+30% Swing Speed.");

    AddEntry(TFClass_Sniper, "Shahanshah", Slot_Melee);
    AddLine("Damage while half dead increased: +25% -> +50%.");
    AddLine("Damage while half alive reduced: -25% -> -50%.");

    AddEntry(TFClass_Sniper, "Bushwacka", Slot_Melee);
    AddLine("Default melee crits removed.");
    AddLine("+20% Damage vulnerability removed.");
    AddLine("+40% Crit damage.");

    // ===================== SPY =====================
    AddEntry(TFClass_Spy, "");
    AddLine("Base movement speed increased: +20%.");
    AddLine("Cannot pick up ammo boxes while invisible.");
    AddLine("Getting hit by Saxton Punch! immediately decloaks you.");


    AddEntry(TFClass_Spy, "Revolver");
    AddLine("Perfectly accurate.");
    AddLine("Damage per bullet increased: 40 -> 80 (+100%).");
    AddLine("Fire rate increased: +15%.");
    AddLine("Reload speed increased: +15%.");

    AddEntry(TFClass_Spy, "Ambassador");
    AddLine("Perfectly accurate.");
    AddLine("Headshot damage doubled.");
    AddLine("Crits no longer suffer from falloff.");
    AddLine("Reload speed increased: +15%.");
    AddLine("Damage penalty increased: -15% -> -20%.");

    AddEntry(TFClass_Spy, "Diamondback");
    AddLine("Perfectly accurate.");
    AddLine("Removed 15% damage penalty.");

    AddEntry(TFClass_Spy, "Enforcer");
    AddLine("Perfectly accurate.");
    AddLine("Removed 20% fire rate penalty.");


    AddEntry(TFClass_Sniper, "Big Earner", Slot_Melee);
    AddLine("Speed boost duration increased (in seconds): 3 -> 10.");


    AddEntry(TFClass_Spy, "Cloak and Dagger", Slot_PDA);
    AddLine("Mirrors the stock Invis Watch.");

    // ===================== MULTI-CLASS SHARED ITEMS =====================
    // "Shotgun" resolves to the same item defindex across the classes that carry it,
    // so one AddEntry per class using the same weapon name is enough.
    static const TFClassType shotgunClasses[] = { TFClass_Soldier, TFClass_Pyro, TFClass_Heavy, TFClass_Engineer };
    for (int i = 0; i < sizeof(shotgunClasses); i++)
    {
        // Shotgun is Engineer's primary weapon, but a secondary for the other classes here.
        int shotgunSlot = (shotgunClasses[i] == TFClass_Engineer) ? Slot_Primary : Slot_Secondary;
        AddEntry(shotgunClasses[i], "Shotgun", shotgunSlot);
        AddLine("Heal-on-hit ratio: 2 damage to 1 health.");
        AddLine("Overheal bonuses/penalties affect max healing.");
        AddLine("Damage increased: +10%.");
        AddLine("Accuracy increased: +30%.");
        AddLine("Reload speed increased: +15%.");
        AddLine("Deploy speed increased: +20%.");
    }

    AddEntry(TFClass_Soldier, "Reserve Shooter", Slot_Secondary);
    AddLine("Airborne mini-crits are now airborne crits.");

    AddEntry(TFClass_Pyro, "Reserve Shooter", Slot_Secondary);
    AddLine("Airborne mini-crits are now airborne crits.");

    static const TFClassType panicAttackClasses[] = { TFClass_Soldier, TFClass_Pyro, TFClass_Heavy, TFClass_Engineer };
    for (int i = 0; i < sizeof(panicAttackClasses); i++)
    {
        // Panic Attack is Engineer's primary weapon, but a secondary for the other classes here.
        int panicAttackSlot = (panicAttackClasses[i] == TFClass_Engineer) ? Slot_Primary : Slot_Secondary;
        AddEntry(panicAttackClasses[i], "Panic Attack", panicAttackSlot);
        AddLine("Damage increased: -20% -> +25%.");
        AddLine("Accuracy increased: +40%.");
        AddLine("Reload speed increased: +40%.");
        AddLine("Fire rate increased: +30%.");
    }
}

void ApplyDefindexOverrides()
{
    // Values below are taken from https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
    // Note some names differ per-class defindex-wise (e.g. Pistol, Shotgun) - those pass a class arg.
    //
    // If a weapon needs to match more than one defindex - e.g. its "Renamed/Strange"
    // variant, which the wiki table lists as a separate index for the same weapon -
    // use SetWeaponDefs() instead of SetWeaponDef():
    //  Example below:
    //
    //   int scattergunIds[] = { 13, 200 };
    //   SetWeaponDefs("Scattergun", scattergunIds, sizeof(scattergunIds), TFClass_Scout);

    // Scout
    int scattergunIds[] = { 13, 200, 669, 799, 808, 888, 897, 906, 915, 964, 973, 15002, 15015, 15021, 15029, 15036, 15053, 15065, 15069, 15106, 15107, 15108, 15131, 15151, 15157 };
    int fanIds[] = { 45, 1078 };
    int pistolIds[] = { 22, 23, 160, 294, 1202 }; //Pistols have two different IDs for both Engineer and Scout, just catch both.
    int bonkpunchIds[] = { 46, 1145 };
    int batIds[]  = { 0, 190, 221, 264, 474, 572, 660, 423, 880, 939, 954, 999, 1013, 1071, 1123, 1127, 30667, 30758 };
    int madmilkIds[] = { 222, 1121 };
    int cleaverIds[] = { 812, 833 };
    int bostonbasherIds[] = { 325, 452 };

    SetWeaponDefs("Scattergun", scattergunIds, sizeof(scattergunIds), TFClass_Scout);
    SetWeaponDefs("Force-A-Nature", fanIds, sizeof(fanIds), TFClass_Scout);
    SetWeaponDef("Shortstop", 220, TFClass_Scout);
    SetWeaponDef("Back Scatter", 1103, TFClass_Scout);
    SetWeaponDefs("Pistol", pistolIds, sizeof(pistolIds), TFClass_Scout);
    SetWeaponDef("Winger", 449, TFClass_Scout);
    SetWeaponDef("Pretty Boy's Pocket Pistol", 773, TFClass_Scout);
    SetWeaponDefs("Bonk! Atomic Punch", bonkpunchIds, sizeof(bonkpunchIds), TFClass_Scout);
    SetWeaponDef("Crit-a-Cola", 163, TFClass_Scout);
    SetWeaponDefs("Flying Guillotine", cleaverIds, sizeof(cleaverIds), TFClass_Scout);
    SetWeaponDefs("Bat", batIds, sizeof(batIds), TFClass_Scout);
    SetWeaponDef("Atomizer", 450, TFClass_Scout);
    SetWeaponDef("Candy Cane", 317, TFClass_Scout);
    SetWeaponDefs("Boston Basher", bostonbasherIds, sizeof(bostonbasherIds), TFClass_Scout);

    // Soldier
    int rocketlauncherIds[] = { 18, 205, 513, 658, 800, 809, 889, 898, 907, 916, 965, 974, 15006, 15014, 15028, 15043, 15052, 15057, 15081, 15104, 15105, 15129, 15130, 15150 };
    int blackboxIds[]  = { 228, 1085 };
    int buffbannerIds[]  = { 129, 1001 };
    int shovelIds[]  = { 6, 196, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 30758 };

    SetWeaponDefs("Rocket Launcher", rocketlauncherIds, sizeof(rocketlauncherIds), TFClass_Soldier);
    SetWeaponDefs("Black Box", blackboxIds, sizeof(blackboxIds), TFClass_Soldier);
    SetWeaponDef("Beggar's Bazooka", 730, TFClass_Soldier);
    SetWeaponDef("Air Strike", 1104, TFClass_Soldier);
    SetWeaponDef("Liberty Launcher", 414, TFClass_Soldier);
    SetWeaponDef("Direct Hit", 127, TFClass_Soldier);
    SetWeaponDef("Rocket Jumper", 237, TFClass_Soldier);
    SetWeaponDef("Righteous Bison", 442, TFClass_Soldier);
    SetWeaponDef("Gunboats", 133, TFClass_Soldier);
    SetWeaponDefs("Buff Banner", buffbannerIds, sizeof(buffbannerIds), TFClass_Soldier);
    SetWeaponDef("Battalion's Backup", 226, TFClass_Soldier);
    SetWeaponDef("Concheror", 354, TFClass_Soldier);
    SetWeaponDefs("Shovel", shovelIds, sizeof(shovelIds), TFClass_Soldier);
    SetWeaponDef("Escape Plan", 775, TFClass_Soldier);
    SetWeaponDef("Equalizer", 128, TFClass_Soldier);
    SetWeaponDef("Market Gardener", 416, TFClass_Soldier);

    // Pyro
    int flamethrowerIds[]  = { 21, 208, 659, 741, 798, 807, 887, 896, 905, 914, 963, 972, 15005, 15017, 15030, 15034, 15049, 15054, 15066, 15067, 15068, 15089, 15090, 15115, 15141, 30474 };
    int backburnerIds[] = { 40, 1146 };
    int flaregunIds[]  = { 39, 1081 };
    int fireaxeIds[]  = { 2, 192, 264, 423, 474, 739, 880, 939, 954, 1013, 1071, 1123, 1127, 30758 };
    int axtinguisherIds[]  = { 38, 457, 1000 };
    int homewreckerIds[]  = { 153, 466 };
    int neonIds[]  = { 813, 834 };
    int flareGunIds[]  = { 39, 1081 };

    SetWeaponDefs("Flamethrower", flamethrowerIds, sizeof(flamethrowerIds), TFClass_Pyro);
    SetWeaponDefs("Backburner", backburnerIds, sizeof(backburnerIds), TFClass_Pyro);
    SetWeaponDef("Phlogistinator", 594, TFClass_Pyro);
    SetWeaponDef("Degreaser", 215, TFClass_Pyro);
    SetWeaponDef("Dragon's Fury", 1178, TFClass_Pyro);

    SetWeaponDefs("Flare Gun", flareGunIds, sizeof(flareGunIds), TFClass_Pyro);
    SetWeaponDef("Detonator", 351, TFClass_Pyro);
    SetWeaponDef("Thermal Thruster", 1179, TFClass_Pyro);
    SetWeaponDef("Gas Passer", 1180, TFClass_Pyro);
    SetWeaponDef("Manmelter", 595, TFClass_Pyro);

    SetWeaponDefs("Axtinguisher", axtinguisherIds, sizeof(axtinguisherIds), TFClass_Pyro);
    SetWeaponDef("Powerjack", 214, TFClass_Pyro);

    // Demoman
    int grenadelauncherIds[] = { 19, 206, 1007, 15077, 15079, 15091, 15092, 15116, 15117, 15142, 15158 };
    int bootsIds[] = { 608, 405 };
    int chargintargeIds[] = { 131, 1144 };
    int stickylauncherIds[] = { 20, 207, 661, 797, 806, 886, 895, 904, 913, 962, 971, 15009, 15012, 15024, 15038, 15045, 15048, 15082, 15083, 15084, 15113, 15137, 15138, 15155 };
    int bottleIds[] = { 1, 191, 264, 423, 474, 609, 880, 939, 954, 1013, 1071, 1123, 1127, 30758 };
    int eyelanderIds[] = { 132, 266, 482, 1082 };

    SetWeaponDefs("Grenade Launcher", grenadelauncherIds, sizeof(grenadelauncherIds), TFClass_DemoMan);
    SetWeaponDef("Iron Bomber", 1151, TFClass_DemoMan);
    SetWeaponDef("Loch-n-Load", 308, TFClass_DemoMan);
    SetWeaponDef("Loose Cannon", 996, TFClass_DemoMan);
    SetWeaponDef("B.A.S.E. Jumper", 1101, TFClass_DemoMan);
    SetWeaponDefs("Boots", bootsIds, sizeof(bootsIds), TFClass_DemoMan);

    SetWeaponDefs("Stickybomb Launcher", stickylauncherIds, sizeof(stickylauncherIds), TFClass_DemoMan);
    SetWeaponDef("Scottish Resistance", 130, TFClass_DemoMan);
    SetWeaponDef("Quickiebomb Launcher", 1150, TFClass_DemoMan);
    SetWeaponDefs("Chargin' Targe", chargintargeIds, sizeof(chargintargeIds), TFClass_DemoMan);
    SetWeaponDef("Splendid Screen", 406, TFClass_DemoMan);

    SetWeaponDefs("Bottle", bottleIds, sizeof(bottleIds), TFClass_DemoMan);
    SetWeaponDefs("Eyelander", eyelanderIds, sizeof(eyelanderIds), TFClass_DemoMan);
    SetWeaponDef("Scotsman's Skullcutter", 172, TFClass_DemoMan);
    SetWeaponDef("Claidheamh Mor", 327, TFClass_DemoMan);
    SetWeaponDef("Tide Turner", 1099, TFClass_DemoMan);
    SetWeaponDef("Ullapool Caber", 307, TFClass_DemoMan);
    SetWeaponDef("Sticky Jumper", 265, TFClass_DemoMan);

    // Heavy
    int minigunIds[] = { 15, 202, 298, 654, 793, 802, 882, 891, 900, 909, 958, 967, 1206, 15004, 15020, 15026, 15031, 15040, 15055, 15086, 15087, 15088, 15098, 15099, 15123, 15124, 15125, 15147 };
    int huolongheaterIds[] = { 811, 832 };
    int sandvichIds[] = { 42, 863, 1002 };
    int chocolatebarIds[] = { 159, 433 };
    int fistsIds[] = { 5, 195, 264, 423, 474, 587, 880, 939, 954, 1013, 1071, 1123, 1127, 30758 };
    int gruIds[] = { 239, 1084, 1100 };

    SetWeaponDefs("Minigun", minigunIds, sizeof(minigunIds), TFClass_Heavy);
    SetWeaponDef("Natascha", 41, TFClass_Heavy);
    SetWeaponDef("Tomislav", 424, TFClass_Heavy);
    SetWeaponDefs("Huo-Long Heater", huolongheaterIds, sizeof(huolongheaterIds), TFClass_Heavy);
    SetWeaponDef("Brass Beast", 312, TFClass_Heavy);

    SetWeaponDef("Family Business", 425, TFClass_Heavy);
    SetWeaponDefs("Sandvich", sandvichIds, sizeof(sandvichIds), TFClass_Heavy);
    SetWeaponDefs("Dalokohs Bar", chocolatebarIds, sizeof(chocolatebarIds), TFClass_Heavy);
    SetWeaponDef("Buffalo Steak Sandvich", 311, TFClass_Heavy);
    SetWeaponDef("Second Banana", 1190, TFClass_Heavy);

    SetWeaponDefs("Fists", fistsIds, sizeof(fistsIds), TFClass_Heavy);
    SetWeaponDefs("Gloves of Running Urgently", gruIds, sizeof(gruIds), TFClass_Heavy);
    SetWeaponDef("Killing Gloves of Boxing", 43, TFClass_Heavy);
    SetWeaponDef("Eviction Notice", 426, TFClass_Heavy);
    SetWeaponDef("Fists of Steel", 331, TFClass_Heavy);
    SetWeaponDef("Warrior's Spirit", 310, TFClass_Heavy);
    SetWeaponDef("Holiday Punch", 656, TFClass_Heavy);

    // Engineer
    int justiceIds[] = { 141, 1004 };
    int wranglerIds[] = { 140, 1086, 30668 };
    int wrenchIds[] = { 7, 197, 169, 423, 662, 795, 804, 884, 893, 902, 911, 960, 969, 1071, 1123, 15073, 15074, 15075, 15114, 15139, 15140, 15156, 30758 };
    int pdaIds[] = { 25, 737 };

    SetWeaponDef("Rescue Ranger", 997, TFClass_Engineer);
    SetWeaponDef("Pomson 6000", 588, TFClass_Engineer);
    SetWeaponDef("Widowmaker", 527, TFClass_Engineer);
    SetWeaponDefs("Frontier Justice", justiceIds, sizeof(justiceIds), TFClass_Engineer);

    SetWeaponDefs("Pistol", pistolIds, sizeof(pistolIds), TFClass_Engineer);
    SetWeaponDefs("Wrangler", wranglerIds, sizeof(wranglerIds), TFClass_Engineer);
    SetWeaponDef("Short Circuit", 528, TFClass_Engineer);

    SetWeaponDef("Jag", 329, TFClass_Engineer);
    SetWeaponDef("Eureka Effect", 589, TFClass_Engineer);
    SetWeaponDef("Southern Hospitality", 155, TFClass_Engineer);
    SetWeaponDef("Gunslinger", 142, TFClass_Engineer);

    // Medic
    int syringegunIds[] = { 17, 204 };
    int crossbowIds[] = { 305, 1079 };
    int medigunIds[] = { 29, 211, 663, 796, 805, 885, 894, 903, 912, 961, 970, 158008, 15010, 15025, 15039, 15050, 15078, 15097, 15121, 15122, 15123, 15145, 15146 };
    int bonesawIds[] = { 8, 198, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 1143, 30758 };
    int ubersawIds[] = { 37, 1003 };

    SetWeaponDefs("Syringe Gun", syringegunIds, sizeof(syringegunIds), TFClass_Medic);
    SetWeaponDef("Blutsauger", 36, TFClass_Medic);
    SetWeaponDef("Overdose", 412, TFClass_Medic);
    SetWeaponDefs("Crusader's Crossbow", crossbowIds, sizeof(crossbowIds), TFClass_Medic);

    SetWeaponDefs("Medigun", medigunIds, sizeof(medigunIds), TFClass_Medic);
    SetWeaponDef("Kritzkrieg", 35, TFClass_Medic);
    SetWeaponDef("Quickfix", 411, TFClass_Medic);
    SetWeaponDef("Vaccinator", 998, TFClass_Medic);

    SetWeaponDefs("Bonesaw", bonesawIds, sizeof(bonesawIds), TFClass_Medic);
    SetWeaponDefs("Ubersaw", ubersawIds, sizeof(ubersawIds), TFClass_Medic);
    SetWeaponDef("Vita-Saw", 173, TFClass_Medic);
    SetWeaponDef("Amputator", 304, TFClass_Medic);
    SetWeaponDef("Solemn Vow", 413, TFClass_Medic);

    // Sniper
    int sniperrifleIds[] = { 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154 };
    int machinaIds[] = { 526, 30665 };
    int huntsmanIds[] = { 56, 1005, 1092 };
    int smgIds[] = { 16, 203, 1105, 1149, 15001, 15022, 15032, 15037, 15058, 15076, 15110, 15134, 15153 };
    int jarateIds[] = { 58, 1083 };
    int kukriIds[] = { 3, 193, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 30758 };

    SetWeaponDefs("Sniper Rifle", sniperrifleIds, sizeof(sniperrifleIds), TFClass_Sniper);
    SetWeaponDefs("Machina", machinaIds, sizeof(machinaIds), TFClass_Sniper);
    SetWeaponDef("Hitman's Heatmaker", 752, TFClass_Sniper);
    SetWeaponDef("The Classic", 1098, TFClass_Sniper);
    SetWeaponDef("Sydney Sleeper", 230, TFClass_Sniper);
    SetWeaponDefs("Huntsman", huntsmanIds, sizeof(huntsmanIds), TFClass_Sniper);

    SetWeaponDefs("SMG", smgIds, sizeof(smgIds), TFClass_Sniper);
    SetWeaponDef("Cleaner's Carbine", 751, TFClass_Sniper);
    SetWeaponDef("Razorback", 57, TFClass_Sniper);
    SetWeaponDef("Darwin's Danger Shield", 231, TFClass_Sniper);
    SetWeaponDef("Cozy Camper", 642, TFClass_Sniper);

    SetWeaponDefs("Kukri", kukriIds, sizeof(kukriIds), TFClass_Sniper);
    SetWeaponDef("Tribalman's Shiv", 171, TFClass_Sniper);
    SetWeaponDef("Shahanshah", 401, TFClass_Sniper);
    SetWeaponDef("Bushwacka", 232, TFClass_Sniper);

    // Spy
    int sapperIds[] = { 735, 736, 933, 1080, 1102 };
    int redtapeIds[] = { 810, 831 };
    int knifeIds[] = { 4, 194, 423, 638, 665, 727, 794, 803, 883, 892, 901, 910, 959, 968, 1071, 15062, 15094, 15095, 15096, 15118, 15119, 15143, 15144, 30758 };
    int yerIds[] = { 225, 574 };
    int inviswatchIds[] = { 30, 212, 297, 947, 1205 };

    SetWeaponDef("Revolver", 24, TFClass_Spy);
    SetWeaponDef("Ambassador", 61, TFClass_Spy);
    SetWeaponDef("Diamondback", 525, TFClass_Spy);
    SetWeaponDef("Enforcer", 460, TFClass_Spy);

    SetWeaponDef("Cloak and Dagger", 60, TFClass_Spy);

    SetWeaponDef("Big Earner", 461, TFClass_Spy);
    SetWeaponDefs("Your Eternal Reward", yerIds, sizeof(yerIds), TFClass_Spy);

    // Multi-class - Shotgun's defindex genuinely differs per class in the schema
    int shotgunIds[] = { 9, 10, 11, 12, 199, 1141, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152 };
    SetWeaponDefs("Shotgun", shotgunIds, sizeof(shotgunIds), TFClass_Soldier);
    SetWeaponDefs("Shotgun", shotgunIds, sizeof(shotgunIds), TFClass_Pyro);
    SetWeaponDefs("Shotgun", shotgunIds, sizeof(shotgunIds), TFClass_Heavy);
    SetWeaponDefs("Shotgun", shotgunIds, sizeof(shotgunIds), TFClass_Engineer);

    // Reserve Shooter and Panic Attack share one defindex across every class that carries them
    SetWeaponDef("Reserve Shooter", 415);
    SetWeaponDef("Panic Attack", 1153);
}
