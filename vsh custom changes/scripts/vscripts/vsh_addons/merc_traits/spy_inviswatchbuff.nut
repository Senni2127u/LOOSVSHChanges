// Script by Senni, Assistance from Bradasparky/Horiuchi
// Script handles no Cloak for Spy when cloaked, and movement speed bonus across the board for Spy.
// No required modifications to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnApply()
    {
    local inviswatch = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA2);
        if (inviswatch != null)
            inviswatch.AddAttribute("move speed bonus", 1.20, -1);
    }
});