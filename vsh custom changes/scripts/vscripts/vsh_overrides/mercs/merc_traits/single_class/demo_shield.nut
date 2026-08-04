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
//  Bradasparky - Helped fix the charge-on-hit also applying when a shield bash happened.
//=========================================================================

PrecacheArbitrarySound("vsh_sfx.shield_break");
PrecacheArbitrarySound("demo.shield")
PrecacheArbitrarySound("demo.shield_lowhp")

characterTraitsClasses.push(class extends CharacterTrait
{
    destroyShield = false;
    shieldBroken = false;

    function CanApply()
    {
        if (player.GetPlayerClass() != TF_CLASS_DEMOMAN)
            return false;
        local wearable = null;
        while (wearable = FindByClassname(wearable, "tf_wearable_demo*"))
            if (wearable.GetOwner() == player)
            {
                wearable.EnableDraw();
                return true;
            }
        return false;
    }

    function OnDamageTaken(attacker, params)
    {
        destroyShield = false;
        if (shieldBroken || !IsValidBoss(attacker) || player.InCond(TF_COND_INVULNERABLE))
            return;

        if ((params.damage_type == 1 || params.damage_type == DMG_BLAST) && params.damage < player.GetHealth())
            return;

        //Note: Saxton Punch!'s collateral will NOT be resisted. Adding extra-extra resistance to make up for it.
        params.damage *= params.inflictor == custom_dmg_saxton_punch ? 0.2 : 0.5;
        destroyShield = true;
    }

    function OnDamageTakenPost(attacker, params)
    {
        if (!destroyShield)
            return;

        shieldBroken = true;
        player.AddCondEx(TF_COND_PREVENT_DEATH, 0, null);

        local wearable = null;
        while (wearable = FindByClassname(wearable, "tf_wearable_demo*"))
            if (wearable.GetOwner() == player)
            {
                wearable.DisableDraw();
                break;
            }

        local deltaVector = player.GetCenter() - attacker.GetCenter();
        deltaVector.z = 0;
        deltaVector.Norm();
        player.Yeet(deltaVector * 600 + Vector(0, 0, 450));

        EmitSoundOn("vsh_sfx.shield_break", player);
        EmitPlayerVODelayed(player, params.inflictor == custom_dmg_saxton_punch ? "shield_lowhp" : "shield", 1);
    }
});

characterTraitsClasses.push(class extends CharacterTrait
{
	wearableIsTideturner = false;
	weapon_secondary = null;
    wearable = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        RunWithDelay2(this, 0.1, function()
        {
            while (wearable = FindByClassname(wearable, "tf_wearable_demo*"))
                if (wearable.GetOwner() == player && WeaponIs(wearable, "any_shield"))
                {
                    // printl("Shield found.")
                    wearableIsTideturner = WeaponIs(wearable, "tideturner")
                    if (WeaponIs(wearable, "chargin_targe"))
                    {
                        wearable.AddAttribute("rocket jump damage reduction", 0.4, -1)
                        wearable.AddAttribute("dmg taken from blast reduced", 0.6, -1)
                    }
                }
        })
    }

    // Delfite: Instead of applying the "charge on hit" attribute to demo's current melee, we'll just add charge via NetProps.
	function OnDamageDealt(victim, params)
    {
        // printl("Damage dealt (Tideturner check).")
        if (params.damage_type & 128 && wearableIsTideturner && params.weapon == player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE))
        {
            SetPropFloat(player, "m_Shared.m_flChargeMeter", clampCeiling(100.0, GetPropFloat(player, "m_Shared.m_flChargeMeter") + 75.0))
            // printl("Supplied charge to the player's meter via the Tideturner.")
        }
    }
});