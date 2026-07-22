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

PrecacheArbitrarySound("soldier.gardened")
PrecacheArbitrarySound("vsh_sfx.gardened");

characterTraitsClasses.push(class extends CharacterTrait
{
    market_garden_counter = 0;
    time_since_last_garden = 0;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnDamageDealt(victim, params)
    {
        if (player.InCond(TF_COND_BLASTJUMPING) && WeaponIs(params.weapon, "market_gardener"))
        {
            market_garden_counter + 1;
            if (market_garden_counter <= 2)
                params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5;
            if (market_garden_counter == 3)
                params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5 * 0.75;
            if (market_garden_counter == 4)
                params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5 * 0.50;

            Time();

            EmitSoundOn("vsh_sfx.gardened", player);
            EmitPlayerVODelayed(player, "gardened", 0.3);
        }
    }
});