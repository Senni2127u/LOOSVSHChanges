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
    remainingTime = 0;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER
    }

    function OnFrameTickAlive()
    {
        // Delfite: It ain't much, but it works.
        if (remainingTime > 0)
            remainingTime -= 1
        else if (remainingTime < 0)
            remainingTime = 0;

        ClientPrint(player, 4, "Market Garden cooldown: " + remainingTime)
    }

    function OnDamageDealt(victim, params)
    {
        if (player.InCond(TF_COND_BLASTJUMPING) && WeaponIs(params.weapon, "market_gardener"))
        {
            if (remainingTime > 0 && market_garden_counter <= 3)
                market_garden_counter += 1;
            if (market_garden_counter <= 1)
            {
                params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5;
                RefreshGardenTimer();
                EmitSoundOn("vsh_sfx.gardened", player);
                EmitPlayerVODelayed(player, "gardened", 0.3);
            }
            if (market_garden_counter == 2)
            {
                params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5 * 0.75;
                RefreshGardenTimer();
                EmitSoundOn("vsh_sfx.gardened", player);
                EmitPlayerVODelayed(player, "gardened", 0.3);
            }
            if (market_garden_counter >= 3)
            {
                params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5 * 0.50;
                RefreshGardenTimer();
                EmitSoundOn("vsh_sfx.gardened", player);
                player.AcceptInput("SpeakResponseConcept", "TLK_STALEMATE", null, null)
            }
            printl(market_garden_counter)
        }
    }

    function RefreshGardenTimer()
    {
        remainingTime = clampCeiling(462, remainingTime + 132)
    }
});