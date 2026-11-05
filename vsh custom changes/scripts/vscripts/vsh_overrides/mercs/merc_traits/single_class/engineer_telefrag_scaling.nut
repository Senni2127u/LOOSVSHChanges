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

PrecacheArbitrarySound("vsh_sfx.gardened")

characterTraitsClasses.push(class extends CharacterTrait
{
    function OnDamageDealt(victim, params)
    {
        if (params.damage_custom == TF_DMG_CUSTOM_TELEFRAG)
        {
            // Delfite: No need to specify attacker here, since the class is already scoped to the specific player.
            local telefragger_name = GetPlayerNameFromParams(player);
            local acting_teleporter = GetPropEntity(player, "m_hGroundEntity");
            local tele_owner = GetPropEntity(acting_teleporter, "m_hBuilder");
            local tele_owner_name = GetPlayerNameFromParams(tele_owner)

            // Delfite: If you own the teleporter, or nobody owns it, don't specify the owner in the broadcast.
            if (tele_owner == null || tele_owner == player)
                ClientPrint(null, 3, "\x0728FF46[VSH] \x07F2AC0A" + telefragger_name + "\x07F5E7DE landed a telefrag on Hale!");
            else
                ClientPrint(null, 3, "\x0728FF46[VSH] \x07F2AC0A" + telefragger_name + "\x07F5E7DE landed a telefrag on Hale with \x07F2AC0A" + tele_owner_name + "'s\x07F5E7DE teleporter!");

            params.damage_type = params.damage_type | DMG_ACID;
            params.damage = vsh_vscript.CalcStabDamage(victim) * 2 * 1.2;
            EmitSoundOn("vsh_sfx.gardened", player)
            HaleStunBreakout()
            RunWithDelay2(this, 1.5, function ()
            {
                if (!player.IsAlive())
                    return;

                switch (player.GetPlayerClass())
                {
                    case TF_CLASS_SCOUT:
                        EmitSoundOn("Scout.LaughLong0" + RandomInt(1, 2), player)
                    break;

                    case TF_CLASS_SOLDIER:
                        EmitSoundOn("Soldier.LaughLong0" + RandomInt(1, 3), player)
                    break;

                    case TF_CLASS_PYRO:
                        EmitSoundOn("Pyro.LaughLong01", player)
                    break;

                    case TF_CLASS_DEMOMAN:
                        EmitSoundOn("Demoman.LaughLong0" + RandomInt(1, 2), player)
                    break;

                    case TF_CLASS_HEAVY:
                        EmitSoundOn("Heavy.LaughLong0" + RandomInt(1, 2), player)
                    break;

                    case TF_CLASS_ENGINEER:
                        EmitSoundOn("Engineer.LaughLong0" + RandomInt(1, 2), player)
                    break;

                    case TF_CLASS_MEDIC:
                        EmitSoundOn("Medic.LaughLong0" + RandomInt(1, 2), player)
                    break;

                    case TF_CLASS_SNIPER:
                        EmitSoundOn("Sniper.LaughLong0" + RandomInt(1, 2), player)
                    break;

                    case TF_CLASS_SPY:
                        EmitSoundOn("Spy.LaughLong01", player)
                    break;

                    default:
                    break;
                }
            })
        }
    }
});