//Assistance from Bradasparky and Dice, Modified partially by Senni


characterTraitsClasses.push(class extends CharacterTrait
{
    timer = null
    caber = null
    caberChecked = null

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        timer = 0
        caber = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE)
        caberChecked = false
    }

function OnTickAlive(timeDelta) 
{
    if (!caberChecked)
    {
        if (GetPropInt(caber, "m_iDetonated"))
        {
            timer = 15;
            caberChecked = true;
        }
        
        return;
    }

    timer -= timeDelta;

    local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
    if (WeaponIs(weapon, "ullapoolcaber"))  //Solution to caber check in the mean time to avoid voicelines/charge sound playing when it's not present, likely need a better solution than this.
    {
        if (timer < 0)
        {
            timer = 0;
            caberChecked = false;
            SetPropInt(caber, "m_iDetonated", 0);
            EmitSoundOnClient("TFPlayer.ReCharged", player);
            return EmitPlayerVO(player, "sticky_trap"); // Playing the sticky trap voiceline so player is more aware about the recharge.
            
        }
    }
    
}
});