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
    weapon = null;

    function CanApply()
    {
        return player.GetPlayerClass() != TF_CLASS_SPY;
    }

    function OnApply()
    {
        weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
        if (!weapon)
            return;

        weapon.AddAttribute("single wep deploy time decreased", 0.75, -1);

        //Instead of only giving the mercs a melee range buff when they're near Hale, we can just give it to them globally so wallclimbing is a little easier.
        //Strangely, the melee range multiplier of an Engineer's wrench doesn't seem to change the distance at which he can hit his own buildings.
        //No clue why, but sure TF2, we can work with that. -Delfite
        if (!WeaponIs(weapon, "disciplinary_action") && !WeaponIs(weapon, "any_sword"))
            weapon.AddAttribute("melee range multiplier", 1.6, -1);

    }


    function OnFrameTickAlive()
    {
        local melee = player.GetActiveWeapon();
        if (melee != weapon)
            //printl(melee + " | " + weapon)
            return;

        if (!WeaponIs(melee, "market_gardener") && !WeaponIs(melee, "holiday_punch"))
            player.AddCondEx(TF_COND_CRITBOOSTED_ON_KILL, 0.13, null);
    }


    function OnDamageDealt(victim, params)
    {
        if (IsBoss(victim)
            && (params.damage_type & 128)
            && player.InCond(TF_COND_CRITBOOSTED_ON_KILL))
        {
            params.damage *= 1.2; //Hale has Crit Resistance. Restoring melee damage back.

            if (!victim.InCond(TF_COND_TAUNTING))
            {
                local deltaVector = victim.GetOrigin() - player.GetOrigin();
                deltaVector.z = 0;
                if (deltaVector.Norm() < 180)
                {
                    local force = !WeaponIs(params.weapon, "any_sword") ? 300 : 100;
                    victim.Yeet(deltaVector * force + Vector(0, 0, force));
                    //printl("A")
                }
            }
        }
    }
});
