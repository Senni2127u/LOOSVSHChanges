//Copyright: Senni, Delfite, Horiuchi, Bradasparky.
//Remember to put your name next to your comments so we know who changed what.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
{
    if (player.GetPlayerClass() != TF_CLASS_SOLDIER)
        return;
    
    local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
    return weapon && WeaponIs(weapon, "any_banner");
}

    //This function is responsible for fixing TF_COND_DEFENSEBUFF from not applying its damage resistance to Hale's abilities.
    //Intended as a fix for the Battalion's Backup, but fixes the condition as a whole. -Delfite
    function OnDamageTaken(attacker, params)
    {
        if (IsValidBoss(attacker))
        {
            if ((params.damage_type & (DMG_CLUB))) //Ignore Saxton's normal hits, the game already handles the resistance. - Senni
            {
                return;
            }

            if (player.InCond(TF_COND_DEFENSEBUFF))
            {
                params.damage *= 0.65
                //printl("damage resisted on merc") //Debug to make sure resistance is applied - Senni
            }
        }
    }



    //This function is responsible for adding Rage to every player's currently equipped banner (if any). -Delfite
    function OnFrameTickAlive()
    {
        local rage = player.GetRageMeter();
                if (rage < 100) //Stop charging it once at full, because that's a waste. - Senni
                {
                    player.SetRageMeter(clampCeiling(100, rage + 0.02525252525252525252525252525253)); //Adding 0.025 to the meter to get 60 seconds - Senni
                    //printl(player.GetRageMeter()) //Debug
                }
        }
    })
