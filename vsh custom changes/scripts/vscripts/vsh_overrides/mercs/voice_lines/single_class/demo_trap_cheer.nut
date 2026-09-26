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

PrecacheArbitrarySound("demo.trap_cheer")
PrecacheArbitrarySound("vsh_sfx.gardened")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    playInterval = 0.5;
    damageDoneRecently = 0;
    isCrit = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnTickAlive(tickDelta)
    {
        damageDoneRecently = clampFloor(0, damageDoneRecently / 2.0);
    }

    function OnDamageDealt(victim, params)
    {
        isCrit = params.damage_type & DMG_ACID
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (!IsBoss(victim) || Time() - lastPlay < playInterval)
            return;
        damageDoneRecently += params.damageamount;
        if (damageDoneRecently > 500)
        {
            lastPlay = Time();
            EmitPlayerVO(player, "trap_cheer");
            if (isCrit)
                EmitSoundOn("vsh_sfx.gardened", player);
        }
    }
});