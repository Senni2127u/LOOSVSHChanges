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

    function OnDamageDealt(victim, params)
    {
        if (params.damage_type & 128)
            SetPropFloat(player, "m_Shared.m_flChargeMeter", clampCeiling(100.0, GetPropFloat(player, "m_Shared.m_flChargeMeter") + 25.0))
    }
})

characterTraitsClasses.push(class extends CharacterTrait
{
    wearable = null;
    weapon_secondary = null;
    weapon_melee = null;

    function CanApply()
    {
        weapon_secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY)
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE)

        if (player.GetPlayerClass() != TF_CLASS_DEMOMAN)
            return false;
        while (wearable = FindByClassname(wearable, "tf_wearable"))
            if (wearable.GetOwner() == player && WeaponIs(wearable, "any_demo_boots"))
			{
				wearable.AddAttribute("move speed bonus shield required", 1.0, -1)
				// Remove the speed boost currently on the boots...
                wearable.AddAttribute("cancel falling damage", 1, -1)
                wearable.AddAttribute("rocket jump damage reduction", wearable.GetAttribute("rocket jump damage reduction", 1.0) - 0.6, -1)
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
				return true;
			}
        return false;
    }


    function OnDiscard()
    {
        if (wearable && wearable.IsValid())
        {
            wearable.RemoveAttribute("move speed bonus");
            wearable.RemoveAttribute("cancel falling damage");
            wearable.RemoveAttribute("move speed bonus shield required");
            wearable.RemoveAttribute("rocket jump damage reduction");
        }
    }
});
