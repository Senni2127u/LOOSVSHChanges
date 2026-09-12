//"This is a mousekatool thing that will help us later."

::CTFPlayer.GetPlayerName <- function ()
{
    return GetPropString(this, "m_szNetname");
}
::CTFBot.GetPlayerName <- CTFPlayer.GetPlayerName;

::CTFPlayer.GetPlayerSteamID <- function ()
{
    return GetPropString(this, "m_szNetworkIDString");
}
::CTFBot.GetPlayerSteamID <- CTFPlayer.GetPlayerSteamID;

// Delfite: Alternative version of GetPlayerName. Useful in scenarios where handles are less convenient.
::GetPlayerNameFromParam <- function(player)
{
    return GetPropString(player, "m_szNetname");
}

// Delfite: Alternative version of GetPlayerSteamID. Useful in scenarios where handles are less convenient.
::GetPlayerSteamIDFromParam <- function(player)
{
    return GetPropString(player, "m_szNetworkIDString");
}

// ::CTFWeaponBase.GetSlot <- function ()
// {
//     return
// }

local weapon_primary = null;
local weapon_secondary = null;
local weapon_melee = null;
local steamid = null;
local wearable = null;

local validCosmeticFound = false;

const SENNI = "[U:1:381254366]";
const LIZARDOFOZ = "[U:1:61845546]";
const LANKO = "[U:1:1144504997]";
const DELFITE = "[U:1:346103890]";
local playerParticles = {};

AddListener("death", 0, function(attacker, victim, params)
{
    local idx = victim.entindex();

    if (idx in playerParticles)
    {
        if (playerParticles[idx] && playerParticles[idx].IsValid())
            playerParticles[idx].Destroy();

        delete playerParticles[idx];
    }
});

AddListener("spawn", 0, function(player, params)
{
    weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
    weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
    weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
    steamid = NetProps.GetPropString(player, "m_szNetworkIDString");
    validCosmeticFound = false;
    GiveTargetParticleEffects(player);
    AddAttributes(player);
    //printl("a target was found, proceeding.") //Debug
});

function CommunitySparkleEffect(player, particleName)
{
    local particle = SpawnEntityFromTable("info_particle_system",
    {
        origin = player.GetOrigin(),
        effect_name = "community_sparkle",
        start_active = true
    });

    particle.AcceptInput("SetParent", "!activator", player, null);
    particle.AcceptInput("SetParentAttachment", "head", null, null);
    particle.AcceptInput("Start", "", null, null);

    playerParticles[player.entindex()] <- particle;

    return particle;
}

function BurningFlamesEffect(player, particleName)
{
    local particle = SpawnEntityFromTable("info_particle_system",
    {
        origin = player.GetOrigin(),
        effect_name = "burningplayer_flyingbits",
        start_active = true
    });

    particle.AcceptInput("SetParent", "!activator", player, null);
    particle.AcceptInput("SetParentAttachment", "head", null, null);
    particle.AcceptInput("Start", "", null, null);
    RunWithDelay2(this, 0.5, function ()
    {
        // switch (player.GetPlayerClass())
        // {
        //     case TF_CLASS_SCOUT:
        //         particle.SetAbsOrigin(player.EyePosition() + Vector(0, 0, 5))
        //             break;

        //     case TF_CLASS_SOLDIER:
        //         particle.SetAbsOrigin(player.EyePosition() + Vector(0, 0, 5))
        //             break;

        //     case TF_CLASS_PYRO:
        //         particle.SetAbsOrigin(player.EyePosition() + Vector(0, 0, 5))
        //             break;

        //     case TF_CLASS_DEMOMAN:
        //         particle.SetAbsOrigin(player.EyePosition() + Vector(0, 0, 5))
        //             break;

        //     case TF_CLASS_HEAVYWEAPONS:
        //         particle.SetAbsOrigin(player.EyePosition() + Vector(0, 0, 5))
        //             break;

        //     case TF_CLASS_ENGINEER:
        //         particle.SetAbsOrigin(player.EyePosition())
        //             break;

        //     // Delfite: Why is Medic's eye position so far away from his head?
        //     // It feels like the vector is getting misinterpreted somehow...
        //     case TF_CLASS_MEDIC:
        //         // particle.SetAbsOrigin(player.EyePosition() + Vector(150, 0, -60))
        //         particle.SetAbsOrigin(player.EyePosition() + Vector(0, 0, 0))
        //             break;

        //     case TF_CLASS_SNIPER:
        //         particle.SetAbsOrigin(player.EyePosition())
        //             break;

        //     case TF_CLASS_SPY:
        //         particle.SetAbsOrigin(player.EyePosition())
        //             break;

        //     default:
        //         break;
        // }

        playerParticles[player.entindex()] <- particle;

        // printl("Particle added.")
        return particle;
    })
}

function AddAttributes (player)
{
    switch (steamid)
    {
        case SENNI:
        case LANKO:
        case LIZARDOFOZ:
            weapon_primary.AddAttribute("building cost reduction", 0.50, -1);
            weapon_primary.AddAttribute("SET BONUS: dmg from sentry reduced", 0.01, -1);
            weapon_primary.AddAttribute("increase player capture value", 2, -1);
            weapon_primary.AddAttribute("SPELL: Halloween pumpkin explosions", 1, -1);
            weapon_primary.AddAttribute("SPELL: Halloween green flames", 1, -1);
            weapon_primary.AddAttribute("SPELL: Halloween death ghosts", 1, -1);
        break;

        case DELFITE:
            // if (weapon_primary.IsValid())
            // {
            //     weapon_primary.AddAttribute("selfmade description", 2, -1)
            //     printl("Selfmade 1: " + weapon_primary.GetAttribute("selfmade description", 1))
            // }
            // if (weapon_secondary.IsValid())
            // {
            //     weapon_secondary.AddAttribute("selfmade description", 2, -1)
            //     printl("Selfmade 2: " + weapon_secondary.GetAttribute("selfmade description", 1))
            // }
            // if (weapon_melee.IsValid())
            // {
            //     weapon_melee.AddAttribute("selfmade description", 2, -1)
            //     printl("Selfmade 3: " + weapon_melee.GetAttribute("selfmade description", 1))
            // }

            while (wearable = FindByClassname(wearable, "tf_wearable"))
            {
                if (wearable.GetOwner() == player)
                {
                    wearable.ValidateScriptScope()
                    local wearableScope = wearable.GetScriptScope();
                    if (!("CHECKED" in wearableScope))
                    {
                        wearableScope["CHECKED"] <- null;
                        switch (GetItemDefIndex(wearable))
                        {
                            // Delfite: Don't attach the particles to the Gunboats, Mantreads, etc.
                            // Not sure why the Medigun backpacks have the DefIndex they do, but hey, it works.
                            case 133:   // Gunboats
                            case 444:   // Mantreads
                            case 405:   // Ali-Babas Wee Booties
                            case 608:   // Bootlegger
                            case 65535:   // Medigun Backpack
                            case 231:   // Darwin's Danger Shield
                            case 642:   // Cozy Camper
                            break;

                            default:
                                wearable.AddAttribute("voice pitch scale", 0.955, -1)
                                printl(wearable.GetAttribute("voice pitch scale", 1.0))
                                wearable.AddAttribute("attach particle effect", 2, -1)
                                wearable.AddAttribute("killstreak tier", 1, -1)
                                wearable.AddAttribute("killstreak idleeffect", 3, -1)
                                SetPropInt(wearable, "m_AttributeManager.m_Item.m_iEntityQuality", 5)
                                // Delfite: I would've liked to set my cosmetic level higher, but the NetProp caps out at 127 before overflowing. Tragic.
                                SetPropInt(wearable, "m_AttributeManager.m_Item.m_iEntityLevel", 127)

                                // printl(GetPropEntityArray(player, "m_hMyWearables", 000))
                                // printl("ItemDefIndex: " + GetItemDefIndex(wearable))
                                // printl("Particle Effect: " + wearable.GetAttribute("attach particle effect", 0))
                                // printl("EntityLevel: " + GetPropInt(wearable, "m_AttributeManager.m_Item.m_iEntityLevel"))
                                validCosmeticFound = true;
                            break;
                        }
                        // Delfite: Sadly, GetSlot doesn't work on wearables :(
                        // printl("wearable slot: " + wearable.GetSlot())
                    }
                }

                if (validCosmeticFound)
                    break;
            }
        break;

        default:
        break;
    }
}

function GiveTargetParticleEffects(player)
{
    local steamid = player.GetPlayerSteamID()

    // Remove any old particle first.
    local idx = player.entindex();
    if (idx in playerParticles)
    {
        if (playerParticles[idx] && playerParticles[idx].IsValid())
            playerParticles[idx].Destroy();

        delete playerParticles[idx];
    }
    // printl("Particle removed.")

    if (validCosmeticFound)
        return;

    // Attach a new particle.
    switch (steamid)
    {
        case SENNI:
        case LANKO:
        case LIZARDOFOZ:
            playerParticles[idx] <- CommunitySparkleEffect(player, "community_sparkle");
                break;

        case DELFITE:
            if (player.GetTeam() == TF_TEAM_BOSS)
            {
                playerParticles[idx] <- BurningFlamesEffect(player, "burningplayer_flyingbits");
                // printl("Particle attached.")
            }
                break;

        default:
                break;
    }
}

// Delfite: This function allows you to add any attribute to Hale, be it player attributes or weapon attributes.
::OldHaleWeaponFunc <- ::TF_CUSTOM_WEAPONS_REGISTRY["Hale's Own Fists"].func;
function HaleWeaponFunc(weapon, player)
{
    local steamid = NetProps.GetPropString(player, "m_szNetworkIDString");

    OldHaleWeaponFunc(weapon, player);
    switch (steamid)
    {
        case SENNI:
        case LANKO:
        case LIZARDOFOZ:
            player.AddCustomAttribute("turn to gold", 1, -1)
                break;

        case DELFITE:
            player.AddCustomAttribute("ragdolls become ash", 1, -1)
                break;

        default:
                break;
    }
    // if (steamid == DELFITE)
    //     player.AddCustomAttribute("ragdolls become ash", 1, -1)
    // else if (steamid == LIZARDOFOZ || steamid == LANKO || steamid == SENNI)
    //     player.AddCustomAttribute("turn to gold", 1, -1)

    // Add custom weapon attributes here
    //weapon.AddAttribute("ragdolls plasma effect", 1, -1)
    //printl("Called Override");
}

::TF_CUSTOM_WEAPONS_REGISTRY["Hale's Own Fists"].func = HaleWeaponFunc;
