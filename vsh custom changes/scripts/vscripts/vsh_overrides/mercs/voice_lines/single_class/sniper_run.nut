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

// Script modified by: Delfite.

::roundIsOver <- false;
AddListener("round_end", 0, function (winnerTeam)
{
	roundIsOver = true;
});

PrecacheArbitrarySound("sniper.run")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    weapon_primary = null;

    my_health = 0;
    // tickInverval = 0.5;
    tickInterval = 0.5;
    playInterval = 30;
    primaryIsHuntsman = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SNIPER;
    }

    function OnApply()
    {
        weapon_primary = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);

        // printdev("sniper_run.nut loaded.")
        if (WeaponIs(weapon_primary, "any_bow"))
            primaryIsHuntsman = true;
    }

    // TODO: Make whoever gets hit by Saxton Punch scream in terror as they're falling back to the ground (assuming they survive in the first place).
    // foreach (player in HitBySaxtonPunch)

    function OnFrameTickAlive()
    {
        my_health = player.GetHealth()
    }

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SNIPER;
    }

    function OnTickAlive(timeDelta)
    {
        if (roundIsOver)
            return;

        local distanceToBoss = 0;
        local my_center = player.GetCenter();
        foreach (boss in GetAliveBossPlayers())
        {
            distanceToBoss = (boss.GetCenter() - my_center).Length()
        }

        if (distanceToBoss < 500 && !player.IsInvulnerable())
        {
            switch(primaryIsHuntsman)
            {
                case true:
                    // printdev("Huntsman is equipped.")
                    if (my_health <= (195 * HUNTSMAN_RESISTANCE_FACTOR))
                    {
                        // printdev("Health is <= 137, playing voiceline...")
                        return EmitPlayerVO(player, "run");
                        break;
                    }
                    else
                        break;

                case false:
                    // printdev("Huntsman is not equipped.")
                    if (my_health <= 195)
                    {
                        // printdev("Health is <= 195, playing voiceline...")
                        return EmitPlayerVO(player, "run");
                        break;
                    }
                    else
                        break;

                default:
                    printdev("Our top scientists can't figure out how primaryIsHuntsman returned something other than a boolean!")
                        break;
            }
        }
    }
});