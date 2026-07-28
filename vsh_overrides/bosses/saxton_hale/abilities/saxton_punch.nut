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

PrecacheArbitrarySound("vsh_sfx.saxton_punch");
PrecacheArbitrarySound("saxton_hale.saxton_punch_ready")
PrecacheArbitrarySound("saxton_hale.saxton_punch")
PrecacheArbitrarySound("Weapon_Capper.SingleCrit")
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "vsh_megapunch_shockwave" })
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "vsh_mighty_slam" })
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "stomp_text" })

class SaxtonPunchTrait extends BossTrait
{
    meter = -30;
    perform = true;
    playedWarning = false;

    function OnApply()
    {
        if (!(player in hudAbilityInstances))
            hudAbilityInstances[player] <- [];
        hudAbilityInstances[player].push(this);
    }


    function CritPunchReady()
        {
            meter = 0;
            vsh_vscript.Hale_SetRedArm(boss, true);
            BossPlayViewModelAnim(boss, "vsh_megapunch_ready");
            boss.AddCond(TF_COND_CRITBOOSTED);
            EmitSoundOn("Weapon_Capper.SingleCrit", boss) //sfx warning when it's fully charged.
        }

    function CritPunchVoiceline()
        {
            PlayAnnouncerVO(boss, "saxton_punch_ready");
            RunWithDelay2(this, 10.0, function() //Some voicelines can be long, overcompensating here for that reason.
            {
                playedWarning = false;
            }
        )
        }

    function OnTickAlive(timeDelta)
    {
        if (meter < 0 && !IsRoundSetup())
        {
            meter += timeDelta;
            if (meter >= 0)
            {
                CritPunchReady()
            }

        if (meter >= -3 && !playedWarning)
            {
                playedWarning = true;
                CritPunchVoiceline();
            }
        }
    }
    function OnDamageDealt(victim, params)
    {
        perform = false;
        if (params.damage_custom == 9)
        {
            params.inflictor = custom_dmg_hale_taunt;
            params.inflictor.SetAbsOrigin(boss.GetOrigin());
            params.damage_stats = 0;
        }
        else if (!IsCollateralDamage(params.damage_type) && player != victim && meter == 0 && params.damage > 0 && !InSweepingCharge)
        {
            perform = true;
            params.inflictor = custom_dmg_saxton_punch;
            params.inflictor.SetAbsOrigin(boss.GetOrigin());
            params.damage_type = DMG_BLAST;

            local deltaVector = victim.GetCenter() - boss.GetCenter();
            local distance = deltaVector.Norm();
            local damage = victim.GetMaxHealth() * (0.7 - distance / 2000);
            if (!victim.IsPlayer())
                damage *= 2;

            params.damage += damage;
            return;
        }
    }

    function OnDamageDealtPost(victim, params)
    {
        if (perform)
        {
            if (victim.IsPlayer())
            {
                local deltaVector = victim.GetCenter() - boss.GetCenter();
                local distance = deltaVector.Norm();
                local pushForce = distance < 100 ? 10 : 10 / sqrt(distance);
                deltaVector.x = deltaVector.x * 1250 * pushForce;
                deltaVector.y = deltaVector.y * 1250 * pushForce;
                deltaVector.z = 750 * pushForce;
                victim.Yeet(deltaVector);
            }

            Perform(victim);
        }
    }

    function Perform(victim)
    {
        meter -= 30;
        perform = false;
        vsh_vscript.Hale_SetRedArm(boss, false);

        local haleEyeVector = boss.EyeAngles().Forward();
        haleEyeVector.Norm();

        boss.RemoveCond(TF_COND_CRITBOOSTED);
        EmitSoundOn("TFPlayer.CritHit", boss);
        EmitSoundOn("vsh_sfx.saxton_punch", boss);
        if (GetAliveMercCount() > 1)
            EmitPlayerVO(boss, "saxton_punch");
        DispatchParticleEffect("vsh_megapunch_shockwave", victim.EyePosition(), QAngle(0,boss.EyeAngles().Yaw(),0).Forward());
        ScreenShake(boss.GetCenter(), 10, 2.5, 1, 1000, 0, true);

        CreateAoE(boss.GetCenter(), 600,
            function (target, deltaVector, distance) {
                if (target == victim)
                    return;

                local dot = haleEyeVector.Dot(deltaVector);
                if (dot < 0.6)
                    return;
                local damage = target.GetMaxHealth() * (0.7 - distance / 2000);
                if (!target.IsPlayer())
                    damage *= 2;
                custom_dmg_saxton_punch_aoe.SetAbsOrigin(boss.GetOrigin());

                target.TakeDamageEx(
                    custom_dmg_saxton_punch_aoe,
                    boss,
                    boss.GetActiveWeapon(),
                    deltaVector * 1250,
                    boss.GetOrigin(),
                    damage,
                    DMG_BLAST);
            }
            function (target, deltaVector, distance) {
                if (target == victim)
                    return;

                local dot = haleEyeVector.Dot(deltaVector);
                if (dot < 0.6)
                    return;
                local pushForce = distance < 100 ? 10 : 10 / sqrt(distance);
                deltaVector.x = deltaVector.x * 1250 * pushForce;
                deltaVector.y = deltaVector.y * 1250 * pushForce;
                deltaVector.z = 750 * pushForce;
                target.Yeet(deltaVector);
            });
    }

    function MeterAsPercentage()
    {
        if (meter < 0)
            return (30 + meter) * 90 / 30;
        return 200
    }

    function MeterAsNumber()
    {
        local mapped = -meter+0.99;
        if (mapped <= 1)
            return "r";
        if (mapped < 10)
            return format(" %d", mapped);
        else
            return format("%d", mapped);
    }
};
