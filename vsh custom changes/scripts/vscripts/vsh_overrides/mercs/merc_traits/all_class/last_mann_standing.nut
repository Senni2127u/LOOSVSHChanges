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
    weapon_primary = null;
    weapon_secondary = null;
    weapon_melee = null;
    player_class = 0;

    mercsAlive = 0;

    chargeReleased = false;

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        player_class = player.GetPlayerClass();
    }

    function OnTickAlive(timeDelta)
    {
        mercsAlive = GetAliveMercCount();
        // Delfite: Only give mini-crits to non-stealthed players, otherwise Spy's cloak will be rendered useless during LMS.
        // I get the point of the glow outlines is to stop people from hiding, but Spy should be an exception considering what
        // his whole identity and style of gameplay is about, that being subterfuge and being sneaky. That, and he's already
        // unable to pick up ammo while he's cloaked, so there isn't really a point in doubling up on the nerfs in his case.
        if (mercsAlive <= 3 && !player.IsStealthed())
            player.AddCondEx(TF_COND_OFFENSEBUFF, 0.2, player);
        if (mercsAlive == 1)    //No, it's not "else if", because engie + sentry combo benefits from both crits and minicrits
            player.AddCondEx(TF_COND_CRITBOOSTED_BONUS_TIME, 0.2, player);
    }

    function OnFrameTickAlive()
    {
        if (LastMannStandingActive)
        {
            if (player_class == TF_CLASS_MEDIC)
            {
                chargeReleased = GetPropBool(weapon_secondary, "m_bChargeRelease")
                local ubercharge = GetPropFloat(weapon_secondary, "m_flChargeLevel")
                if (ubercharge < 1.0 && !chargeReleased)
                {
                    if (mercsAlive == 3)
                        // Delfite: Full charge in 60 seconds.
                        SetPropFloat(weapon_secondary, "m_flChargeLevel", ubercharge + 0.00025252525252525252525252525252525)
                    else if (mercsAlive == 2)
                        SetPropFloat(weapon_secondary, "m_flChargeLevel", ubercharge + 0.00033670033670033670033670033670034)
                    else
                        SetPropFloat(weapon_secondary, "m_flChargeLevel", ubercharge + 0.00050505050505050505050505050505051)
                }
            }
        }
    }
});