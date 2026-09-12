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

PrecacheClassVoiceLines("win")
// PrecacheScriptSound("medic_hat_taunts01")
// PrecacheScriptSound("medic_hat_taunts02")
// PrecacheScriptSound("medic_hat_taunts03")
// PrecacheScriptSound("medic_hat_taunts04")

PrecacheSound("vo/medic_hat_taunts01.mp3")
PrecacheSound("vo/medic_hat_taunts02.mp3")
PrecacheSound("vo/medic_hat_taunts03.mp3")
PrecacheSound("vo/medic_hat_taunts04.mp3")

::killer <- null;
::assister <- null;

::awful_hat_array <- [
    "vo/medic_hat_taunts01.mp3",
    "vo/medic_hat_taunts02.mp3",
    "vo/medic_hat_taunts03.mp3",
    "vo/medic_hat_taunts04.mp3"
]

characterTraitsClasses.push(class extends CharacterTrait
{
    function OnKill(victim, params)
    {
        if (IsValidBoss(victim))
        {
            ::killer <- player
            ::assister <- GetPlayerFromUserID(params.assister)
            // printl("Killer: " + killer + " | Assister: " + assister)
        }
    }
})

AddListener("round_end", 0, function (winnerTeam)
{
    if (winnerTeam != TF_TEAM_MERCS)
        return;

    foreach (player in GetAliveMercs())
    {
        // printl("Searching through players...")
        if (player == killer && killer.GetPlayerClass() == TF_CLASS_MEDIC)
        {
            // printl("Killer found.")
            // printl("The killer is a Medic.")
            RunWithDelay2(this, 1.5, function ()
            {
                // EmitSoundOn("medic_hat_taunts0" + RandomInt(1,4), killer)
                local awful_hat = awful_hat_array[RandomInt(0, 3)];
                EmitSoundEx(
                {
                    sound_name = awful_hat
                    volume = 1.0
                    entity = killer
                })
            })
        }
        else if (player == assister && assister.GetPlayerClass() == TF_CLASS_MEDIC)
        {
            // printl("Assister found.")
            // printl("The assister is a Medic.")
            RunWithDelay2(this, 1.5, function ()
            {
                // EmitSoundOn("medic_hat_taunts0" + RandomInt(1,4), assister)
                local awful_hat = awful_hat_array[RandomInt(0, 3)];
                EmitSoundEx(
                {
                    sound_name = awful_hat
                    volume = 1.0
                    entity = assister
                })
            })
        }
        else if (RandomInt(0, 4) == 0)
            EmitPlayerVODelayed(player, "win", RandomInt(5, 6));
    }
});