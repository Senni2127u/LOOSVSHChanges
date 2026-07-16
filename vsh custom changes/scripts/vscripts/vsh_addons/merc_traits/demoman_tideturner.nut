// Script by Senni
// Script handles Demoman's Tide Turner on kill effects happening on hit instead.
// This script requires modification to weapons.nut script to function.


characterTraitsClasses.push(class extends CharacterTrait
{

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnApply()
    {
        RunWithDelay2(this, 0.1, function()
        {
            local wearable = null;
            local melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
            while (wearable = FindByClassname(wearable, "tf_wearable_demoshield"))
            {
                if (wearable.GetOwner() == player && WeaponIs(wearable, "tideturner"))
                {
                    if (!WeaponIs(melee, "persian_persuader") && !WeaponIs(melee, "claidheamh_mor")) //Prevent these weapons from getting this, they need different changes.
                    {
                    //printl("tide turner found, applying attributes") //Debug
                    melee.AddAttribute("charge meter on hit", 0.75, -1); //If we apply the attribute directly to Tide Turner, it will do nothing, needs to be applied to his melee.
                    //printl(melee.GetAttribute("charge meter on hit", -1)); //Debug
                    }

                    if (WeaponIs(melee, "persian_persuader"))
                    {
                        melee.AddAttribute("charge meter on hit" 0.95, -1); //Adding Tide Turner's attribute ontop.
                    }

                    if (WeaponIs(melee, "claidheamh_mor"))
                    {
                        melee.AddAttribute("charge meter on hit" 1.0, -1); //Same here.
                    }
                    return true;
                }
            }
        });
    }
});