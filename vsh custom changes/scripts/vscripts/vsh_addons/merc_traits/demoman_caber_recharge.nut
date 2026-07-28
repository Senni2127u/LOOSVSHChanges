//Assistance from Bradasparky and Dice, Modified partially by Senni


characterTraitsClasses.push(class extends CharacterTrait
{
    timer = null
    caberChecked = null
    weapon_melee = null

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        timer = 0
        caberChecked = false
        weapon_melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
    }

    function OnTickAlive(timeDelta)
    {
        if (WeaponIs(weapon_melee, "ullapool_caber"))  //Solution to caber check in the mean time to avoid voicelines/charge sound playing when it's not present, likely need a better solution than this.
        {
            if (!caberChecked)
            {
                if (GetPropInt(weapon_melee, "m_iDetonated"))
                {
                    timer = 12;
                    caberChecked = true;
                }
                return;
            }

            timer -= timeDelta;

            if (timer < 0)
            {
                timer = 0;
                caberChecked = false;
                SetPropInt(weapon_melee, "m_iDetonated", 0);
                EmitSoundOnClient("TFPlayer.ReCharged", player);
                return EmitPlayerVO(player, "sticky_trap"); // Playing the sticky trap voiceline so player is more aware about the recharge.

            }
        }
    }
});