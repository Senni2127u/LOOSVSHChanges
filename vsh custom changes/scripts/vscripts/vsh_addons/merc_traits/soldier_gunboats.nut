// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's gunboats providing fall damage immunity.
// This script requires modification to weapons.nut script to function.


characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        if (player.GetPlayerClass() != TF_CLASS_SOLDIER)
            return false;
        local wearable = null;
        while (wearable = FindByClassname(wearable, "tf_wearable"))
            if (wearable.GetOwner() == player && WeaponIs(wearable, "gunboats")) //Gunboats aren't considered a weapon, so this is a workaround.
            {
                wearable.AddAttribute("cancel falling damage", 1, -1);
                return true;
            }
        return false;
    }

    // function OnDiscard()
    // {
    //     if (wearable && wearable.IsValid())
    //     {
    //         wearable.RemoveAttribute("cancel falling damage");
    //         wearable.RemoveAttribute("rocket jump damage reduction");
    //     }
    // }
});
