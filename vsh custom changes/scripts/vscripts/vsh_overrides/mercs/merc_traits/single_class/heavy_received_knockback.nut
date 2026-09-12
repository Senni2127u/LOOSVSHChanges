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

// Delfite: Code migrated to `__player_traits.nut`

// characterTraitsClasses.push(class extends CharacterTrait
// {
//     launch = false;

//     function CanApply()
//     {
//         return player.GetPlayerClass() == TF_CLASS_HEAVY;
//     }

//     function OnDamageTaken(attacker, params)
//     {
//         launch = IsValidBoss(attacker);
//         if (launch)
//             params.damage_type = params.damage_type | DMG_PREVENT_PHYSICS_FORCE;
//     }

//     function OnDamageTakenPost(attacker, params)
//     {
//         local weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY)
//         local active_weapon = player.GetActiveWeapon()
//         if (!launch)
//             return;

//         if (player.IsInvulnerable() && GetPropInt(weapon_primary, "m_iWeaponState") > 0 && active_weapon == weapon_primary)
//         {
//             local deltaVector = player.GetOrigin() - attacker.GetOrigin();
//             deltaVector.z = 0;
//             deltaVector.Norm();
//             player.Yeet(deltaVector * 300 + Vector(0, 0, 250));
//         }
//         else
//         {
//             local deltaVector = player.GetOrigin() - attacker.GetOrigin();
//             deltaVector.z = 0;
//             deltaVector.Norm();
//             player.Yeet(deltaVector * 600 + Vector(0, 0, 450));
//         }
//     }
// });