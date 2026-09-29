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

characterTraitsClasses.push(class extends CharacterTrait
{
    function OnTickAlive(timeDelta)
    {
        local mercsAlive = GetAliveMercCount();
        // Delfite: Only give mini-crits to non-stealthed players, otherwise Spy's cloak will be rendered useless during LMS.
        // I get the point of the glow outlines is to stop people from hiding, but Spy should be an exception considering what
        // his whole identity and style of gameplay is about, that being subterfuge and being sneaky.
        if (mercsAlive <= 3 && !player.IsStealthed())
            player.AddCondEx(TF_COND_OFFENSEBUFF, 0.2, player);
        if (mercsAlive == 1)    //No, it's not "else if", because engie + sentry combo benefits from both crits and minicrits
            player.AddCondEx(TF_COND_CRITBOOSTED_ON_KILL, 0.2, player);
    }
});