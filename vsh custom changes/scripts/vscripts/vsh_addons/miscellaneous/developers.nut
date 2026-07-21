//"This is a mousekatool thing that will help us later."

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
    local steamid = NetProps.GetPropString(player, "m_szNetworkIDString");

    if (steamid == SENNI ||
        steamid == LIZARDOFOZ ||
        steamid == LANKO)
    {
        GiveTargetEffects(player);
        AddAttributes(player);
        //printl("a target was found, proceeding.") //Debug
    }
});

function AttachParticleToHead(player, particleName)
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

function GiveTargetEffects(player)
{
    // Remove any old particle first.
    local idx = player.entindex();
    if (idx in playerParticles)
    {
        if (playerParticles[idx] && playerParticles[idx].IsValid())
            playerParticles[idx].Destroy();

        delete playerParticles[idx];
    }

    // Attach a new particle.
    playerParticles[idx] <- AttachParticleToHead(player, "community_sparkle");
}

function AddAttributes (player) //I think this is what happens when you play god. - Senni
{
    local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
    if (weapon)
    {
        weapon.AddAttribute("building cost reduction", 0.50, -1);
        weapon.AddAttribute("SET BONUS: dmg from sentry reduced", 0.01, -1);
        weapon.AddAttribute("increase player capture value", 2, -1);
        weapon.AddAttribute("SPELL: Halloween pumpkin explosions", 1, -1);
        weapon.AddAttribute("SPELL: Halloween green flames", 1, -1);
        weapon.AddAttribute("SPELL: Halloween death ghosts", 1, -1);
    }
}

//This function allows you to add any attribute to Hale's fists. -Delfite
::OldHaleWeaponFunc <- ::TF_CUSTOM_WEAPONS_REGISTRY["Hale's Own Fists"].func;
function HaleWeaponFunc(weapon, player)
{
    local steamid = NetProps.GetPropString(player, "m_szNetworkIDString");

    OldHaleWeaponFunc(weapon, player);
    if (steamid == SENNI)
        weapon.AddAttribute("ragdolls plasma effect", 1, -1)
    else if (steamid == DELFITE)
        weapon.AddAttribute("ragdolls become ash", 1, -1)
    else if (steamid == LIZARDOFOZ || steamid == LANKO)
        weapon.AddAttribute("turn to gold", 1, -1)

    // Add custom weapon attributes here
    //weapon.AddAttribute("ragdolls plasma effect", 1, -1)
    //printl("Called Override");
}

::TF_CUSTOM_WEAPONS_REGISTRY["Hale's Own Fists"].func = HaleWeaponFunc;
