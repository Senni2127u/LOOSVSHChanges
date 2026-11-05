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

PrecacheClassVoiceLines("rage")
PrecacheArbitrarySound("xmas.jingle_noisemaker");

::HaleStunBreakout <- function()
{
    local boss = GetBossPlayers()[0]

    // printdev(damageRequired)

    RunWithDelay2(this, 0.0, function ()
    {
        if (boss.IsAlive())
            EmitPlayerVO(boss, "rage");
    })

    boss.RemoveCond(TF_COND_STUNNED);
    boss.RemoveCond(TF_COND_TAUNTING);
    boss.Yeet(Vector(0,0,800));

    DispatchParticleEffect("vsh_mighty_slam", boss.GetOrigin() + Vector(0,0,20), Vector(0,0,0));
    EmitSoundOn("vsh_sfx.boss_slam_impact", boss);

    // Delfite: Original radius was 400, increased to 750 to make the breakout better at crowd dispersal.
    // The breakout also, originally, did 1 damage. For a shockwave that inflicts as much knockback as it does,
    // you'd think it would do more damage. So, I gave it more damage.
    CreateAoE(boss.GetCenter(), 750,
        function (target, deltaVector, distance) {
            local targetMaxHealth = target.GetMaxHealth()
            local minDamage = targetMaxHealth * 0.15
            local maxDamage = targetMaxHealth * 0.85
            local breakoutDamage = targetMaxHealth * 6 / sqrt(distance)
            local finalDamage = clamp(breakoutDamage, minDamage, maxDamage)
            // printdev("Damage: " + finalDamage)
            // printdev("minDamage: " + minDamage)
            // printdev("maxDamage: " + maxDamage)
            target.TakeDamageEx(
                custom_dmg_hale_taunt,   // inflictor
                boss,   // attacker
                boss.GetActiveWeapon(), // weapon
                (target.IsPlayer() && target.InCond(TF_COND_MEGAHEAL)) ? deltaVector * 0 : deltaVector * 2400,
                boss.GetOrigin(),
                finalDamage,
                DMG_BLAST);
        }
        function (target, deltaVector, distance) {
            local pushForce = distance < 100 ? 10 : 10 / sqrt(distance);
            deltaVector.x = deltaVector.x * 2400 * pushForce;
            deltaVector.y = deltaVector.y * 2400 * pushForce;
            deltaVector.z = 800 * pushForce;
            target.Yeet((target.IsPlayer() && target.InCond(TF_COND_MEGAHEAL)) ? deltaVector * 0 : deltaVector);
        });
}

class StunBreakoutTrait extends BossTrait
{
    stunTimer = 0;
    stunInitHealth = 0;
    holidayPunchTimeStamp = 0;

    function OnTickAlive(timeDelta)
    {
        local health = boss.GetHealth()
        ::bossHealthAsDecimal <- health.tofloat() / boss.GetMaxHealth().tofloat()
        ::damageRequired <- clampFloor(500, (bossHealthAsDecimal + 0.25) * 2400).tointeger()

        if (boss.IsControlStunned() || (Time() - holidayPunchTimeStamp <= 4 && boss.InCond(TF_COND_TAUNTING)))
        {
            stunTimer += timeDelta;

            if (stunInitHealth == 0)
                stunInitHealth = health;
            else if (health < stunInitHealth - damageRequired)
            {
                DoBreakOut();
                return;
            }
        }
        else if (stunTimer > 0)
            stunTimer -= timeDelta;
        if (stunTimer < 0)
        {
            stunTimer = 0;
            stunInitHealth = 0;
        }

        if (stunTimer >= 4)
            DoBreakOut();
    }

    function OnDamageTaken(attacker, params)
    {
        if (WeaponIs(params.weapon, "holiday_punch") && !boss.InCond(TF_COND_TAUNTING))
        {
            RunWithDelay2(this, 0, function(boss)
            {
                if (IsValidBoss(boss) && boss.InCond(TF_COND_TAUNTING))
                {
                    EmitPlayerVO(attacker, "laugh");
                    EmitSoundOn("xmas.jingle_noisemaker", boss);
                    holidayPunchTimeStamp = Time();
                    EmitPlayerVO(boss, "laugh");
                    boss.AddCustomAttribute("airblast vulnerability multiplier", 0.01, 4)
                    boss.AddCustomAttribute("damage force increase", 0.7, 4)
                }
            }, boss);
        };
    }

    function DoBreakOut()
    {
        stunTimer = 0;
        stunInitHealth = 0;

        HaleStunBreakout()
    }
};