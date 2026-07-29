// Script by Senni, Assistance from Bradasparky.
// Script handles Soldier's gunboats providing fall damage immunity.
// This script requires modification to weapons.nut script to function.


characterTraitsClasses.push(class extends CharacterTrait
{
    wearable = null;

    function CanApply()
    {
        if (player.GetPlayerClass() != TF_CLASS_SOLDIER)
            return false;
        for (wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
        {
            if (WeaponIs(wearable, "gunboats"))
            {
                wearable.AddAttribute("cancel falling damage", 1, -1);
                return true;
            }
            if (WeaponIs(wearable, "base_jumper"))
            {
                wearable.AddAttribute("rocket jump damage reduction", 0.4, -1);
                return true;
            }
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
