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
//  Delfite - Programming.
//=========================================================================

characterTraitsClasses.push(class extends CharacterTrait
{
    // weapon_melee = null;

    function CanApply()
    {
        return player.GetPlayerClass() != TF_CLASS_SPY;
    }

    function OnApply()
    {
        // weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        if (!weapon_melee)
            return;

        weapon_melee.AddAttribute("single wep deploy time decreased", 0.75, -1);

        //Instead of only giving the mercs a melee range buff when they're near Hale, we can just give it to them globally so wallclimbing is a little easier.
        //Strangely, the melee range multiplier of an Engineer's wrench doesn't seem to change the distance at which he can hit his own buildings.
        //No clue why, but sure TF2, we can work with that. -Delfite
        if (!WeaponIs(weapon_melee, "disciplinary_action") && !WeaponIs(weapon_melee, "any_sword"))
            weapon_melee.AddAttribute("melee range multiplier", 1.6, -1);

    }


    function OnFrameTickAlive()
    {
        local active_weapon = player.GetActiveWeapon();
        if (active_weapon != weapon_melee)
            //printl(active_weapon + " | " + weapon)
            return;

        if (!WeaponIs(active_weapon, "market_gardener") && !WeaponIs(active_weapon, "holiday_punch") && !WeaponIs(active_weapon, "bushwacka"))
            player.AddCondEx(TF_COND_CRITBOOSTED_ON_KILL, 0.13, null);
    }


    function OnDamageDealt(victim, params)
    {
        if (IsBoss(victim) && (params.damage_type & 128))
        {
            if (player.IsCritBoosted())
                params.damage *= 1.2; //Hale has Crit Resistance. Restoring melee damage back.

            if (!victim.InCond(TF_COND_TAUNTING))
            {
                local deltaVector = victim.GetOrigin() - player.GetOrigin();
                deltaVector.z = 0;
                if (deltaVector.Norm() < 180)
                {
                    local force = 0;
                    if (WeaponIs(params.weapon, "any_sword"))
                        force = 100
                    else if (WeaponIs(params.weapon, "tideturner"))
                        force = 100
                    else if (WeaponIs(params.weapon, "eviction_notice"))
                        force = 130
                    else
                        force = 300
                    // local force = !WeaponIs(params.weapon, "any_sword")
                    //     && !WeaponIs(params.weapon, "tideturner")
                    //     && !WeaponIs(params.weapon, "eviction_notice") ? 300 : 100;
                    victim.Yeet(deltaVector * force + Vector(0, 0, force));
                    //printl("A")
                }
            }
        }
    }
});