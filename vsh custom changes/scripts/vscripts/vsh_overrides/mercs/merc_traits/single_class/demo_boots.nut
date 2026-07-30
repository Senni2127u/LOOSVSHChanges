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

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        if (player.GetPlayerClass() != TF_CLASS_DEMOMAN)
            return false;
        local wearable = null;
        while (wearable = FindByClassname(wearable, "tf_wearable"))
            if (wearable.GetOwner() == player && WeaponIs(wearable, "any_demo_boots"))
                return true;
        return false;
    }

    // Delfite: Instead of applying the "charge on hit" attribute to demo's current melee, we'll just add charge via NetProps.
	function OnDamageDealt(victim, params)
    {
        // printl("Damage dealt (Boots check).")
        if (params.damage_type & 128 && params.weapon == player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE))
        {
            SetPropFloat(player, "m_Shared.m_flChargeMeter", clampCeiling(100.0, GetPropFloat(player, "m_Shared.m_flChargeMeter") + 25.0))
            // printl("Supplied charge to the player's meter via boots.")
        }
    }
})

characterTraitsClasses.push(class extends CharacterTrait
{
    wearable = null;
    weapon_secondary = null;
    weapon_melee = null;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);

        RunWithDelay2(this, 0.1, function() // Delfite: Adding a delay here to apply the attributes, otherwise there's a chance they won't.
        {
            while (wearable = FindByClassname(wearable, "tf_wearable"))
                if (wearable.GetOwner() == player && WeaponIs(wearable, "any_demo_boots"))
                {
                    // printl("Boots found.")
                    wearable.AddAttribute("move speed bonus shield required", 1.0, -1)
                    // Remove the speed boost currently on the boots.
                    wearable.AddAttribute("cancel falling damage", 1, -1)
                    wearable.AddAttribute("rocket jump damage reduction", 0.4, -1)
                    // Apparently, the game finishes any math you give it before OnDiscard finishes running.
                    // This resulted in the old rocket jump damage reduction code subtracting from the attribute every time you changed loadouts.
                    // printl("Rocket jump damage reduction: " + wearable.GetAttribute("rocket jump damage reduction", 1.0))
                    // if (WeaponIs(weapon_secondary, "any_stickybomb_launcher") && !WeaponIs(weapon_secondary, "sticky_jumper"))
                    // {
                    //     // printl("Secondary is a stickybomb launcher.")
                    // }
                    if (WeaponIs(weapon_melee, "eyelander") && WeaponIs(weapon_secondary, "any_stickybomb_launcher"))
                    {
                        wearable.AddAttribute("move speed bonus", 1.10, -1)
                        // Delfite: Only give this speed bonus if you don't have an eyelander and stickybomb launcher equipped.
                        // Delfite: Failing to do this will result in demomen that are not only faster than a scout, but also highly resistant to their own bombs.
                    }
                    else
                    {
                        wearable.AddAttribute("move speed bonus", 1.15, -1)
                    }
                    player.Regenerate(true)
                }
        })
    }
});
