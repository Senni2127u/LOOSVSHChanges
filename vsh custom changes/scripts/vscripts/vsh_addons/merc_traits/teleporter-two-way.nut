// Script by Senni, Assistance from Bradasparky.
// Script handles two way teleporter functions from Mann VS Machine.
// No required modifications to base gamemode files.

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_ENGINEER;
    }

    function OnApply()
    {
    local constructionpda = player.GetWeaponBySlot(TF_WEAPONSLOTS.PDA);
        if (constructionpda != null)
            constructionpda.AddAttribute("bidirectional teleport", 1, -1);
    }
});