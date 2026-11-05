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

Include("__lizardlib/netprops.nut");
Include("__lizardlib/constants.nut");
Include("__lizardlib/listeners.nut");
Include("__lizardlib/player_util.nut");
Include("__lizardlib/weapons.nut");
Include("__lizardlib/character_trait.nut");
Include("__lizardlib/game_events.nut");

::CreateAoE <- function(center, radius, applyDamageFunc, applyPushFunc)
{
    foreach(target in GetAliveMercs())
    {
        local deltaVector = target.GetCenter() - center;
        local distance = deltaVector.Norm();
        if (distance > radius)
            continue;

        applyPushFunc(target, deltaVector, distance);
        applyDamageFunc(target, deltaVector, distance);
    }

    local target = null;
    while (target = FindByClassname(target, "obj_*"))
    {
        local deltaVector = target.GetCenter() - center;
        local distance = deltaVector.Norm();
        if (distance > radius)
            continue;

        applyDamageFunc(target, deltaVector, distance);
    }
}

::CreateAoEAABB <- function(center, min, max, applyDamageFunc, applyPushFunc)
{
    local min = center + min;
    local max = center + max;
    foreach(target in GetAliveMercs())
    {
        local targetCenter = target.GetCenter();
        if (targetCenter.x >= min.x
            && targetCenter.y >= min.y
            && targetCenter.z >= min.z
            && targetCenter.x <= max.x
            && targetCenter.y <= max.y
            && targetCenter.z <= max.z)
            {
                local deltaVector = targetCenter - center;
                local distance = deltaVector.Norm();
                applyPushFunc(target, deltaVector, distance);
                applyDamageFunc(target, deltaVector, distance);
            }
    }

    local target = null;
    while (target = FindByClassname(target, "obj_*"))
    {
        local targetCenter = target.GetCenter();
        if (targetCenter.x >= min.x
            && targetCenter.y >= min.y
            && targetCenter.z >= min.z
            && targetCenter.x <= max.x
            && targetCenter.y <= max.y
            && targetCenter.z <= max.z)
            {
                local deltaVector = targetCenter - center;
                local distance = deltaVector.Norm();
                applyDamageFunc(target, deltaVector, distance);
            }
    }
}

::clampCeiling <- function(ceiling, formula)
{
    if (formula > ceiling)
        return ceiling;
    return formula;
}

::clampFloor <- function(floor, formula)
{
    if (formula < floor)
        return floor;
    return formula;
}

::clamp <- function(formula, floor, ceiling)
{
    if (formula < floor)
        return floor;
    if (formula > ceiling)
        return ceiling;
    return formula;
}

// ::clampCeiling <- function(ceiling, math)
// {
//     local result = 0;
//     if (math > ceiling)
//         result = ceiling;
//     else
//         result = math;

//     return result;
// }

// ::clampFloor <- function(floor, math)
// {
//     local result = 0;
//     if (math < floor)
//         result = floor;
//     else
//         result = math;

//     return result;
// }

// ::clamp <- function(math, floor, ceiling)
// {
//     local result = 0;
//     if (math < floor)
//         result = floor;
//     else if (math > ceiling)
//         result = ceiling;
//     else
//         result = math;

//     return result;
// }

::SetPersistentVar <- function(name, value)
{
    local persistentVars = tf_gamerules.GetScriptScope();
    persistentVars[name] <- value;
}

::GetPersistentVar <- function(name, defValue = null)
{
    local persistentVars = tf_gamerules.GetScriptScope();
    return name in persistentVars ? persistentVars[name] : defValue;
}

::RunWithDelay <- function(func, activator, delay)
{
    EntFireByHandle(vsh_vscript_entity, "RunScriptCode", func, delay, activator, activator);
}

::RunWithDelay2 <- function (scope, delay, func, ...)
{
    local name = UniqueString();
    vsh_vscript[name] <- function()
    {
        try { func.acall([scope].extend(vargv)) }
        catch (e) { throw e; }
        delete vsh_vscript[name];
    }
    RunWithDelay(name + "()", null, delay);
}

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
::GetPlayerNameFromParams <- function(player)
{
    return GetPropString(player, "m_szNetname");
}

// Delfite: Alternative version of GetPlayerSteamID. Useful in scenarios where handles are less convenient.
::GetPlayerSteamIDFromParams <- function(player)
{
    return GetPropString(player, "m_szNetworkIDString");
}

// Delfite: Custom function used to get an entity's max overheal.
// If supplied with a multiplier (mult), it will calculate the new max overheal based on that multiplier.
// Useful in scenarios where an entity's max health can change at a moment's notice.

// TODO: Implement a better way of calculating the player's max overheal. The current method only accounts for one weapon
// in the player's loadout having an overheal penalty/bonus, when there could be multiple of them. A possible solution would
// be to build an array of active overheal mults on the player, then iterate through and add each entry to an equation that
// calculates the final multiplier. Another idea is to refactor all of the weapon scripts (again), but instead of having each
// weapon be defined in their respective scripts, we define them in __player_traits.nut and store them as per-player variables
// that can be retrieved from anywhere. Then when it comes time to calculate the final overheal mult, we just use GetAttribute
// on the weapons and punch their floats into the final calculation. Not that important to do right now though.
::CTFPlayer.GetMaxOverheal <- function (mult = 1.0)
{
    local overheal_quotient = this.GetMaxHealth() / 2
    local overheal_limit = overheal_quotient * mult + this.GetMaxHealth()
    return overheal_limit.tointeger();
}