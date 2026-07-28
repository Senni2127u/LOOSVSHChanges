#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION  "2.0"
#define MAX_LINE_LEN    96
#define MAX_WEAPON_NAME 64

public Plugin myinfo =
{
    name        = "VSH Class Changes",
    author      = "Senni",
    description = "Displays custom class balance changes, filtered to the weapons the player currently has equipped.",
    version     = PLUGIN_VERSION
};

#define MAX_ITEM_DEFS   6

enum struct ChangeEntry
{
    TFClassType classType;
    char weaponName[MAX_WEAPON_NAME]; // empty = class-wide, always shown regardless of loadout
    int  itemDefs[MAX_ITEM_DEFS];     // any of these matching the player's equipped weapon shows this entry
    int  itemDefCount;                // 0 = unresolved/none set - falls back to "always show"
    ArrayList lines;                  // handle to an ArrayList of strings (ByteCountToCells(MAX_LINE_LEN) blocks)
}

ArrayList g_Entries;        // blocks of ChangeEntry
Handle    g_hAdvertTimer = null;

// ------------------------------------------------------------------
// Setup
// ------------------------------------------------------------------

public void OnPluginStart()
{
    RegConsoleCmd("sm_changes", Command_Changes);
    RegConsoleCmd("sm_classchanges", Command_Changes);
    RegAdminCmd("sm_weaponid", Command_WeaponId, ADMFLAG_GENERIC,
        "Prints the item definition index + schema name of your active weapon. Use this to check why a change entry isn't matching your loadout.");

    g_Entries = new ArrayList(sizeof(ChangeEntry));
    BuildChangeEntries();
    ApplyDefindexOverrides();
}

public void OnMapStart()
{
    if (g_hAdvertTimer != null)
    {
        delete g_hAdvertTimer;
    }
    g_hAdvertTimer = CreateTimer(60.0, Timer_Advert, _, TIMER_REPEAT);
}

public Action Timer_Advert(Handle timer)
{
    PrintToChatAll("\x04[VSH]\x01 Type \x03!changes\x01 to view the custom balance changes for your loadout.");
    return Plugin_Continue;
}

// ------------------------------------------------------------------
// Commands
// ------------------------------------------------------------------

public Action Command_Changes(int client, int args)
{
    if (client == 0 || !IsClientInGame(client))
        return Plugin_Handled;

    ShowClassChanges(client);
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
// which ShowClassChanges() treats as "always show" - so nothing is ever silently
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

        int def = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
        for (int k = 0; k < count; k++)
        {
            if (def == itemDefs[k])
                return true;
        }
    }
    return false;
}

void ShowClassChanges(int client)
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
    // (or entries whose name failed to resolve, shown as a safe fallback).
    for (int i = 0; i < total; i++)
    {
        ChangeEntry e;
        g_Entries.GetArray(i, e);

        if (e.classType != class || e.weaponName[0] == '\0')
            continue;

        bool show = (e.itemDefCount == 0) || ClientHasAnyWeaponDef(client, e.itemDefs, e.itemDefCount);
        if (!show)
            continue;

        char header[80];
        FormatEx(header, sizeof(header), "-- %s --", e.weaponName);
        panel.DrawText(header);

        DrawEntryLines(panel, e);
        printedAnything = true;
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

void AddEntry(TFClassType class, const char[] weaponName)
{
    ChangeEntry e;
    e.classType = class;
    strcopy(e.weaponName, MAX_WEAPON_NAME, weaponName);
    e.itemDefCount = 0; // 0 = unresolved, falls back to "always show" until SetWeaponDef(s) is called
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
    AddLine("Damage increased by 30%.");

    AddEntry(TFClass_Scout, "Shortstop");
    AddLine("Accuracy increased by 65%.");
    AddLine("Reload speed increased by 10%.");
    AddLine("Damage increased by 15%.");

    AddEntry(TFClass_Scout, "Back Scatter");
    AddLine("No accuracy penalty.");

    AddEntry(TFClass_Scout, "Pistol");
    AddLine("Reserve ammo quadrupled (36 -> 144).");
    AddLine("Perfectly accurate.");
    AddLine("Fire rate increased by 15%.");
    AddLine("Damage per bullet increased from 15 to 18 (+20%).");

    AddEntry(TFClass_Scout, "Winger");
    AddLine("Reserve ammo quadrupled (36 -> 144).");
    AddLine("Perfectly accurate.");

    AddEntry(TFClass_Scout, "Pretty Boy's Pocket Pistol");
    AddLine("Reserve ammo quadrupled (36 -> 144).");
    AddLine("Perfectly accurate.");
    AddLine("Healing per bullet increased from 3 to 5.");

    AddEntry(TFClass_Scout, "Bonk! Atomic Punch");
    AddLine("Recharge time reduced by 35%.");

    AddEntry(TFClass_Scout, "Crit-a-Cola");
    AddLine("Recharge time reduced by 35%.");
    AddLine("No Marked For Death.");

    AddEntry(TFClass_Scout, "Flying Guillotine");
    AddLine("Crits whenever it would normally mini-crit.");
    AddLine("Recharge time increased from 5 to 8 seconds (+60%).");

    // ===================== SOLDIER =====================
    AddEntry(TFClass_Soldier, "Rocket Launcher");
    AddLine("Projectile speed increased by 25%.");
    AddLine("Reload speed increased by 25%.");

    AddEntry(TFClass_Soldier, "Black Box");
    AddLine("Up to 50+ HP on hit.");

    AddEntry(TFClass_Soldier, "Beggar's Bazooka");
    AddLine("Projectile speed increased by 25%.");
    AddLine("Reload speed increased by 25%.");
    AddLine("Random deviation removed.");

    AddEntry(TFClass_Soldier, "Air Strike");
    AddLine("Projectile speed increased from +25% to +40%.");

    AddEntry(TFClass_Soldier, "Liberty Launcher");
    AddLine("Projectile speed increased from +40% to +65%.");
    AddLine("Blast jump damage resistance increased from 25% to 60%.");

    AddEntry(TFClass_Soldier, "Direct Hit");
    AddLine("Projectile speed increased from +80% to +100%.");

    AddEntry(TFClass_Soldier, "Righteous Bison");
    AddLine("Projectile speed increased by 100%.");
    AddLine("Fire rate increased by 20%.");
    AddLine("Reload speed increased by 20%.");

    AddEntry(TFClass_Soldier, "Buff Banner");
    AddLine("Charge builds passively over 60 seconds.");

    AddEntry(TFClass_Soldier, "Battalion's Backup");
    AddLine("Charge builds passively over 60 seconds.");
    AddLine("When Banner is Active, Resists Hale's abilities by 35%.");

    AddEntry(TFClass_Soldier, "Concheror");
    AddLine("Charge builds passively over 60 seconds.");

    AddEntry(TFClass_Soldier, "Shovel");
    AddLine("Damage increased from 195 to 253 (+30%).");

    AddEntry(TFClass_Soldier, "Escape Plan");
    AddLine("Movement speed increased by 40% while active.");
    AddLine("Damage reduced from 195 to 126 (-35%).");
    AddLine("Speed boost no longer scales with missing health.");
    AddLine("No longer applies Marked-For-Death.");

    AddEntry(TFClass_Soldier, "Gunboats");
    AddLine("Cancels fall damage.");

    // ===================== PYRO =====================
    AddEntry(TFClass_Pyro, "");
    AddLine("Base HP increased to 200.");
    AddLine("Airblast only works directly above or below Hale.");

    AddEntry(TFClass_Pyro, "Axtinguisher");
    AddLine("Restores half of missing HP on hit.");

    AddEntry(TFClass_Pyro, "Gas Passer");
    AddLine("Explodes on ignite.");
    AddLine("Now requires 800 damage to fully charge.");
    AddLine("Deploy/Holster speed reduced by 15%.");

    AddEntry(TFClass_Pyro, "Manmelter");
    AddLine("Stores crits from primary fire damage.");

    AddEntry(TFClass_Pyro, "Powerjack");
    AddLine("Movement speed while active increased from 15% to 30%.");
    AddLine("20% damage vulnerability removed.");
    AddLine("Damage reduced by 60%.");
    AddLine("Healing on hit (+25 HP) removed.");

    // ===================== DEMOMAN =====================
    AddEntry(TFClass_DemoMan, "Grenade Launcher");
    AddLine("Projectile speed increased by 25%.");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Mag size increased from 4 to 6.");
    AddLine("Reserve ammo increased from 16 to 24.");
    AddLine("Reload speed increased by 20%.");
    AddLine("Fire rate increased by 15%.");

    AddEntry(TFClass_DemoMan, "Iron Bomber");
    AddLine("Projectile speed increased by 25%.");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Fuse time decreased from -30% to -80%.");
    AddLine("Blast radius penalty removed, and radius increased by 35%.");
    AddLine("Blast jump damage reduced by 30% on wearer.");
    AddLine("Self-damage push force increased by 20%.");
    AddLine("Damage reduced from 150 to 120 (-20%).");
    AddLine("Reserve ammo increased from 16 to 24 (mag size unchanged).");

    AddEntry(TFClass_DemoMan, "Loch-n-Load");
    AddLine("Projectile speed increased by 25%.");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Damage increased from 150 to 180 (+20%).");
    AddLine("Fire rate increased by 20%.");
    AddLine("Mag size and reserve ammo unchanged.");

    AddEntry(TFClass_DemoMan, "Loose Cannon");
    AddLine("Projectile speed increased by 45%.");

    AddEntry(TFClass_DemoMan, "B.A.S.E. Jumper");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Blast jump resistance on wearer increased by 60%.");

    AddEntry(TFClass_DemoMan, "Stickybomb Launcher");
    AddLine("Projectile speed increased by 20%.");
    AddLine("Damage increased by 10%.");
    AddLine("Blast radius increased by 20%.");
    AddLine("Fire rate increased by 25%.");

    AddEntry(TFClass_DemoMan, "Scottish Resistance");
    AddLine("No changes.");

    AddEntry(TFClass_DemoMan, "Quickiebomb Launcher");
    AddLine("Projectile speed increased by 20%.");
    AddLine("Blast radius increased by 50%.");
    AddLine("Mag size penalty reduced from -50% to -25%.");
    AddLine("Max stickybombs out reduced from 8 to 6.");

    AddEntry(TFClass_DemoMan, "Chargin' Targe");
    AddLine("Blast resistance increased from +30% to +40%.");
    AddLine("Blast jump resistance increased by 60%.");

    AddEntry(TFClass_DemoMan, "Claidheamh Mor");
    AddLine("Gains charge on hit instead of on kill.");

    AddEntry(TFClass_DemoMan, "Tide Turner");
    AddLine("Gains charge on hit instead of on kill.");

    AddEntry(TFClass_DemoMan, "Ullapool Caber");
    AddLine("Blast jump damage resistance increased by 25%.");
    AddLine("Recharge time reduced to 12 seconds.");

    AddEntry(TFClass_DemoMan, "Sticky Jumper");
    AddLine("Limited to one sticky out at a time.");

    // ===================== HEAVY =====================
    AddEntry(TFClass_Heavy, "Minigun");
    AddLine("Can switch weapons while spinning down (unrev).");

    AddEntry(TFClass_Heavy, "Natascha");
    AddLine("Can switch weapons while spinning down (unrev).");

    AddEntry(TFClass_Heavy, "Tomislav");
    AddLine("Can switch weapons while spinning down (unrev).");

    AddEntry(TFClass_Heavy, "Huo-Long Heater");
    AddLine("Can switch weapons while spinning down (unrev).");
    AddLine("Spin-up costs no ammo.");

    AddEntry(TFClass_Heavy, "Brass Beast");
    AddLine("Can switch weapons while spinning down (unrev).");
    AddLine("Spin movement penalty reduced.");

    AddEntry(TFClass_Heavy, "Gloves of Running Urgently");
    AddLine("No longer drains health while active.");

    AddEntry(TFClass_Heavy, "Family Business");
    AddLine("Accuracy increased by 30%.");
    AddLine("15% damage penalty removed.");

    AddEntry(TFClass_Heavy, "Sandvich");
    AddLine("Healing from medkits increased by 50%.");

    AddEntry(TFClass_Heavy, "Dalokohs Bar");
    AddLine("Max health on wearer increased by 50.");
    AddLine("Now heals 133 HP per eat instead of 100.");
    AddLine("Recharge rate is doubled.");
    AddLine("No longer grants max health on eat.");

    AddEntry(TFClass_Heavy, "Buffalo Steak Sandvich");
    AddLine("Removed damage vulnerability.");

    AddEntry(TFClass_Heavy, "Eviction Notice");
    AddLine("Removed max health drain.");
    AddLine("Damage penalty reduced from -60% to -30%.");

    AddEntry(TFClass_Heavy, "Fists of Steel");
    AddLine("Removed melee damage vulnerability.");
    AddLine("Holster speed penalty reduced from +100% to +50%.");

    AddEntry(TFClass_Heavy, "Warrior's Spirit");
    AddLine("Removed damage vulnerability.");
    AddLine("Added +50% holster speed penalty.");

    // ===================== ENGINEER =====================
    AddEntry(TFClass_Engineer, "");
    AddLine("Teleporters work in both directions.");
    AddLine("Teleporter build speed increased by 300%.");

    AddEntry(TFClass_Engineer, "Rescue Ranger");
    AddLine("No longer applies Marked-For-Death.");

    AddEntry(TFClass_Engineer, "Pomson 6000");
    AddLine("Fire rate increased by 20%.");
    AddLine("Reload speed increased by 20%.");
    AddLine("Projectile speed roughly doubled.");

    AddEntry(TFClass_Engineer, "Pistol");
    AddLine("Fire rate increased by 15%.");
    AddLine("Damage increased from 15 to 18 (+20%).");
    AddLine("Perfectly accurate.");

    AddEntry(TFClass_Engineer, "Wrangler");
    AddLine("Deploy speed increased by 35%.");
    AddLine("No longer doubles sentry fire rate.");

    // ===================== MEDIC =====================
    AddEntry(TFClass_Medic, "");
    AddLine("Spawn with 100% UberCharge.");

    AddEntry(TFClass_Medic, "Syringe Gun");
    AddLine("Fire rate increased by 15%.");
    AddLine("Syringe velocity doubled.");
    AddLine("Damage per syringe increased from 10 to 15 (+50%).");

    AddEntry(TFClass_Medic, "Blutsauger");
    AddLine("Fire rate increased by 15%.");
    AddLine("Syringe velocity roughly doubled.");
    AddLine("Health on hit increased from 3 to 5.");

    AddEntry(TFClass_Medic, "Overdose");
    AddLine("Fire rate increased by 15%.");
    AddLine("Syringe velocity roughly doubled.");
    AddLine("Movement speed on wearer increased by 20%.");
    AddLine("Speed bonus no longer scales down with UberCharge.");

    // ===================== SNIPER =====================
    AddEntry(TFClass_Sniper, "Sniper Rifle");
    AddLine("Fires the Classic's tracer rounds.");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Movement speed on wearer increased by 30%.");
    AddLine("Rifle charge rate increased by 15%.");

    AddEntry(TFClass_Sniper, "Machina");
    AddLine("Fires the Classic's tracer rounds.");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Damage pierces Hale's crit resistance.");
    AddLine("Max-charge damage bonus increased from +15% to +25%.");
    AddLine("Movement speed on wearer increased by 10%.");
    AddLine("Can now be fired while unscoped.");

    AddEntry(TFClass_Sniper, "Hitman's Heatmaker");
    AddLine("Fires the Classic's tracer rounds.");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Movement speed on wearer increased by 15%.");
    AddLine("Crits whenever it would normally mini-crit.");
    AddLine("Rifle charge rate increased by 15%.");

    AddEntry(TFClass_Sniper, "The Classic");
    AddLine("Movement speed on wearer increased by 10%.");
    AddLine("Max health on wearer increased by 75 (125 -> 200).");
    AddLine("Rifle charge rate increased by 30%.");
    AddLine("Aiming movement speed increased by 2.7x.");
    AddLine("Can headshot even while not fully charged.");

    AddEntry(TFClass_Sniper, "Sydney Sleeper");
    AddLine("Max health on wearer increased by 25.");
    AddLine("Rifle charge rate increased from +25% to +35%.");

    AddEntry(TFClass_Sniper, "Huntsman");
    AddLine("Movement speed on wearer increased by 10%.");
    AddLine("Max health on wearer increased by 50 (125 -> 175).");
    AddLine("Projectile speed increased by 25%.");
    AddLine("Reload speed increased by 25%.");
    AddLine("Fire rate increased by 35%.");
    AddLine("Reserve ammo increased from 12 to 25 (+100%).");
    AddLine("Damage resistance on wearer increased by 30%.");

    AddEntry(TFClass_Sniper, "SMG");
    AddLine("Fire rate increased by 15%.");
    AddLine("Damage per bullet increased from 8 to 16 (+100%).");
    AddLine("Reserve ammo increased from 75 to 200.");
    AddLine("Perfectly accurate.");

    AddEntry(TFClass_Sniper, "Cleaner's Carbine");
    AddLine("25% fire rate penalty removed.");
    AddLine("Damage per bullet increased from 8 to 14 (+75%).");
    AddLine("Reserve ammo increased from 75 to 200.");
    AddLine("Perfectly accurate.");

    // ===================== SPY =====================
    AddEntry(TFClass_Spy, "");
    AddLine("Base movement speed increased by 20%.");
    AddLine("Cannot pick up ammo boxes while invisible.");

    AddEntry(TFClass_Spy, "Cloak and Dagger");
    AddLine("Mirrors the stock Invis Watch.");

    AddEntry(TFClass_Spy, "Revolver");
    AddLine("Perfectly accurate.");
    AddLine("Damage per bullet increased from 40 to 80 (+100%).");
    AddLine("Fire rate increased by 15%.");
    AddLine("Reload speed increased by 15%.");

    AddEntry(TFClass_Spy, "Ambassador");
    AddLine("Perfectly accurate.");
    AddLine("Crits no longer suffer from falloff.");
    AddLine("Headshot damage doubled.");
    AddLine("Reload speed increased by 15%.");
    AddLine("Damage penalty increased from 15% to 20%.");

    AddEntry(TFClass_Spy, "Diamondback");
    AddLine("Perfectly accurate.");
    AddLine("Removed 15% damage penalty.");

    AddEntry(TFClass_Spy, "Enforcer");
    AddLine("Perfectly accurate.");
    AddLine("Removed 20% fire rate penalty.");

    // ===================== MULTI-CLASS SHARED ITEMS =====================
    // "Shotgun" resolves to the same item defindex across the classes that carry it,
    // so one AddEntry per class using the same weapon name is enough.
    static const TFClassType shotgunClasses[] = { TFClass_Soldier, TFClass_Pyro, TFClass_Heavy, TFClass_Engineer };
    for (int i = 0; i < sizeof(shotgunClasses); i++)
    {
        AddEntry(shotgunClasses[i], "Shotgun");
        AddLine("Damage increased by 40%.");
        AddLine("Accuracy increased by 30%.");
        AddLine("Reload speed increased by 15%.");
    }

    AddEntry(TFClass_Soldier, "Reserve Shooter");
    AddLine("Accuracy increased by 30%.");

    AddEntry(TFClass_Pyro, "Reserve Shooter");
    AddLine("Accuracy increased by 30%.");

    static const TFClassType panicAttackClasses[] = { TFClass_Soldier, TFClass_Pyro, TFClass_Heavy, TFClass_Engineer };
    for (int i = 0; i < sizeof(panicAttackClasses); i++)
    {
        AddEntry(panicAttackClasses[i], "Panic Attack");
        AddLine("Accuracy increased by 40%.");
        AddLine("20% damage penalty removed.");
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
    int pistolIds[] = { 22, 23, 160, 294 }; //Pistols have two different IDs for both Engineer and Scout, just catch both.
    int bonkpunchIds[] = { 46, 1145 };
    int batIds[]  = { 0, 190, 221, 264, 474, 572, 660, 423, 880, 939, 954, 999, 1013, 1071, 1123, 1127, 30667, 30758 };
    int madmilkIds[] = { 222, 1121 };
    int cleaverIds[] = { 812, 833 };
    int bostonbasherIds[] = { 325, 452 };

    SetWeaponDefs("Scattergun", scattergunIds, sizeof(scattergunIds), TFClass_Scout);
    SetWeaponDef("Shortstop", 220, TFClass_Scout);
    SetWeaponDef("Back Scatter", 1103, TFClass_Scout);
    SetWeaponDefs("Pistol", pistolIds, sizeof(pistolIds), TFClass_Scout);
    SetWeaponDef("Winger", 449, TFClass_Scout);
    SetWeaponDef("Pretty Boy's Pocket Pistol", 773, TFClass_Scout);
    SetWeaponDefs("Bonk! Atomic Punch", bonkpunchIds, sizeof(bonkpunchIds), TFClass_Scout);
    SetWeaponDef("Crit-a-Cola", 163, TFClass_Scout);
    SetWeaponDefs("Flying Guillotine", cleaverIds, sizeof(cleaverIds), TFClass_Scout);

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
    SetWeaponDef("Righteous Bison", 442, TFClass_Soldier);
    SetWeaponDefs("Buff Banner", buffbannerIds, sizeof(buffbannerIds), TFClass_Soldier);
    SetWeaponDef("Battalion's Backup", 226, TFClass_Soldier);
    SetWeaponDef("Concheror", 354, TFClass_Soldier);
    SetWeaponDefs("Shovel", shovelIds, sizeof(shovelIds), TFClass_Soldier);
    SetWeaponDef("Escape Plan", 775, TFClass_Soldier);
    SetWeaponDef("Gunboats", 133, TFClass_Soldier);

    // Pyro
    int flamethrowerIds[]  = { 21, 208, 659, 741, 798, 807, 887, 896, 905, 914, 963, 972, 15005, 15017, 15030, 15034, 15049, 15054, 15066, 15067, 15068, 15089, 15090, 15115, 15141, 30474 };
    int backburnerIds[] = { 40, 1146 };
    int flaregunIds[]  = { 39, 1081 };
    int fireaxeIds[]  = { 2, 192, 264, 423, 474, 739, 880, 939, 954, 1013, 1071, 1123, 1127, 30758 };
    int axtinguisherIds[]  = { 38, 457, 1000 };
    int homewreckerIds[]  = { 153, 466 };
    int neonIds[]  = { 813, 834 };

    SetWeaponDefs("Axtinguisher", axtinguisherIds, sizeof(axtinguisherIds), TFClass_Pyro);
    SetWeaponDef("Gas Passer", 1180, TFClass_Pyro);
    SetWeaponDef("Manmelter", 595, TFClass_Pyro);
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
    SetWeaponDef("Stickybomb Launcher", 20, TFClass_DemoMan);
    SetWeaponDef("Scottish Resistance", 130, TFClass_DemoMan);
    SetWeaponDef("Quickiebomb Launcher", 1150, TFClass_DemoMan);
    SetWeaponDefs("Chargin' Targe", chargintargeIds, sizeof(chargintargeIds), TFClass_DemoMan);
    SetWeaponDef("Claidheamh Mor", 327, TFClass_DemoMan);
    SetWeaponDef("Tide Turner", 1099, TFClass_DemoMan);
    SetWeaponDef("Ullapool Caber", 307, TFClass_DemoMan);
    SetWeaponDef("Sticky Jumper", 265, TFClass_DemoMan);

    // Heavy
    int minigunIds[] = { 15, 202, 298, 654, 793, 802, 882, 891, 900, 909, 958, 967, 15004, 15020, 15026, 15031, 15040, 15055, 15086, 15087, 15088, 15098, 15099, 15123, 15124, 15125, 15147 };
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
    SetWeaponDefs("Gloves of Running Urgently", gruIds, sizeof(gruIds), TFClass_Heavy);
    SetWeaponDef("Family Business", 425, TFClass_Heavy);
    SetWeaponDefs("Sandvich", sandvichIds, sizeof(sandvichIds), TFClass_Heavy);
    SetWeaponDefs("Dalokohs Bar", chocolatebarIds, sizeof(chocolatebarIds), TFClass_Heavy);
    SetWeaponDef("Buffalo Steak Sandvich", 311, TFClass_Heavy);
    SetWeaponDef("Eviction Notice", 426, TFClass_Heavy);
    SetWeaponDef("Fists of Steel", 331, TFClass_Heavy);
    SetWeaponDef("Warrior's Spirit", 310, TFClass_Heavy);

    // Engineer
    int justiceIds[] = { 141, 1004 };
    int wranglerIds[] = { 140, 1086, 30668 };
    int wrenchIds[] = { 7, 197, 169, 423, 662, 795, 804, 884, 893, 902, 911, 960, 969, 1071, 1123, 15073, 15074, 15075, 15114, 15139, 15140, 15156, 30758 };
    int pdaIds[] = { 25, 737 };

    SetWeaponDef("Rescue Ranger", 997, TFClass_Engineer);
    SetWeaponDef("Pomson 6000", 588, TFClass_Engineer);
    SetWeaponDefs("Pistol", pistolIds, sizeof(pistolIds), TFClass_Engineer);
    SetWeaponDefs("Wrangler", wranglerIds, sizeof(wranglerIds), TFClass_Engineer);

    // Medic
    int syringegunIds[] = { 17, 204 };
    int crossbowIds[] = { 305, 1079 };
    int medigunIds[] = { 29, 211, 663, 796, 805, 885, 894, 903, 912, 961, 970, 158008, 15010, 15025, 15039, 15050, 15078, 15097, 15121, 15122, 15123, 15145, 15146 };
    int bonesawIds[] = { 8, 198, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 1143, 30758 };
    int ubersawIds[] = { 37, 1003 };

    SetWeaponDefs("Syringe Gun", syringegunIds, sizeof(syringegunIds), TFClass_Medic);
    SetWeaponDef("Blutsauger", 36, TFClass_Medic);
    SetWeaponDef("Overdose", 412, TFClass_Medic);

    // Sniper
    int sniperrifleIds[] = { 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154 };
    int machinaIds[] = { 526, 30665 };
    int huntsmanIds[] = { 56, 1101, 1092 };
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

    // Spy
    int sapperIds[] = { 735, 736, 933, 1080, 1102 };
    int redtapeIds[] = { 810, 831 };
    int knifeIds[] = { 4, 194, 423, 638, 665, 727, 794, 803, 883, 892, 901, 910, 959, 968, 1071, 15062, 15094, 15095, 15096, 15118, 15119, 15143, 15144, 30758 };
    int yerIds[] = { 225, 574 };
    int inviswatchIds[] = { 30, 212, 297, 947 };


    SetWeaponDef("Cloak and Dagger", 60, TFClass_Spy);
    SetWeaponDef("Revolver", 24, TFClass_Spy);
    SetWeaponDef("Ambassador", 61, TFClass_Spy);
    SetWeaponDef("Diamondback", 525, TFClass_Spy);
    SetWeaponDef("Enforcer", 460, TFClass_Spy);

    // Multi-class - Shotgun's defindex genuinely differs per class in the schema
    SetWeaponDef("Shotgun", 10, TFClass_Soldier);
    SetWeaponDef("Shotgun", 12, TFClass_Pyro);
    SetWeaponDef("Shotgun", 11, TFClass_Heavy);
    SetWeaponDef("Shotgun", 9, TFClass_Engineer);

    // Reserve Shooter and Panic Attack share one defindex across every class that carries them
    SetWeaponDef("Reserve Shooter", 415);
    SetWeaponDef("Panic Attack", 1153);
}
